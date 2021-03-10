//
//  ASEVideoPlayerView.m
//  ASEnterprise
//
//  Created by David Mitchell on 2/1/16.
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

#import <AVFoundation/AVFoundation.h>
#import "ASEVideoPlayerView.h"

#if !TARGET_OS_WATCH

@interface ASEVideoPlayerView ()

@property (nonatomic) AVAsset* asset;
@property (nonatomic) NSError* error;
@property (nonatomic) AVPlayer* player;
@property (nonatomic) AVPlayerItem* playerItem;
@property (nonatomic) CGSize videoSize;

@end

@implementation ASEVideoPlayerView
#pragma mark - NSView/UIView overrides

- (instancetype)init {
	self = [super init];
	[self setupView];
	return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	[self setupView];
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	[self setupView];
	return self;
}
#if TARGET_OS_IPHONE
- (CGSize)intrinsicContentSize {
	CGSize videoSize = [self videoSize];
	if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
		return CGSizeMake(UIViewNoIntrinsicMetric, UIViewNoIntrinsicMetric);
	}
	return videoSize;
}
	
+ (Class)layerClass {
	return [AVPlayerLayer class];
}
#elif TARGET_OS_MAC
- (NSSize)intrinsicContentSize {
	CGSize videoSize = [self videoSize];
	if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
		return NSMakeSize(NSViewNoIntrinsicMetric, NSViewNoIntrinsicMetric);
	}
	return NSSizeFromCGSize(videoSize);
}

- (BOOL)wantsUpdateLayer {
	return YES;
}
#endif
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
	if ([object isKindOfClass:[AVPlayerItem class]]) {
		AVPlayerItem* playerItem = object; // All reads/updates need to be on the main thread now
		dispatch_async(dispatch_get_main_queue(), ^{
			if (self.playerItem == playerItem) {
				if ([keyPath isEqualToString:@"presentationSize"]) {
					self.videoSize = playerItem.presentationSize;
					[self invalidateIntrinsicContentSize];
				} else if ([keyPath isEqualToString:@"status"]) {
					if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
						if ([change[NSKeyValueChangeOldKey] isEqualToNumber:@(playerItem.status)]) {
							if ([self isPlaying]) {
								[self.player play];
							}
						} else {
							if ([self.delegate respondsToSelector:@selector(videoPlayerViewReadyToPlay:)]) {
								[self.delegate videoPlayerViewReadyToPlay:self];
							}
						}
					} else if (playerItem.status == AVPlayerItemStatusFailed) {
						if ([self.delegate respondsToSelector:@selector(videoPlayerView:didEncounterError:)]) {
							[self.delegate videoPlayerView:self didEncounterError:playerItem.error];
						}
					}
				}
			}
		});
	}
}

- (void)removeFromSuperview {
	self.asset = nil;
	[super removeFromSuperview];
}

#pragma mark - Notifications

- (IBAction)playerItemDidEncounterError:(NSNotification*)notification {
	if (self.player.currentItem == notification.object) {
		if ([self.delegate respondsToSelector:@selector(videoPlayerView:didEncounterError:)]) {
			NSError* error = notification.userInfo[AVPlayerItemFailedToPlayToEndTimeErrorKey];
			[self.delegate videoPlayerView:self didEncounterError:error];
		}
	}
}

- (IBAction)playerItemDidReachEnd:(NSNotification*)notification {
	if (self.player.currentItem == notification.object) {
		self.playing = NO;
		if ([self.delegate respondsToSelector:@selector(videoPlayerViewDidFinishPlaying:)]) {
			[self.delegate videoPlayerViewDidFinishPlaying:self];
		}
	}
}

#pragma mark - Private properties and methods

- (void)setAsset:(AVAsset*)asset {
	if (_asset == asset || [_asset isEqual:asset]) return;
	_asset = asset;
	self.playerItem = _asset ? [AVPlayerItem playerItemWithAsset:asset] : nil;
}

- (void)setPlayerItem:(AVPlayerItem*)playerItem {
	if (_playerItem == playerItem) return;
	[self pause];
	if (_playerItem) {
		[_playerItem removeObserver:self forKeyPath:@"presentationSize" context:NULL];
		[_playerItem removeObserver:self forKeyPath:@"status" context:NULL];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
	}
	_playerItem = playerItem;
	if (_playerItem) {
		[_playerItem addObserver:self forKeyPath:@"presentationSize" options:NSKeyValueObservingOptionNew context:NULL];
		[_playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionOld context:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidEncounterError:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:_playerItem];
	}
	[self.player replaceCurrentItemWithPlayerItem:_playerItem];
#if TARGET_OS_IPHONE
	[self setNeedsDisplay];
#elif TARGET_OS_MAC
	[self setNeedsDisplay:YES];
#endif
}

- (void)setupView {
	_player = [[AVPlayer alloc] init];
#if TARGET_OS_IPHONE
	[(AVPlayerLayer*)self.layer setPlayer:self.player];
#elif TARGET_OS_MAC
	self.layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
	[self setWantsLayer:YES];
	[self setLayerContentsRedrawPolicy:NSViewLayerContentsRedrawOnSetNeedsDisplay];
#endif
	[self updateResizeMode];
}

- (void)updateResizeMode {
	NSString* videoGravity = [self videoGravityForResizeMode:_resizeMode];
	[(AVPlayerLayer*)self.layer setVideoGravity:videoGravity];
}

- (void)updateVideoURLWithCompletionHandler:(ASEVideoPlayerLoadCompletionHandler)handler {
	NSString* const tracksKey = @"tracks";
	if (!self.videoURL) {
		self.asset = nil;
		if (handler) {
			handler(YES, nil);
		}
		return;
	}
	AVURLAsset* asset = [AVURLAsset URLAssetWithURL:self.videoURL options:nil];
	[asset loadValuesAsynchronouslyForKeys:@[tracksKey] completionHandler:^{
		dispatch_async(dispatch_get_main_queue(), ^{
			NSError* error = nil;
			BOOL result = [asset statusOfValueForKey:tracksKey error:&error] == AVKeyValueStatusLoaded;
#if false	// Require assets with non-zero-sized videos only
			if (result) {
				for (AVAssetTrack* track in [asset tracksWithMediaType:AVMediaTypeVideo]) {
					if (!CGSizeEqualToSize(track.naturalSize, CGSizeZero)) {
						self.asset = asset;
						break;
					}
				}
			}
#else
			self.asset = result ? asset : nil;
#endif
			if (handler) {
				handler(!!self.asset, error);
			}
			if (error && [self.delegate respondsToSelector:@selector(videoPlayerView:didEncounterError:)]) {
				[self.delegate videoPlayerView:self didEncounterError:error];
			}
		});
	}];
}

- (NSString*)videoGravityForResizeMode:(ASEVideoPlayerResizeMode)resizeMode {
	switch (resizeMode) {
		case VideoPlayerResize:
			return AVLayerVideoGravityResize;
		case VideoPlayerResizeAspect:
			return AVLayerVideoGravityResizeAspect;
		case VideoPlayerResizeAspectFill:
			return AVLayerVideoGravityResizeAspectFill;
	}
}

#pragma mark - Public properties and methods

- (void)setResizeMode:(ASEVideoPlayerResizeMode)resizeMode {
	if (_resizeMode == resizeMode) return;
	_resizeMode = resizeMode;
	[self updateResizeMode];
}

- (void)setVideoURL:(NSURL*)videoURL {
	[self setVideoURL:videoURL withCompletionHandler:NULL];
}

- (void)setVideoURL:(NSURL*)videoURL withCompletionHandler:(ASEVideoPlayerLoadCompletionHandler)handler {
	if (_videoURL == videoURL || [_videoURL isEqual:videoURL]) {
		if (handler) {
			handler(!!self.asset == !!videoURL, nil);
		}
		return;
	}
	_videoURL = videoURL;
	[self updateVideoURLWithCompletionHandler:handler];
}

- (void)play {
	if (!self.isPlaying) {
		if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
			[self.player play];
		}
		self.playing = YES;
	}
}

- (void)pause {
	[self.player pause];
	self.playing = NO;
}

- (void)reset {
	[self pause];
	[self.player seekToTime:kCMTimeZero completionHandler:^(BOOL finished) {
		if ([self.delegate respondsToSelector:@selector(videoPlayerViewReadyToPlay:)]) {
			[self.delegate videoPlayerViewReadyToPlay:self];
		}
	}];
}

@end

#endif
