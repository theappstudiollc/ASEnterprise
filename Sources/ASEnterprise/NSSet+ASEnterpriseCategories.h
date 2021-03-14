//
//  NSSet+ASEnterpriseCategories.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSSet<ObjectType> (ASEnterpriseCategories)

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, BOOL* stop))block;
- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, BOOL* stop))block;
- (NSDictionary*)ase_DictionaryGroupedByKeyBlock:(__attribute__((noescape)) id<NSCopying> _Nullable (^)(ObjectType object))block;
- (nullable id)ase_ObjectMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object))block;
- (NSSet*)ase_SetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, BOOL* stop))block;
- (NSMutableSet*)ase_MutableSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, BOOL* stop))block;

@end

NS_ASSUME_NONNULL_END
