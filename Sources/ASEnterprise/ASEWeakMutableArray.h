//
//  ASEWeakMutableArray.h
//  ASEnterprise
//
//  Created by David Mitchell on 4/19/14.
//  Copyright (c) 2014 The App Studio LLC.
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

/** Mutable Array that weakly holds its contents */
@interface ASEWeakMutableArray<__covariant ObjectType> : NSObject <NSFastEnumeration>

// Public properties
@property (nonatomic) BOOL allowMutations;
@property (nonatomic, readonly) NSUInteger count;

// Public methods (matching NSMutableArray)
- (NSArray<ObjectType>*)allObjects;
+ (instancetype)arrayWithArray:(NSArray<ObjectType>*)array;
- (instancetype)initWithArray:(NSArray<ObjectType>*)array;
- (instancetype)initWithCapacity:(NSUInteger)capacity NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithObjects:(ObjectType)firstObj, ... NS_REQUIRES_NIL_TERMINATION;
- (void)addObject:(ObjectType)object;
- (BOOL)containsObject:(ObjectType)anObject;
- (ObjectType)objectAtIndex:(NSUInteger)index;
- (ObjectType)objectAtIndexedSubscript:(NSUInteger)idx NS_AVAILABLE(10_8, 6_0);
- (void)removeObject:(ObjectType)object;

// Specialized public methods
- (void)cleanWeakReferences;
- (NSUInteger)countByAddingObject:(ObjectType)object;
- (NSUInteger)countByRemovingObject:(ObjectType)object;

@end
