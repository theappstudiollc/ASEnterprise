//
//  NSOrderedSet+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 4/15/14.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSOrderedSet<ObjectType> (ASEnterpriseCategories)

- (NSOrderedSet*)ase_OrderedSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;
- (NSMutableOrderedSet*)ase_MutableOrderedSetMappedWithBlock:(__attribute__((noescape)) id _Nullable (^)(ObjectType object, NSUInteger index, BOOL* stop))block;

@end

NS_ASSUME_NONNULL_END