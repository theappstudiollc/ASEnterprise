//
//  ASEFileStoreManager.h
//  ASEnterprise
//
//  Created by David Mitchell on 12/27/14.
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

NS_ASSUME_NONNULL_BEGIN

/** A service for working with file stores on iOS */
@protocol ASEFileStoreService

/**
 Enumeration for directory types supported by this class.
	- The Application Support directory: Library/Application Support/your.bundle.identifier
	- The Cache directory: Library/Caches/your.bundle.identifier
	- The User Documents directory: Documents
	- A starting point for custom application types defined by subclasses
 
 Use 'static enum ASEFileStoreDirectoryType DirectoryTypeYourSubclassCustomType = DirectoryTypeApplicationReserved + x;' to extend with your own types in Objective C.
 
 DO NOT depend on these enumerations staying the same across releases of this library (i.e. do not persist any variables of this type in user settings or in databases).
 */
typedef NS_ENUM(NSInteger, ASEFileStoreDirectoryType) {
	DirectoryTypeApplicationSupport = 0,
	DirectoryTypeCache,
	DirectoryTypeUserDocuments,
	/** Reserved for subclasses. 8 are explicity called out to prevent warnings for Objective-C-based customizations */
	DirectoryTypeApplicationReserved = 128,
	DirectoryTypeApplicationReserved1,
	DirectoryTypeApplicationReserved2,
	DirectoryTypeApplicationReserved3,
	DirectoryTypeApplicationReserved4,
	DirectoryTypeApplicationReserved5,
	DirectoryTypeApplicationReserved6,
	DirectoryTypeApplicationReserved7,
	DirectoryTypeApplicationReservedEnd = 255
};

/**
 Returns the NSURL for the provided directoryType. Behavior is undefined for unsupported ASEFileStoreDirectoryTypes.

 @param directoryType The desired ASEFileStoreDirectoryType
 @return Tthe NSURL for the provided directoryType. Behavior is undefined for unsupported ASEFileStoreDirectoryTypes
 */
- (NSURL*)directoryURLForType:(ASEFileStoreDirectoryType)directoryType NS_SWIFT_NAME(directoryUrl(for:));

/**
 Ensures the directory for the provided directoryType exists on the file system.

 @param directoryType The ASEFileStoreDirectoryType
 @param error NSError describing the error if the operation fails
 @return YES if the operation succeeds. NO otherwise
 */
- (BOOL)ensureDirectoryExistsForType:(ASEFileStoreDirectoryType)directoryType error:(NSError**)error NS_SWIFT_NAME(ensureDirectoryExists(for:));

/**
 Ensures the directory for the provided directoryType exists on the file system, also including an optional subpath.

 @param directoryType The ASEFileStoreDirectoryType
 @param subpath An optional subpath beneath the directoryType
 @param error NSError describing the error if the operation fails
 @return YES if the operation succeeds. NO otherwise
 */
- (BOOL)ensureDirectoryExistsForType:(ASEFileStoreDirectoryType)directoryType withSubpath:(nullable NSString*)subpath error:(NSError**)error NS_SWIFT_NAME(ensureDirectoryExists(for:subpath:));

@end

/**
 Ready-to-use implementation of the ASEFileStoreService.
 
 Can easily be subclassed to support additional ASEFileStoreDirectoryTypes through the use of the DirectoryTypeApplicationReserved enum value.
 */
@interface ASEFileStoreManager : NSObject <ASEFileStoreService> {
	@protected
	NSString* _Nullable _applicationBundleString;
}

/** Use initWithApplicationBundle: instead */
- (instancetype)init NS_UNAVAILABLE;

/**
 Initializes a new File Store Manager with the application's bundle.

 @param applicationBundle The application's main bundle.
 @return A new File Store Manager for use by the application.
 */
- (instancetype)initWithApplicationBundle:(nullable NSBundle*)applicationBundle NS_DESIGNATED_INITIALIZER;

@end

@interface ASEFileStoreManager (Subclassing)

/**
 Returns whether the provided directoryType should be excluded for backup. Used by ensureDirectoryExistsForType:withSubpath:error:
 
 Override to add support for your own ApplicationReserved types.
 */
- (BOOL)shouldExcludeForBackup:(ASEFileStoreDirectoryType)directoryType;

@end

NS_ASSUME_NONNULL_END
