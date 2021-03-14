//
//  NSBlockOperation+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 5/25/15.
//  Copyright (c) 2015 The App Studio LLC.
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

#import "NSBlockOperation+ASEnterpriseCategories.h"

@implementation NSBlockOperation (ASEnterpriseCategories)

+ (instancetype)ase_BlockOperationWithBlock:(ASEBlockOperationBlock)block {
	NSParameterAssert(block);
	
	NSBlockOperation* retVal = [self new];
	__weak NSBlockOperation* weakOperation = retVal;
	[retVal addExecutionBlock:^{
		__strong NSBlockOperation* strongOperation = weakOperation;
		@autoreleasepool {
			block(strongOperation);
		}
	}];
	return retVal;
}

@end
