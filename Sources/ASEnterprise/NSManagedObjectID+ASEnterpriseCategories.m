//
//  NSManagedObjectID+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/24/14.
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

#import "NSManagedObjectID+ASEnterpriseCategories.h"

@implementation NSManagedObjectID (ASEnterpriseCategories)

- (NSManagedObject*)ase_ManagedObjectForContext:(NSManagedObjectContext*)context {
	NSError* error = nil;
	NSManagedObject* retVal = [context existingObjectWithID:self error:&error];
	NSAssert(!error, @"error obtaining existing object with %@: %@", self, error);
	return retVal;
}

- (NSManagedObject*)ase_ManagedObjectForContext:(NSManagedObjectContext*)context mergeChanges:(BOOL)mergeChanges {
	NSManagedObject* retVal = [self ase_ManagedObjectForContext:context];
	[context refreshObject:retVal mergeChanges:mergeChanges];
	return retVal;
}

@end
