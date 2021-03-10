//
//  UIApplication+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 8/16/16.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_WATCH)

#import "UIApplication+ASEnterpriseCategories.h"

@implementation UIApplication (ASEnterpriseCategories)
#pragma mark - Public methods

- (void)ase_StartBackgroundTask:(ASEBackgroundTaskBlock)task withName:(NSString*)name completion:(ASEBackgroundTaskCompleted)completion {
	NSParameterAssert(task != NULL);
	__block UIBackgroundTaskIdentifier taskIdentifier = UIBackgroundTaskInvalid;
	taskIdentifier = [self beginBackgroundTaskWithName:name expirationHandler:^{
		if (taskIdentifier == UIBackgroundTaskInvalid) return;
		taskIdentifier = UIBackgroundTaskInvalid;
		if (completion) completion(YES);
	}];
	task(self.backgroundTimeRemaining, ^{
		if (taskIdentifier == UIBackgroundTaskInvalid) return;
		taskIdentifier = UIBackgroundTaskInvalid;
		if (completion) completion(NO);
		[self endBackgroundTask:taskIdentifier];
	});
}

@end

#endif
