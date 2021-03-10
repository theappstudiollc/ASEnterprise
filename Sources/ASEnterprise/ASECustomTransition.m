//
//  ASECustomTransition.m
//  ASEnterprise
//
//  Created by David Mitchell on 12/16/14.
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

#import <objc/runtime.h>
#import "ASECustomTransition.h"

static void* const kASETransitioningDelegateKey = (void*)&kASETransitioningDelegateKey;

@implementation ASECustomTransitionSegue : UIStoryboardSegue

- (id<UIViewControllerTransitioningDelegate>)delegateForTransitioning {
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (void)perform {
	UIViewController* destinationViewController = [self viewControllerWrappingPresentedViewController:self.destinationViewController];
	[destinationViewController setModalPresentationStyle:UIModalPresentationCustom];
	if (![destinationViewController transitioningDelegate]) {
		// Get and save the transitioning delegate (so that we can use it for dismissal)
		id<UIViewControllerTransitioningDelegate> transitioningDelegate = objc_getAssociatedObject(destinationViewController, kASETransitioningDelegateKey);
		if (!transitioningDelegate) {
			transitioningDelegate = [self delegateForTransitioning];
			if (transitioningDelegate) {
				objc_setAssociatedObject(destinationViewController, kASETransitioningDelegateKey, transitioningDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
			}
		}
		[destinationViewController setTransitioningDelegate:transitioningDelegate];
	}
	// Now perform the segue transition
	[self.sourceViewController presentViewController:destinationViewController animated:YES completion:NULL];
}

- (UIViewController*)viewControllerWrappingPresentedViewController:(UIViewController*)viewController {
	return viewController;
}

@end

#pragma mark -
@interface ASECustomAnimatedTransition ()

@property (weak, nonatomic) UIViewController* aseFromViewController;
@property (weak, nonatomic) UIViewController* aseToViewController;
@property (nonatomic) BOOL aseAnimatedTransition;
@property (nonatomic, getter=isPresenting) BOOL presenting;

@end

@implementation ASECustomAnimatedTransition

- (void)animatePresentation:(id<UIViewControllerContextTransitioning>)transitionContext {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)animateDismissal:(id<UIViewControllerContextTransitioning>)transitionContext {
	[self doesNotRecognizeSelector:_cmd];
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	self.aseAnimatedTransition = [transitionContext isAnimated];
	self.aseFromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
	self.aseToViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
	
	if (self.isPresenting) { // We cannot depend on toViewController's isBeingPresented
		[self.aseFromViewController beginAppearanceTransition:NO animated:self.aseAnimatedTransition];
		[self animatePresentation:transitionContext];
	} else {
		[self.aseToViewController beginAppearanceTransition:YES animated:self.aseAnimatedTransition];
		[self animateDismissal:transitionContext];
	}
}

- (void)animationEnded:(BOOL)transitionCompleted {
	if (!transitionCompleted) {
		if (self.isPresenting) {
			[self.aseFromViewController beginAppearanceTransition:YES animated:self.aseAnimatedTransition];
			objc_setAssociatedObject(self.aseToViewController, kASETransitioningDelegateKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
		} else {
			[self.aseToViewController beginAppearanceTransition:NO animated:self.aseAnimatedTransition];
		}
	}
	if (self.isPresenting) {
		[self.aseFromViewController endAppearanceTransition];
	} else {
		[self.aseToViewController endAppearanceTransition];
	}
	self.aseFromViewController = nil;
	self.aseToViewController = nil;
}

- (instancetype)initAsPresenting:(BOOL)presenting {
	self = [super init];
	self.presenting = presenting;
	return self;
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
	// This is an abstract method that must be overridden (here to prevent build warnings)
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

@end

#pragma mark -
@interface ASECustomAnimatedDismissibleTransition ()

@property (nonatomic) NSArray* dismissGestureRecognizers;

@end

@implementation ASECustomAnimatedDismissibleTransition

- (void)animationEnded:(BOOL)transitionCompleted {
	[super animationEnded:transitionCompleted];
	if (transitionCompleted ^ self.isPresenting) {
		for (UIGestureRecognizer* gestureRecognizer in self.dismissGestureRecognizers) {
			[[gestureRecognizer view] removeGestureRecognizer:gestureRecognizer];
		}
		[self.dismissView removeFromSuperview];
	}
}

- (void)setDismissView:(UIView*)dismissView {
	if (_dismissView == dismissView) return;
	for (UIGestureRecognizer* gestureRecognizer in self.dismissGestureRecognizers) {
		[_dismissView removeGestureRecognizer:gestureRecognizer];
	}
	for (UIGestureRecognizer* gestureRecognizer in self.dismissGestureRecognizers) {
		[dismissView addGestureRecognizer:gestureRecognizer];
	}
	_dismissView = dismissView;
}

- (void)setGestureRecognizers:(UIGestureRecognizer*)gestureRecognizers, ... {
	NSMutableArray* temp = [[NSMutableArray alloc] initWithCapacity:2];
	va_list args;
	va_start(args, gestureRecognizers);
	UIGestureRecognizer* gestureRecognizer = gestureRecognizers;
	do {
		[temp addObject:gestureRecognizer];
	} while ((gestureRecognizer = va_arg(args, UIGestureRecognizer*)));
	va_end(args);
	// If self.dismissView is already set, add these gestures to the view
	for (UIGestureRecognizer* gestureRecognizer in temp) {
		[self.dismissView addGestureRecognizer:gestureRecognizer];
	}
	// Remove pre-existing gestures from their views before updating the backing store
	for (UIGestureRecognizer* gestureRecognizer in self.dismissGestureRecognizers) {
		[[gestureRecognizer view] removeGestureRecognizer:gestureRecognizer];
	}
	self.dismissGestureRecognizers = [temp copy];
}

@end

#pragma mark -
@interface ASECustomInteractiveTransition ()

@property (nonatomic) CGFloat completionSpeed;
@property (nonatomic) CFTimeInterval pausedTime;
@property (weak, nonatomic) id<UIViewControllerContextTransitioning> transitionContext;

@end

@implementation ASECustomInteractiveTransition
#pragma mark - <UIViewControllerInteractiveTransitioning> methods

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
	NSAssert(self.animator, @"We cannot start an interactive transition without knowing the animator!");
	self.transitionContext = transitionContext;
	// NOTE: According to Apple docs this class is responsible for telling the animator to begin...
	[self.animator animateTransition:transitionContext];
	[self pauseLayer:[transitionContext containerView].layer];
}

#pragma mark - Public methods

- (void)cancelInteractiveTransition {
	[self.transitionContext cancelInteractiveTransition];
	CALayer* containerLayer = [self.transitionContext containerView].layer;
	containerLayer.speed = -1.0;
	containerLayer.beginTime = CACurrentMediaTime();
#if CGFLOAT_IS_DOUBLE
	CGFloat delay = ((1.0 - self.completionSpeed) * [self.animator transitionDuration:self.transitionContext]) + 0.05;
#else
	CGFloat delay = ((1.f - self.completionSpeed) * (CGFloat)[self.animator transitionDuration:self.transitionContext]) + 0.05f;
#endif
	// TODO: Find a better way to restore the layer's animation speed
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		containerLayer.speed = 1.0;
	});
}

- (void)finishInteractiveTransition {
	[self.transitionContext finishInteractiveTransition];
	[self resumeLayer:[self.transitionContext containerView].layer];
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
#if CGFLOAT_IS_DOUBLE
	self.completionSpeed = 1.0 - percentComplete;
#else
	self.completionSpeed = 1.f - percentComplete;
#endif
	[self.transitionContext updateInteractiveTransition:percentComplete];
	[self.transitionContext containerView].layer.timeOffset = self.pausedTime + [self.animator transitionDuration:self.transitionContext] * percentComplete;
}

#pragma mark - Private methods

- (void)pauseLayer:(CALayer*)layer {
	CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
	layer.speed = 0.0;
	layer.timeOffset = pausedTime;
	self.pausedTime = pausedTime;
}

- (void)resumeLayer:(CALayer*)layer {
	CFTimeInterval pausedTime = [layer timeOffset];
	layer.speed = 1.0;
	layer.timeOffset = 0.0;
	layer.beginTime = 0.0;
	CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
	layer.beginTime = timeSincePause;
}

@end

#pragma mark -
@implementation ASECustomTransition

- (ASECustomAnimatedTransition*)animationTransitionController {
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController*)dismissed {
	ASECustomAnimatedTransition* animationController = [self animationTransitionController];
	NSAssert(animationController, @"animationTransitionController is required");
	animationController.presenting = NO;
	return animationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController*)presented presentingController:(UIViewController*)presenting sourceController:(UIViewController*)source {
	ASECustomAnimatedTransition* animationController = [self animationTransitionController];
	NSAssert(animationController, @"animationTransitionController is required");
	animationController.presenting = YES;
	return animationController;
}

@end

#endif
