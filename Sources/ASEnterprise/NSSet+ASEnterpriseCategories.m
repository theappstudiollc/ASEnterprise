//
//  NSSet+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 7/7/13.
//  Copyright (c) 2013 The App Studio LLC.
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

#import "NSMutableDictionary+ASEnterpriseCategories.h"
#import "NSSet+ASEnterpriseCategories.h"

@implementation NSSet (ASEnterpriseCategories)

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, BOOL* _Nonnull))block {
	return [[self ase_MutableArrayMappedWithBlock:block] copy];
}

- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, BOOL* _Nonnull))block {
	NSParameterAssert(block);
	
	NSMutableArray* retVal = [[NSMutableArray alloc] initWithCapacity:[self count]];
	[self enumerateObjectsUsingBlock:^(id obj, BOOL* stop) {
		id blockResult = block(obj, stop);
		if (blockResult) {
			[retVal addObject:blockResult];
		}
	}];
	return retVal;
}

- (NSDictionary*)ase_DictionaryGroupedByKeyBlock:(__attribute__((noescape)) id<NSCopying> _Nullable (^)(id _Nonnull))block {
	NSParameterAssert(block);
	
	// Create mutable arrays and dictionaries with maximum possible capacity
	NSMutableDictionary* retVal = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	// First do the grouping
	[self enumerateObjectsUsingBlock:^(id object, BOOL* stop) {
		id key = block(object);
		if (key) {
			[[retVal ase_ObjectForKey:key withDefaultConstructBlock:^id {
				return [[NSMutableSet alloc] initWithCapacity:[self count]];
			}] addObject:object];
		}
	}];
	// Now convert all mutable sets into sets (releasing excess capacity)
	for (id key in [retVal allKeys]) {
		retVal[key] = [[NSSet alloc] initWithSet:retVal[key]];
	}
	// Finally, return a non-mutable dictionary (releasing excess capacity)
	return [retVal copy];
}

- (nullable id)ase_ObjectMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull))block {
	NSParameterAssert(block);
	
	__block id retVal = nil;
	[self enumerateObjectsUsingBlock:^(id object, BOOL* stop) {
		retVal = block(object);
		if (retVal) {
			*stop = YES;
		}
	}];
	return retVal;
}

- (NSSet*)ase_SetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, BOOL* _Nonnull))block {
	return [[self ase_MutableSetMappedWithBlock:block] copy];
}

- (NSMutableSet*)ase_MutableSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, BOOL* _Nonnull))block {
	NSParameterAssert(block);
	
	NSMutableSet* retVal = [[NSMutableSet alloc] initWithCapacity:[self count]];
	[self enumerateObjectsUsingBlock:^(id obj, BOOL* stop) {
		id blockResult = block(obj, stop);
		if (blockResult) {
			[retVal addObject:blockResult];
		}
	}];
	return retVal;
}

@end
