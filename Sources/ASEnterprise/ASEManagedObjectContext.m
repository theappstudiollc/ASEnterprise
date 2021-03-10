//
//  ASEManagedObjectContext.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/3/16.
//  Copyright © 2016 The App Studio LLC. All rights reserved.
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

#import "ASECoreDataManager.h"
#import "ASEManagedObjectContext.h"
#import "NSError+ASEnterpriseCategories.h"

@interface ASECoreDataManager (ASEProtectedMethods) // Expose private methods to this class

- (void)saveContext:(NSManagedObjectContext*)context producedError:(NSError*)error;
- (void)saveContext:(NSManagedObjectContext*)context producedException:(NSException*)exception;

@end

@implementation ASEManagedObjectContext

- (void)dealloc {
	if (self.ase_ServiceLogLevel > 0) {
		NSLog(@"%@ %@", [self debugDescription], NSStringFromSelector(_cmd));
	}
}

- (NSString*)debugDescription {
	if (self.ase_ServiceLogLevel > 0) {
		NSString* readOnly = self.ase_ReadOnlyContext ? @":ReadOnly" : @"";
		if (self.concurrencyType == NSMainQueueConcurrencyType) {
			return [NSString stringWithFormat:@"%@<%lu:MainThread%@>", [self class], (unsigned long)self.hash, readOnly];
		}
		return [NSString stringWithFormat:@"%@<%lu%@>", [self class], (unsigned long)self.hash, readOnly];
	}
	return [super debugDescription];
}

- (BOOL)save:(NSError* _Nullable __autoreleasing*)error {
	if (self.ase_IsReadOnlyContext) {
		if (error != NULL) *error = [NSError ase_ErrorWithCode:ASEnterpriseErrorCodeReadOnlyContextAttemptedSave];
		return NO;
	}
	BOOL(^saveBlock)(void) = ^BOOL(void) {
		NSError* saveError = nil;
		if ([super save:&saveError]) {
			return YES;
		}
		if (error != NULL) {
			*error = saveError;
		}
		[self.ase_CoreDataManager saveContext:self producedError:saveError];
		return NO;
	};
	
	if (self.ase_CatchesExceptions) {
		@try {
			return saveBlock();
		} @catch (NSException* exception) {
			[self.ase_CoreDataManager saveContext:self producedException:exception];
		}
	} else {
		return saveBlock();
	}
}

@end
