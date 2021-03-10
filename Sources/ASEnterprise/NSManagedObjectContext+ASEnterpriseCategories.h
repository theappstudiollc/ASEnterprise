//
//  NSManagedObjectContext+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 12/25/13.
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

@interface NSManagedObjectContext (ASEnterpriseCategories)

- (NSArray*)ase_FetchAllOfType:(Class)managedObjectClass withSortDescriptors:(NSArray*)sortDescriptors;
- (id)ase_InsertNewObjectForEntityForName:(NSString*)className;
- (id)ase_PerformBlockAndReturn:(__attribute__((noescape)) id(^)(void))block;
- (BOOL)ase_SaveIfChanges:(NSError**)error;

@end
