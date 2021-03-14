//
//  NSArray+ASEnterpriseCategories.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray<ObjectType> (ASEnterpriseCategories)

+ (NSArray*)ase_ArrayWithRange:(NSRange)range mappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(NSUInteger index, BOOL* stop))block;
+ (NSMutableArray*)ase_MutableArrayWithRange:(NSRange)range mappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(NSUInteger index, BOOL* stop))block;

- (NSArray*)ase_ArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;
- (NSDictionary*)ase_DictionaryGroupedByKeyBlock:(__attribute__((noescape)) id<NSCopying> _Nullable (^)(ObjectType object, NSUInteger index))block;
- (NSMutableArray*)ase_MutableArrayMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;
- (NSMutableSet*)ase_MutableSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;
- (NSSet*)ase_SetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;
- (nullable id)ase_ObjectOrNilAtIndex:(NSUInteger)index;
- (nullable id)ase_ObjectMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index))block;

@end

NS_ASSUME_NONNULL_END
