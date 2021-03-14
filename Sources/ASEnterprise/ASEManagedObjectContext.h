//
//  ASEManagedObjectContext.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/3/16.
//  Copyright © 2016 The App Studio LLC.
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

@class ASECoreDataManager;

@interface ASEManagedObjectContext : NSManagedObjectContext

// Really make sure these properties will never conflict with NSManagedObjectContext
@property (nonatomic) BOOL ase_CatchesExceptions;
@property (weak, nonatomic) ASECoreDataManager* ase_CoreDataManager;
@property (nonatomic, getter=ase_IsReadOnlyContext) BOOL ase_ReadOnlyContext;
@property (nonatomic) NSUInteger ase_ServiceLogLevel;

@end
