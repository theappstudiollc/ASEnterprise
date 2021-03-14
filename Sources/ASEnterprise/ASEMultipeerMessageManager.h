//
//  ASEMultipeerMessageManager.h
//  ASEnterprise
//
//  Created by David Mitchell on 7/6/16.
//  Copyright © 2016 The App Studio LLC.
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

#import <Foundation/Foundation.h>

#if !TARGET_OS_WATCH

#import <MultipeerConnectivity/MultipeerConnectivity.h>

NS_ASSUME_NONNULL_BEGIN

/** Error domain used in ASEMultipeerMessageManager-specific NSErrors */
OBJC_EXTERN NSString* const kASEMultipeerErrorDomain;
/** Points to an NSDictionary of NSErrors keyed by MCPeerID. Used with ASEMultipeerMessageManagerErrorPartialErrorsEmbedded. */
OBJC_EXTERN NSString* const kASEMultipeerErrorKeyErrorsByPeerID;

@class ASEMultipeerMessageManager, ASEMultipeerMessagePayload;

@protocol ASEMultipeerMessageManagerDelegate <NSObject>

@required
/** Called when a message is received from a peer, along with an optional recource at URL. */
- (void)messageManager:(__kindof ASEMultipeerMessageManager*)manager didReceiveMessagePayload:(ASEMultipeerMessagePayload*)payload fromPeer:(MCPeerID*)peerID;

@optional
/** Called when the connection state to a peer changes */
- (void)messageManager:(__kindof ASEMultipeerMessageManager*)manager didChangeConnectionState:(MCSessionState)connectionState forPeer:(MCPeerID*)peerID;
/** Called when an error is encountered while receiving a resource from a peer. Enough information is provided so that a request for resubmission may be attempted. */
- (void)messageManager:(__kindof ASEMultipeerMessageManager*)manager didEncounterError:(NSError*)error receivingResourceForMessagePayloadWithIdentifier:(NSUUID*)payloadIdentifier fromPeer:(MCPeerID*)peerID;
/** Called when an exception is encountered decoding a message from a peer. This can happen if an invalid (possibly malicious) payload was sent from the peer */
- (void)messageManager:(__kindof ASEMultipeerMessageManager*)manager didEncounterException:(NSException*)exception decodingMessageFromPeer:(MCPeerID*)peerID;

@end

/** An embeddable manager for sending and receiving messages through MultipeerConnectivity. This class is not responsible for establishing the connection to peers, thus it may be subclassed or contained by another manager or service. */
@interface ASEMultipeerMessageManager : NSObject

typedef NS_ENUM(NSInteger, ASEMultipeerMessageManagerError) {
	/** The message could not be sent because there are no peers to receive it */
	ASEMultipeerMessageManagerErrorNoConnectedPeers = -1,
	/** There was a problem encoding the supplied resourceURL during message send */
	ASEMultipeerMessageManagerErrorCouldNotEncodeResource = -2,
	/** A message was received by a peer containing a resource, yet there is no resourceContainerURL to store it */
	ASEMultipeerMessageManagerErrorNoResourceContainerURL = -3,
	/** Partial errors embedded into userInfo with the kASEMultipeerErrorKeyErrorsByPeerID key */
	ASEMultipeerMessageManagerErrorPartialErrorsEmbedded = -4,
};

/** An optional dispatch queue for the completion handlers or delegate methods to call back into. Otherwise the main queue is used */
@property (nullable, nonatomic) dispatch_queue_t callbackQueue;
/** The delegate for this manager. */
@property (weak, nonatomic) id<ASEMultipeerMessageManagerDelegate> delegate;
/** An optional file-based container URL that will store incoming message resources. */
@property (nullable, nonatomic) NSURL* resourceContainerURL;
/** The current MCSession. The caller is responsible for assigning the session. This class will then assume the session's delegate responsibilities. */
@property (nullable, nonatomic) MCSession* session;

- (instancetype)init NS_UNAVAILABLE;
/** Instantiates a new instance with a resource container URL that will hold received message resources. The instantiator is responsible for making sure the container exists. */
- (instancetype)initWithResourceContainerURL:(nullable NSURL*)resourceContainerURL forSession:(nullable MCSession*)session NS_DESIGNATED_INITIALIZER;
/** Sends an ASEMultipeerMessagePayload to the specified peers with a required completion handler indicating success or failure. */
- (void)sendMessagePayload:(ASEMultipeerMessagePayload*)payload toPeers:(nullable NSArray<MCPeerID*>*)peers completion:(void(^)(NSError* _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END

#endif
