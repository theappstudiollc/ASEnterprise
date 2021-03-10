//
//  ASENetworkActivityIndicatorManager.m
//  ASEnterprise
//
//  Created by David Mitchell on 3/13/16.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import <UIKit/UIKit.h>
#import "ASENetworkActivityIndicatorManager.h"

@interface ASENetworkActivityIndicatorManager ()

@property (nonatomic) UIApplication* application;
@property (nonatomic) NSHashTable* requestors;

@end

@implementation ASENetworkActivityIndicatorManager
#pragma mark - Public methods

- (instancetype)initWithApplication:(UIApplication*)application {
	self = [super init];
	self.application = application;
	self.requestors = [[NSHashTable alloc] initWithOptions:NSPointerFunctionsWeakMemory|NSPointerFunctionsObjectPointerPersonality capacity:8];
	return self;
}

#pragma mark - <ASENetworkActivityIndicatorService> methods

- (void)beginNetworkActivityForRequestor:(id)requestor {
	[self.requestors addObject:requestor];
	[self updateState];
}

- (void)endNetworkActivityForRequestor:(id)requestor {
	[self.requestors removeObject:requestor];
	[self updateState];
}

#pragma mark - Private methods

- (void)updateState {
	BOOL showNetworkActivityIndicator = [self.requestors count] > 0;
	[self.application setNetworkActivityIndicatorVisible:showNetworkActivityIndicator];
}

@end

#endif
