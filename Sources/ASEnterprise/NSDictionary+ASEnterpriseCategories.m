//
//  NSDictionary+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/9/13.
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

#import "NSDictionary+ASEnterpriseCategories.h"

@implementation NSDictionary (ASEnterpriseCategories)

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, id _Nonnull, BOOL* _Nonnull))block {
	return [[self ase_MutableArrayMappedWithBlock:block] copy];
}

- (NSDictionary*)ase_DictionaryByRemovingNulls {
	return [[self ase_MutableDictionaryByRemovingNulls] copy];
}

- (NSDictionary*)ase_DictionaryByReplacingKeysBlock:(__attribute__((noescape)) ASEReturnKeyType _Nullable (^)(id _Nonnull, id _Nonnull, BOOL* _Nonnull))block {
	return [[self ase_MutableDictionaryByReplacingKeysBlock:block] copy];
}

- (NSDictionary*)ase_DictionaryOverwrittenWithDictionary:(NSDictionary*)dictionary {
	NSMutableDictionary* mutableSelf = [NSMutableDictionary dictionaryWithDictionary:self];

	[dictionary enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL* _Nonnull stop) {
		mutableSelf[key] = obj;
	}];

	return [mutableSelf copy];
}

- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(id _Nonnull, id _Nonnull, BOOL* _Nonnull))block {
	NSParameterAssert(block);
	
	NSMutableArray* retVal = [[NSMutableArray alloc] initWithCapacity:[self count]];
	[self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL* stop) {
		id blockResult = block(key, obj, stop);
		if (blockResult) {
			[retVal addObject:blockResult];
		}
	}];
	return retVal;
}

- (NSMutableDictionary*)ase_MutableDictionaryByRemovingNulls {
	NSMutableDictionary* retVal = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	[self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id _Nonnull obj, BOOL* _Nonnull stop) {
		if ([key isKindOfClass:[NSNull class]] || [obj isKindOfClass:[NSNull class]]) return;
		retVal[key] = obj;
	}];
	return retVal;
}

- (NSMutableDictionary*)ase_MutableDictionaryByReplacingKeysBlock:(__attribute__((noescape)) ASEReturnKeyType _Nullable (^)(id _Nonnull, id _Nonnull, BOOL* _Nonnull))block {
	NSMutableDictionary* retVal = [[NSMutableDictionary alloc] initWithCapacity:self.count];
	[self enumerateKeysAndObjectsUsingBlock:^(id _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
		id blockResult = block(key, obj, stop);
		if (blockResult) {
			retVal[blockResult] = obj;
		}
	}];
	return retVal;
}

- (NSNumber*)ase_NumberOrNilForKey:(id)key {
	id retVal = self[key];
	return [retVal isKindOfClass:[NSNumber class]] ? retVal : nil;
}

- (NSString*)ase_StringOrNilForKey:(id)key {
	id retVal = self[key];
	return [retVal isKindOfClass:[NSString class]] ? retVal : nil;
}

@end
