//
//  ASEMultipeerMessageManager.m
//  ASEnterprise
//
//  Created by David Mitchell on 7/6/16.
//  Copyright © 2016 The App Studio LLC. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//	   http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "ASEMultipeerMessageManager.h"

#if !TARGET_OS_WATCH

#import "ASEMultipeerMessagePayload.h"
#import "NSData+ASEnterpriseCategories.h"

NSString* const kASEMultipeerErrorDomain = @"ASEMultipeerErrorDomain";
NSString* const kASEMultipeerErrorKeyErrorsByPeerID = @"ASEMultipeerErrorKeyErrorsByPeerID";

@interface ASEMultipeerMessageManager () <MCSessionDelegate>

@property (nonatomic) NSMutableDictionary<NSUUID*,NSURL*>* pendingResourceURLs;
@property (nonatomic) NSMutableDictionary<NSUUID*,ASEMultipeerMessagePayload*>* pendingMessagePayloads;

@end

@implementation ASEMultipeerMessageManager
#pragma mark - Public methods

- (instancetype)initWithResourceContainerURL:(nullable NSURL*)resourceContainerURL forSession:(nullable MCSession*)session {
	self = [super init];
	self.pendingResourceURLs = [[NSMutableDictionary alloc] init];
	self.pendingMessagePayloads = [[NSMutableDictionary alloc] init];
	self.resourceContainerURL = resourceContainerURL;
	self.session = session;
	return self;
}

- (void)sendMessagePayload:(ASEMultipeerMessagePayload*)payload toPeers:(NSArray<MCPeerID*>*)peers completion:(void (^)(NSError* _Nullable))completion {
	NSParameterAssert(!!payload && !!completion);
	NSAssert(self.session != nil, @"Cannot send message without session being set");
	if ([self.session.connectedPeers count]) {
		NSString* resourceName = [self resourceNameForPayload:payload];
		if (payload.resourceURL && !resourceName) {
			// There was a problem creating a resourceName with the supplied resourceURL
			dispatch_async(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				completion([NSError errorWithDomain:kASEMultipeerErrorDomain code:ASEMultipeerMessageManagerErrorCouldNotEncodeResource userInfo:nil]);
			});
			return;
		}
		NSData* multipeerMessage = [NSKeyedArchiver archivedDataWithRootObject:payload];
		NSArray* peersToSendTo = peers ?: self.session.connectedPeers;
		NSError* sendError = nil;
		if ([self.session sendData:multipeerMessage toPeers:peersToSendTo withMode:MCSessionSendDataReliable error:&sendError]) {
			if (resourceName) {
				NSMutableDictionary* sendErrors = [[NSMutableDictionary alloc] initWithCapacity:[peersToSendTo count]];
				dispatch_group_t resourceGroup = dispatch_group_create();
				for (MCPeerID* peerID in peersToSendTo) {
					dispatch_group_enter(resourceGroup);
					[self.session sendResourceAtURL:payload.resourceURL withName:resourceName toPeer:peerID withCompletionHandler:^(NSError* _Nullable error) {
						if (error) {
							@synchronized (sendErrors) {
								sendErrors[peerID] = error;
							}
						}
						dispatch_group_leave(resourceGroup);
					}];
				}
				dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
					if (dispatch_group_wait(resourceGroup, DISPATCH_TIME_FOREVER) != 0) {
						NSLog(@"Error waiting for resourceGroup"); // This should never happen
					}
					NSError* partialError = [sendErrors count] ? [NSError errorWithDomain:kASEMultipeerErrorDomain code:ASEMultipeerMessageManagerErrorPartialErrorsEmbedded userInfo:@ {
							NSLocalizedDescriptionKey : @"Partial errors sending resource to peers",
							kASEMultipeerErrorKeyErrorsByPeerID : [sendErrors copy],
					}] : nil;
					dispatch_async(self.callbackQueue ?: dispatch_get_main_queue(), ^{
						completion(partialError);
					});
				});
			} else {
				dispatch_async(self.callbackQueue ?: dispatch_get_main_queue(), ^{
					completion(nil);
				});
			}
		} else {
			dispatch_async(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				completion(sendError);
			});
		}
		NSAssert(!sendError, @"Error sending object: %@", sendError);
	} else {
		dispatch_async(self.callbackQueue ?: dispatch_get_main_queue(), ^{
			completion([NSError errorWithDomain:kASEMultipeerErrorDomain code:ASEMultipeerMessageManagerErrorNoConnectedPeers userInfo:@ {
				NSLocalizedDescriptionKey : @"No connected peers",
			}]);
		});
	}
}

#pragma mark - Public properties

- (void)setResourceContainerURL:(NSURL*)resourceContainerURL {
	if (!!resourceContainerURL && ![resourceContainerURL isFileURL]) {
		[NSException raise:NSInvalidArgumentException format:@"resourceContainerURL must be a file URL"];
	}
	_resourceContainerURL = resourceContainerURL;
}

- (void)setSession:(MCSession*)session {
	if (_session == session) return;
	_session.delegate = nil;
	[_session disconnect];
	_session = session;
	_session.delegate = self;
}

#pragma mark - Private methods

- (BOOL)moveFileFromSourceURL:(NSURL*)sourceURL toDestinationURL:(NSURL*)destinationURL error:(NSError* _Nullable __autoreleasing * _Nullable)error {
	NSFileManager* fileManager = [[NSFileManager alloc] init];
	NSFileCoordinator* coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
	__block BOOL success = NO;
	__block NSError* moveError = nil;
	NSURL* directoryURL = [destinationURL URLByDeletingLastPathComponent];
	if (directoryURL) {
		[coordinator coordinateWritingItemAtURL:directoryURL options:NSFileCoordinatorWritingForDeleting error:&moveError byAccessor:^(NSURL* writingURL) {
			[fileManager createDirectoryAtURL:writingURL withIntermediateDirectories:YES attributes:nil error:&moveError];
		}];
	}
	if (!moveError) {
		[coordinator coordinateWritingItemAtURL:destinationURL options:NSFileCoordinatorWritingForMoving error:&moveError byAccessor:^(NSURL* writingURL) {
			success = [fileManager moveItemAtURL:sourceURL toURL:writingURL error:&moveError];
		}];
	}
	NSAssert(!moveError, @"Failed to move file: %@", moveError);
	if (moveError && error != NULL) {
		*error = moveError;
	}
	return success;
}

- (NSString*)resourceNameForPayload:(ASEMultipeerMessagePayload*)payload {
	NSString* lastPathComponent = [payload.resourceURL lastPathComponent];
	return lastPathComponent ? [NSString stringWithFormat:@"%@/%@", payload.UUID.UUIDString, lastPathComponent] : nil;
}

#pragma mark - <MCSessionDelegate> methods

- (void)session:(MCSession*)session didFinishReceivingResourceWithName:(NSString*)resourceName fromPeer:(MCPeerID*)peerID atURL:(NSURL*)localURL withError:(NSError*)error {
	NSString* UUIDString = [[resourceName componentsSeparatedByString:@"/"] firstObject];
	NSUUID* messageIdentifier = [[NSUUID alloc] initWithUUIDString:UUIDString];
	NSAssert(messageIdentifier != nil, @"We have a nil messageIdentifier");
	if (error || !localURL || !messageIdentifier) {
		// Unexpected problem! Clean up and return
		if (messageIdentifier) {
			[self.pendingMessagePayloads removeObjectForKey:messageIdentifier];
		}
		if (error && [self.delegate respondsToSelector:@selector(messageManager:didEncounterError:receivingResourceForMessagePayloadWithIdentifier:fromPeer:)]) {
			dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				[self.delegate messageManager:self didEncounterError:error receivingResourceForMessagePayloadWithIdentifier:messageIdentifier fromPeer:peerID];
			});
		}
		return;
	}
	if (!self.resourceContainerURL) {
		[self.pendingMessagePayloads removeObjectForKey:messageIdentifier];
		if ([self.delegate respondsToSelector:@selector(messageManager:didEncounterError:receivingResourceForMessagePayloadWithIdentifier:fromPeer:)]) {
			NSError* receiveError = [NSError errorWithDomain:kASEMultipeerErrorDomain code:ASEMultipeerMessageManagerErrorNoResourceContainerURL userInfo:nil];
			dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				[self.delegate messageManager:self didEncounterError:receiveError receivingResourceForMessagePayloadWithIdentifier:messageIdentifier fromPeer:peerID];
			});
		}
		return;
	}
	// We have recieved the resource. Move it to a safe place and notify the delegate if everything has arrived.
	NSURL* resourceURL = [NSURL fileURLWithPath:resourceName relativeToURL:self.resourceContainerURL];
	NSError* moveError = nil;
	if ([self moveFileFromSourceURL:localURL toDestinationURL:resourceURL error:&moveError]) {
		ASEMultipeerMessagePayload* payload = self.pendingMessagePayloads[messageIdentifier];
		if (payload) { // Combine with the associated message
			payload.resourceURL = resourceURL;
			[self.pendingMessagePayloads removeObjectForKey:messageIdentifier];
			dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				[self.delegate messageManager:self didReceiveMessagePayload:payload fromPeer:peerID];
			});
		} else { // Wait for the associated message to arrive
			self.pendingResourceURLs[messageIdentifier] = resourceURL;
		}
	} else { // There was an error, clean up internal state
		[self.pendingMessagePayloads removeObjectForKey:messageIdentifier];
		if ([self.delegate respondsToSelector:@selector(messageManager:didEncounterError:receivingResourceForMessagePayloadWithIdentifier:fromPeer:)]) {
			dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
				[self.delegate messageManager:self didEncounterError:moveError receivingResourceForMessagePayloadWithIdentifier:messageIdentifier fromPeer:peerID];
			});
		}
	}
}

- (void)session:(MCSession*)session didReceiveCertificate:(NSArray*)certificate fromPeer:(MCPeerID*)peerID certificateHandler:(void (^)(BOOL))certificateHandler {
	certificateHandler(YES); // Subclasses should override if they want different behavior
}

- (void)session:(MCSession*)session didReceiveData:(NSData*)data fromPeer:(MCPeerID*)peerID {
	[data ase_SecureDecodeAsClass:[ASEMultipeerMessagePayload class] completionHandler:^(ASEMultipeerMessagePayload* payload, NSException* exception) {
		if (payload) {
			NSString* resourceName = [self resourceNameForPayload:payload];
			if (resourceName) { // We are expecting a resource with this payload
				NSURL* pendingResource = self.pendingResourceURLs[payload.UUID];
				if (pendingResource) {
					payload.resourceURL = pendingResource;
					[self.pendingResourceURLs removeObjectForKey:payload.UUID];
					dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
						[self.delegate messageManager:self didReceiveMessagePayload:payload fromPeer:peerID];
					});
				} else { // Save the payload until we get the resource
					self.pendingMessagePayloads[payload.UUID] = payload;
				}
			} else { // There's no resource to wait for. Call the delegate
				dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
					[self.delegate messageManager:self didReceiveMessagePayload:payload fromPeer:peerID];
				});
			}
		} else if (exception) {
			if ([self.delegate respondsToSelector:@selector(messageManager:didEncounterException:decodingMessageFromPeer:)]) {
				dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
					[self.delegate messageManager:self didEncounterException:exception decodingMessageFromPeer:peerID];
				});
			}
		}
	}];
}

- (void)session:(MCSession*)session didReceiveStream:(NSInputStream*)stream withName:(NSString*)streamName fromPeer:(MCPeerID*)peerID {
	// Do nothing. Subclasses may override
}

- (void)session:(MCSession*)session didStartReceivingResourceWithName:(NSString*)resourceName fromPeer:(MCPeerID*)peerID withProgress:(NSProgress*)progress {
	// Do nothing. Subclasses may override
}

- (void)session:(MCSession*)session peer:(MCPeerID*)peerID didChangeState:(MCSessionState)state {
	dispatch_sync(self.callbackQueue ?: dispatch_get_main_queue(), ^{
		[self.delegate messageManager:self didChangeConnectionState:state forPeer:peerID];
	});
}

@end

#endif
