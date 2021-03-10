//
//  NSObject+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/10/13.
//  Copyright (c) 2013 The App Studio LLC. All rights reserved.
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

#import "NSObject+ASEnterpriseCategories.h"

@interface ASEObjectObserver : NSObject <ASEObjectObserver>

typedef void(^ASEObjectObserverFinishBlock)(ASEObjectObserver* observer);

@property (copy, nonatomic) ASEObjectObserverFinishBlock finishBlock;
@property (copy, nonatomic) ASEObserveKeyPathBlock observeBlock;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithObserveBlock:(ASEObserveKeyPathBlock)observeBlock finishBlock:(ASEObjectObserverFinishBlock)finishBlock NS_DESIGNATED_INITIALIZER;

@end

@implementation ASEObjectObserver

- (void)dealloc {
	[self finishObserving];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id>*)change context:(void*)context {
	self.observeBlock(object, change);
}

- (instancetype)initWithObserveBlock:(ASEObserveKeyPathBlock)observeBlock finishBlock:(ASEObjectObserverFinishBlock)finishBlock {
	NSParameterAssert(observeBlock && finishBlock);
	self = [super init];
	self.finishBlock = finishBlock;
	self.observeBlock = observeBlock;
	return self;
}

- (void)finishObserving {
	if (self.finishBlock) {
		// This releases the observed object (because we know "self" is in the finishBlock below)
		self.finishBlock(self);
		self.finishBlock = nil;
	}
}
@end

@implementation NSObject (ASEnterpriseCategories)

- (void)ase_Notify:(NSString*)notification {
	[self ase_Notify:notification withUserInfo:nil];
}

- (void)ase_Notify:(NSString*)notification withUserInfo:(NSDictionary*)userInfo {
	// Always makes sure that the notification is posted on the main thread
	dispatch_async(dispatch_get_main_queue(), ^{
		NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
		[defaultCenter postNotificationName:notification object:self userInfo:userInfo];
	});
}

- (id<ASEObjectObserver>)ase_ObserveKeyPath:(NSString*)keyPath withOptions:(NSKeyValueObservingOptions)options inBlock:(ASEObserveKeyPathBlock)block {
	NSObject* context = [[NSObject alloc] init]; // Guarantees no confusion with addObserver/removeObserver
	ASEObjectObserver* retVal = [[ASEObjectObserver alloc] initWithObserveBlock:block finishBlock:^(ASEObjectObserver* observer) {
		// We don't want self to dealloc before retVal, so capture self as self in this block
		[self removeObserver:observer forKeyPath:keyPath context:(__bridge void* _Nullable)context];
	}];
	[self addObserver:retVal forKeyPath:keyPath options:options context:(__bridge void* _Nullable)context];
	return retVal;
}

- (void)ase_SetSelector:(SEL)selector forNotification:(NSString*)notification {
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:notification object:nil];
	[defaultCenter addObserver:self selector:selector name:notification object:nil];
}

@end
