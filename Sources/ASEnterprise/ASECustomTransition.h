//
//  ASECustomTransition.h
//  ASEnterprise
//
//  Created by David Mitchell on 12/16/14.
//  Copyright (c) 2014 The App Studio LLC.
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

@interface ASECustomTransitionSegue : UIStoryboardSegue

/** Returns an optional wrapping viewController for the viewController being passed in */
- (UIViewController*)viewControllerWrappingPresentedViewController:(UIViewController*)viewController;

@end

@interface ASECustomTransitionSegue (AbstractMethods)

/** Returns the transitioning delegate used by this segue. Must be overridden by the subclass (calling super will result in an error) */
- (id<UIViewControllerTransitioningDelegate>)delegateForTransitioning;

@end

@interface ASECustomAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (readonly, nonatomic, getter=isPresenting) BOOL presenting;

/** Optional initializer specifying the presenting value */
- (instancetype)initAsPresenting:(BOOL)presenting;

@end

@interface ASECustomAnimatedTransition (AbstractMethods)

/** Animates the presentation of a new view controller. Must be overridden by the subclass (calling super will result in an error) */
- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext;

/** Animates the dismissal of a presented view controller. Must be overridden by the subclass (calling super will result in an error) */
- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext;

@end

@interface ASECustomAnimatedDismissibleTransition : ASECustomAnimatedTransition

/** An optional dismiss view that will host gesture recognizers for dismissal. This gets removed upon dismissal */
@property (nonatomic) UIView* dismissView;

/** Set gesture recognizers for the dismissView. These will be cleaned up automatically upon dismissal */
- (void)setGestureRecognizers:(UIGestureRecognizer*)gestureRecognizers, ... NS_REQUIRES_NIL_TERMINATION;

@end

@interface ASECustomInteractiveTransition : NSObject <UIViewControllerInteractiveTransitioning>

@property (weak, nonatomic) id<UIViewControllerAnimatedTransitioning> animator;

- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)finishInteractiveTransition;
- (void)cancelInteractiveTransition;

@end

@interface ASECustomTransition : NSObject <UIViewControllerTransitioningDelegate>

/** Provides access to this transitioning delegate's custom animated transition delegate. Derived subclasses are expected to implement and return a non-nil value */
@property (readonly, nonatomic) ASECustomAnimatedTransition* animationTransitionController;

@end

#endif
