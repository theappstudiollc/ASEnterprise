//
//  ASEVideoPlayerView.h
//  ASEnterprise
//
//  Created by David Mitchell on 2/1/16.
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

#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

NS_ASSUME_NONNULL_BEGIN

@class ASEVideoPlayerView;

@protocol ASEVideoPlayerViewDelegate <NSObject>

@optional
- (void)videoPlayerView:(ASEVideoPlayerView*)videoPlayerView didEncounterError:(NSError*)error;
- (void)videoPlayerViewDidFinishPlaying:(ASEVideoPlayerView*)videoPlayerView;
- (void)videoPlayerViewReadyToPlay:(ASEVideoPlayerView*)videoPlayerView;

@end

#if TARGET_OS_IPHONE
@interface ASEVideoPlayerView : UIView
#elif TARGET_OS_MAC
@interface ASEVideoPlayerView : NSView
#endif

typedef void(^ASEVideoPlayerLoadCompletionHandler)(BOOL success, NSError* _Nullable error);

typedef NS_ENUM(NSInteger, ASEVideoPlayerResizeMode) {
	VideoPlayerResizeAspectFill = 0, // This is the default
	VideoPlayerResizeAspect,
	VideoPlayerResize,
};

@property (weak, nonatomic) IBOutlet id<ASEVideoPlayerViewDelegate> delegate;
@property (nonatomic, getter = isPlaying) BOOL playing;
@property (nonatomic) ASEVideoPlayerResizeMode resizeMode;
@property (readonly, nonatomic) CGSize videoSize;
@property (nullable, nonatomic) NSURL* videoURL;

- (void)setVideoURL:(nullable NSURL*)videoURL withCompletionHandler:(nullable ASEVideoPlayerLoadCompletionHandler)handler;
- (void)play;
- (void)pause;
- (void)reset;

@end

NS_ASSUME_NONNULL_END

#endif
