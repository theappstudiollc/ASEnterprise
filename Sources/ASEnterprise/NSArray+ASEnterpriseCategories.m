//
//  NSArray+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/10/13.
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

#import "NSArray+ASEnterpriseCategories.h"
#import "NSDictionary+ASEnterpriseCategories.h"
#import "NSMutableDictionary+ASEnterpriseCategories.h"

@implementation NSArray (ASEnterpriseCategories)

+ (NSArray*)ase_ArrayWithRange:(NSRange)range mappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(NSUInteger, BOOL* _Nonnull))block {
	return [[self ase_MutableArrayWithRange:range mappedWithBlock:block] copy];
}

+ (NSMutableArray*)ase_MutableArrayWithRange:(NSRange)range mappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(NSUInteger, BOOL* _Nonnull))block {
	NSParameterAssert(block);
	NSMutableArray* retVal = [NSMutableArray arrayWithCapacity:range.length];
	BOOL stop = NO;
	for (NSUInteger index = range.location; index < range.location + range.length; index++) {
		id converted = block(index, &stop);
		if (converted) {
			[retVal addObject:converted];
		}
		if (stop) break;
	}
	return retVal;
}

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, NSUInteger, BOOL* _Nonnull))block {
	return [[self ase_MutableArrayMappedWithBlock:block] copy];
}

- (NSDictionary*)ase_DictionaryGroupedByKeyBlock:(__attribute__((noescape)) id<NSCopying> _Nullable (^)(id _Nonnull, NSUInteger))block {
	NSParameterAssert(block);
	
	// Create mutable arrays and dictionaries with maximum possible capacity
	NSMutableDictionary* retVal = [[NSMutableDictionary alloc] initWithCapacity:[self count]];
	// First do the grouping
	[self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop) {
		id key = block(object, index);
		if (key) {
			[[retVal ase_ObjectForKey:key withDefaultConstructBlock:^id {
				return [[NSMutableArray alloc] initWithCapacity:[self count]];
			}] addObject:object];
		}
	}];
	// Now convert all mutable arrays into arrays (releasing excess capacity)
	for (id key in [retVal allKeys]) {
		retVal[key] = [[NSArray alloc] initWithArray:retVal[key]];
	}
	// Finally, return a non-mutable dictionary (releasing excess capacity)
	return [retVal copy];
}

- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, NSUInteger, BOOL* _Nonnull))block {
	NSParameterAssert(block);

	NSMutableArray* retVal = [[NSMutableArray alloc] initWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop) {
		id converted = block(object, index, stop);
		if (converted) {
			[retVal addObject:converted];
		}
	}];
	return retVal;
}

- (NSMutableSet*)ase_MutableSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, NSUInteger, BOOL* _Nonnull))block {
	NSParameterAssert(block);
	
	NSMutableSet* retVal = [[NSMutableSet alloc] initWithCapacity:self.count];
	[self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop) {
		id converted = block(object, index, stop);
		if (converted) {
			[retVal addObject:converted];
		}
	}];
	return retVal;
}

- (NSSet*)ase_SetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, NSUInteger, BOOL* _Nonnull))block {
	return [[self ase_MutableSetMappedWithBlock:block] copy];
}

- (nullable id)ase_ObjectOrNilAtIndex:(NSUInteger)index {
	return [self count] > index ? self[index] : nil;
}

- (nullable id)ase_ObjectMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, NSUInteger))block {
	NSParameterAssert(block);
	
	__block id retVal = nil;
	[self enumerateObjectsUsingBlock:^(id object, NSUInteger index, BOOL* stop) {
		retVal = block(object, index);
		if (retVal) {
			*stop = YES;
		}
	}];
	return retVal;
}

@end
