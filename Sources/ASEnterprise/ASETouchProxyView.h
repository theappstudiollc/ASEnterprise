//
//  ASETouchProxyView.h
//  ASEnterprise
//
//  Created by David Mitchell on 12/21/14.
//  Copyright (c) 2014 The App Studio LLC. All rights reserved.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// Used in situations where you don't want a root view to respond to touches,
// but you _do_ want its subviews to respond. For example, in a modal with a
// bounding region that is empty and transparent.
@interface ASETouchProxyView : UIView

/** By default, a subview with isUserInteractionEnabled == false will never be returned by hitTest:withEvent:. Change this to true to allow such subviews. Note that this rule applies even if touchViews have been manually set. */
@property (nonatomic, getter=ignoresUserInteractionEnabled) BOOL shouldIgnoreUserInteractionEnabled;

/** views that should be tested for touches. If null then the view's subviews are used. This array can still be affected by ignoresUserInteractionEnabled so set accordingly. */
@property (nullable, nonatomic) NSArray<UIView*>* touchViews;

@end

NS_ASSUME_NONNULL_END

#endif
