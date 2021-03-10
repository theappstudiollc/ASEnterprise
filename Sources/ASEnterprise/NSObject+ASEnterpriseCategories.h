//
//  NSObject+ASEnterpriseCategories.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASEObjectObserver <NSObject>
/** Call this method to finish observing the object from ase_ObserveKeyPath:withOptions:inBlock: */
- (void)finishObserving;
@end

@interface NSObject (ASEnterpriseCategories)

/** Note that the thread upon which this block is called is unspecified. */
typedef void(^ASEObserveKeyPathBlock)(id object, NSDictionary<NSKeyValueChangeKey,id>* change);

/** Asynchronously posts the notification on the main thread using the receiver as the notification object. 
 NOTE: This is asynchronous to ensure consistent behavior no matter what thread the method is called from.
 If you need synchronous behavior, just use the NSNoficationCenter methods yourself. */
- (void)ase_Notify:(NSNotificationName)notification;
/** Asynchronously posts the notification on the main thread using the receiver as the notification object.
 NOTE: This is asynchronous to ensure consistent behavior no matter what thread the method is called from.
 If you need synchronous behavior, just use the NSNoficationCenter methods yourself. */
- (void)ase_Notify:(NSNotificationName)notification withUserInfo:(nullable NSDictionary*)userInfo;
/** Registers a block to observe changes to the receiver at the specified keyPath. If you do not save the return value the block may be deallocated prematurely. */
- (id<ASEObjectObserver>)ase_ObserveKeyPath:(NSString*)keyPath withOptions:(NSKeyValueObservingOptions)options inBlock:(ASEObserveKeyPathBlock)block;
/** Registers a selector to listen to a notification, while also preventing double-registering. */
- (void)ase_SetSelector:(SEL)selector forNotification:(NSNotificationName)notification;

@end

NS_ASSUME_NONNULL_END
