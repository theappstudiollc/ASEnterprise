//
//  NSManagedObject+ASEnterpriseCategories.h
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

#import <CoreData/CoreData.h>

@interface NSManagedObject (ASEnterpriseCategories)

+ (NSFetchRequest*)ase_FetchRequestWithFormat:(NSString*)format, ...;
+ (NSFetchRequest*)ase_FetchRequestWithSubstitutionVariables:(NSDictionary*)substitutionVariables forPredicate:(NSPredicate*)predicate;
- (instancetype)ase_ManagedObjectForContext:(NSManagedObjectContext*)context;
- (instancetype)ase_ManagedObjectForContext:(NSManagedObjectContext*)context mergeChanges:(BOOL)mergeChanges;
/** @deprecated This is not an effective design pattern. Please consider an alternative. */
+ (instancetype)ase_ManagedObjectSingletonUsingContext:(NSManagedObjectContext*)context __attribute__((deprecated));
/** @deprecated This is not an effective design pattern. Please consider an alternative. */
+ (instancetype)ase_ManagedObjectSingletonUsingContext:(NSManagedObjectContext*)context withInitBlock:(void(^)(id singleton))block __attribute__((deprecated));

@end
