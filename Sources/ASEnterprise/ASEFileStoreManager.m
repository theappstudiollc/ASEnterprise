//
//  ASEFileStoreManager.m
//  ASEnterprise
//
//  Created by David Mitchell on 12/27/14.
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

#import "ASEFileStoreManager.h"

@interface ASEFileStoreManager ()

@property (nonatomic) NSString* applicationBundleString;

@end

@implementation ASEFileStoreManager
#pragma mark - Public methods

- (instancetype)initWithApplicationBundle:(NSBundle*)applicationBundle {
	self = [super init];
	_applicationBundleString = [(applicationBundle ?: [NSBundle bundleForClass:[self class]]) bundleIdentifier];
	return self;
}

- (BOOL)shouldExcludeForBackup:(ASEFileStoreDirectoryType)directoryType {
	switch (directoryType) {
		case DirectoryTypeApplicationSupport:
		case DirectoryTypeCache:
			return YES;
			
		default:
			return NO;
	}
}

#pragma mark - <ASEFileStoreService> methods

- (NSURL*)directoryURLForType:(ASEFileStoreDirectoryType)directoryType {
	switch (directoryType) {
		case DirectoryTypeApplicationSupport:
			return [self applicationSupportDirectory];
		case DirectoryTypeCache:
			return [self cacheDirectory];
		case DirectoryTypeUserDocuments:
			return [self userDocumentsDirectory];
		default:
			NSAssert(NO, @"Invalid directoryTypes not supported");
			return nil;
	}
}

- (BOOL)ensureDirectoryExistsForType:(ASEFileStoreDirectoryType)directoryType error:(NSError *__autoreleasing *)error {
	return [self ensureDirectoryExistsForType:directoryType withSubpath:nil error:error];
}

- (BOOL)ensureDirectoryExistsForType:(ASEFileStoreDirectoryType)directoryType withSubpath:(NSString*)subpath error:(NSError *__autoreleasing *)error {
	switch (directoryType) {
			
		case DirectoryTypeUserDocuments: // This is the only directory already created by the OS
			return YES;

		default: {
			NSFileCoordinator* coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
			NSURL* directoryURL = [self directoryURLForType:directoryType];
			if ([subpath length]) {
				directoryURL = [directoryURL URLByAppendingPathComponent:subpath isDirectory:YES];
			}
			__block BOOL success = NO;
			__weak typeof(self) weakSelf = self;
			[coordinator coordinateWritingItemAtURL:directoryURL options:NSFileCoordinatorWritingForDeleting error:error byAccessor:^(NSURL* writingURL) {
				NSFileManager* fileManager = [[NSFileManager alloc] init];
				if ([fileManager createDirectoryAtURL:writingURL withIntermediateDirectories:YES attributes:nil error:error]) {
					if (![weakSelf shouldExcludeForBackup:directoryType] ||
						[writingURL setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error]) {
						success = YES;
					}
				}
			}];
			if (error != NULL) {
				NSAssert(success ^ !!(*error), @"Cannot return success with error, or failure without: %d|%@", success, *error);
			}
			return success;
		}
	}
}

#pragma mark - Private methods

- (NSURL*)applicationSupportDirectory {
	NSURL* applicationSupportDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] firstObject];
	return [applicationSupportDirectoryURL URLByAppendingPathComponent:_applicationBundleString isDirectory:YES];
}

- (NSURL*)cacheDirectory {
	NSURL* cacheDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] firstObject];
	return [cacheDirectoryURL URLByAppendingPathComponent:_applicationBundleString isDirectory:YES];
}

- (NSURL*)userDocumentsDirectory {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
}

@end
