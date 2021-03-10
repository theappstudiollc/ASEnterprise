//
//  NSOperationQueue+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 2/4/14.
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

#import "NSOperationQueue+ASEnterpriseCategories.h"

@implementation NSOperationQueue (ASEnterpriseCategories)

- (NSOperation*)ase_OperationAddedWithDependencies:(NSArray<NSOperation*>*)dependencies withBlock:(ASEBlockOperationBlock)block {
	NSParameterAssert(block);
	
	NSBlockOperation* retVal = [NSBlockOperation ase_BlockOperationWithBlock:block];
	for (NSOperation* dependency in dependencies) {
		[retVal addDependency:dependency];
	}
	[self addOperation:retVal];

	return retVal;
}

@end
