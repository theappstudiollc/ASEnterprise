//
//  NSManagedObjectContext+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 12/25/13.
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

#import "NSManagedObject+ASEnterpriseCategories.h"
#import "NSManagedObjectContext+ASEnterpriseCategories.h"

@implementation NSManagedObjectContext (ASEnterpriseCategories)

- (NSArray*)ase_FetchAllOfType:(Class)managedObjectClass withSortDescriptors:(NSArray*)sortDescriptors {
	NSParameterAssert([managedObjectClass isSubclassOfClass:[NSManagedObject class]]);
	NSFetchRequest* request = [managedObjectClass ase_FetchRequestWithFormat:nil];
	[request setSortDescriptors:sortDescriptors];
	NSError* error = nil;
	NSArray* retVal = [self executeFetchRequest:request error:&error];
	NSAssert(!error, @"Error fetching request (%@): %@", request, error);
	return retVal;
}

- (id)ase_InsertNewObjectForEntityForName:(NSString*)className {
	return [NSEntityDescription insertNewObjectForEntityForName:className inManagedObjectContext:self];
}

- (id)ase_PerformBlockAndReturn:(__attribute__((noescape)) id(^)(void))block {
	NSParameterAssert(block);
	
	__block id retVal = nil;
	[self performBlockAndWait:^{
		retVal = block();
	}];
	return retVal;
}

- (BOOL)ase_SaveIfChanges:(NSError* __autoreleasing *)error {
	return ![self hasChanges] || [self save:error];
}

@end
