//
//  NSManagedObject+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/31/13.
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

#import <libkern/OSAtomic.h>
#import "NSManagedObject+ASEnterpriseCategories.h"
#import "NSManagedObjectContext+ASEnterpriseCategories.h"
#import "NSManagedObjectID+ASEnterpriseCategories.h"

@implementation NSManagedObject (ASEnterpriseCategories)

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods -
////////////////////////////////////////////////////////////////////////////////

+ (NSFetchRequest*)ase_FetchRequestWithFormat:(NSString*)format, ... {
	NSString* entityName = NSStringFromClass([self class]);
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	if (format) {
		va_list args;
		va_start(args, format);
		[request setPredicate:[NSPredicate predicateWithFormat:format arguments:args]];
		va_end(args);
	}
	return request;
}

+ (NSFetchRequest*)ase_FetchRequestWithSubstitutionVariables:(NSDictionary*)substitutionVariables forPredicate:(NSPredicate*)predicate {
	NSString* entityName = NSStringFromClass([self class]);
	NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:entityName];
	if ([substitutionVariables count]) {
		[request setPredicate:[predicate predicateWithSubstitutionVariables:substitutionVariables]];
	} else {
		[request setPredicate:predicate];
	}
	return request;
}

- (instancetype)ase_ManagedObjectForContext:(NSManagedObjectContext*)context {
	if ([self.managedObjectContext isEqual:context]) {
		return self;
	}
	if ([self.managedObjectContext.persistentStoreCoordinator isEqual:context.persistentStoreCoordinator]) {
		return [self.objectID ase_ManagedObjectForContext:context];
	}
	return nil;
}

- (instancetype)ase_ManagedObjectForContext:(NSManagedObjectContext*)context mergeChanges:(BOOL)mergeChanges {
	if ([self.managedObjectContext isEqual:context]) {
		[context refreshObject:self mergeChanges:mergeChanges];
		return self;
	}
	if ([self.managedObjectContext.persistentStoreCoordinator isEqual:context.persistentStoreCoordinator]) {
		return [self.objectID ase_ManagedObjectForContext:context mergeChanges:mergeChanges];
	}
	return nil;
}

+ (instancetype)ase_ManagedObjectSingletonUsingContext:(NSManagedObjectContext*)context {
	return [self ase_ManagedObjectSingletonUsingContext:context withInitBlock:nil];
}

+ (instancetype)ase_ManagedObjectSingletonUsingContext:(NSManagedObjectContext*)context withInitBlock:(void(^)(id))block {
	// We're assuming that we're already inside a context's performBlock*
	static volatile int lockThread = 0; // used to synchronize access to "singletons"
	static NSMutableDictionary* singletons;
	
	NSString* className = NSStringFromClass([self class]);
	// Try to get the singleton from the singletons array
	while (!OSAtomicCompareAndSwapInt(0, 1, &lockThread));
	if (!singletons) {
		singletons = [NSMutableDictionary new];
	}
	NSManagedObject* singleton = singletons[className];
	OSAtomicCompareAndSwapInt(1, 0, &lockThread);
	// Finished with the critical section

	// Is the found object part of the requested context?
	if (![singleton.managedObjectContext isEqual:context]) {
		// Are the persistentStoreCoordinators the same?
		if ([singleton.managedObjectContext.persistentStoreCoordinator isEqual:context.persistentStoreCoordinator]) {
			// Grab the singleton from the new context
			NSManagedObjectID* objectID = singleton.objectID;
			singleton = [context objectRegisteredForID:objectID];
		}
	}
	if (!singleton) {
		// Fetch from Core Data
		NSFetchRequest* request = [NSFetchRequest fetchRequestWithEntityName:className];
		[request setFetchLimit:1];
		NSError* error = nil;
		singleton = [[context executeFetchRequest:request error:&error] firstObject];
		if (!singleton) { // && !error)?
			singleton = [context ase_InsertNewObjectForEntityForName:className];
		}
		// Now initialize the object for the first time
		if (block) {
			block(singleton);
		}
		// synchronize access to singletons again
		while (!OSAtomicCompareAndSwapInt(0, 1, &lockThread));
		singletons[className] = singleton;
		OSAtomicCompareAndSwapInt(1, 0, &lockThread);
		// Finished with the critical section
	}
	return singleton;
}

////////////////////////////////////////////////////////////////////////////////
@end
