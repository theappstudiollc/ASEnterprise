//
//  NSDictionary+ASEnterpriseCategories.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary<KeyType, ObjectType> (ASEnterpriseCategories)

typedef id ASEReturnKeyType;

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(KeyType key, ObjectType object, BOOL* stop))block;
- (NSDictionary<KeyType, ObjectType>*)ase_DictionaryByRemovingNulls;
- (NSDictionary<ASEReturnKeyType, ObjectType>*)ase_DictionaryByReplacingKeysBlock:(__attribute__((noescape)) ASEReturnKeyType _Nullable (^)(KeyType key, ObjectType object, BOOL* stop))block;
- (NSDictionary<KeyType, ObjectType>*)ase_DictionaryOverwrittenWithDictionary:(NSDictionary<KeyType, ObjectType>*)dictionary;
- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(KeyType key, ObjectType object, BOOL* stop))block;
- (NSMutableDictionary<KeyType, ObjectType>*)ase_MutableDictionaryByRemovingNulls;
- (NSMutableDictionary<ASEReturnKeyType, ObjectType>*)ase_MutableDictionaryByReplacingKeysBlock:(__attribute__((noescape)) ASEReturnKeyType _Nullable (^)(KeyType key, ObjectType object, BOOL* stop))block;
- (nullable NSNumber*)ase_NumberOrNilForKey:(KeyType)key;
- (nullable NSString*)ase_StringOrNilForKey:(KeyType)key;

@end

NS_ASSUME_NONNULL_END