//
//  UIApplication+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 8/16/16.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_WATCH)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIApplication (ASEnterpriseCategories)

/** A block that must be called when the background task is complete. This should be called on the main thread only. */
typedef void(^ASEBackgroundTaskNotifyCompletion)(void);
/** The block for the task. The time remaining, decided by the Operating System, is also provided. When your task is complete (asynchronously or synchronously) you should invoke the notifyCompletion block. */
typedef void(^ASEBackgroundTaskBlock)(NSTimeInterval timeRemaining, ASEBackgroundTaskNotifyCompletion notifyCompletion);
/** A block that will be called when the task is finished, either by iself or forced by the Operating System, which will be denoted by the value of taskExpired. */
typedef void(^ASEBackgroundTaskCompleted)(BOOL taskExpired);

/** Starts a background task block with a provided name. Upon completion (whether expired by the Operation System or notified by the background task block, the supplied completion handler is called. */
- (void)ase_StartBackgroundTask:(ASEBackgroundTaskBlock)task withName:(nullable NSString*)name completion:(nullable ASEBackgroundTaskCompleted)completion;

@end

NS_ASSUME_NONNULL_END

#endif
