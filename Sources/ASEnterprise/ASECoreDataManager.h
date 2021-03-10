//
//  ASECoreDataManager.h
//  ASEnterprise
//
//  Created by David Mitchell on 4/20/14.
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

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ASECoreDataManagerDelegate <NSObject>

typedef NS_ENUM(NSInteger, ASECoreDataStackConfiguration) {
	ASECoreDataStackConfigurationMultiCoordinatorWithBlockingMergeContexts = 0, // This is the default, and the only usable option with NSFetchedResultsController in iOS 9.x and lower
	ASECoreDataStackConfigurationSingleCoordinatorWithBlockingMergeContexts,
	ASECoreDataStackConfigurationSingleCoordinatorWithAsynchronousMergeContexts NS_AVAILABLE(10_11,9_0),
};

@required
/** Returns one or more data model URLs to be loaded by the manager */
- (NSArray<NSURL*>*)modelURLs;
/** Returns the persistent store URL for the specified configuration. A nil configuration means the "default" configuration. A nil value is appropriate only for InMemory persistent store types */
- (nullable NSURL*)persistentStoreUrlForConfiguration:(nullable NSString*)configuration;

@optional
- (NSUInteger)backgroundContextPoolSize;
/** Provides an optional list of configurations, if there are more than just the "default" configuration */
- (nullable NSArray<NSString*>*)configurations;
/** Provides an opportunity to initialize a newly created context. For example, to set the mergePolicy or stalenessInterval. */
- (void)initializeContext:(NSManagedObjectContext*)context asReadOnly:(BOOL)readOnly;
/** Provides some persistent store coordinator options based on the configuration */
- (nullable NSDictionary*)persistentStoreOptionsForConfiguration:(nullable NSString*)configuration;
/** Persistent Store Type: NSSQLiteStoreType, NSBinaryStoreType, NSInMemoryStoreType */
- (NSString*)persistentStoreTypeForConfiguration:(nullable NSString*)configuration;
/** Provides an opportunity to handle errors produced while saving the context */
- (void)saveContext:(NSManagedObjectContext*)context producedError:(NSError*)error;
/** Provides an opportunity to handle exceptions produced while saving the context */
- (void)saveContext:(NSManagedObjectContext*)context producedException:(NSException*)exception;
/** Specifies the stack configuration, which affects how a context saves its changes and how other contexts are updated */
- (ASECoreDataStackConfiguration)stackConfiguration;

@end

@protocol ASECoreDataService
/** Uses NSManagedObjectContext's performBlock call, which includes a built-in autorelease pool and a call to processPendingChanges. Unless you are calling from the main thread, you cannot access any resulting NSManagedObjects and their properties outside of the block. */
- (void)performBlock:(void(^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(perform(_:));
/** Uses NSManagedObjectContext's performBlockAndWait call. Client code may wish to use an autorelease pool inside the block. */
- (void)performBlockAndWait:(__attribute__((noescape)) void(^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(performAndWait(_:));
/** Uses NSManagedObjectContext's performBlockAndWait call and assigns the result to a __block variable. Client code may wish to use an autorelease pool inside the block. */
- (id _Nullable)performBlockAndReturn:(__attribute__((noescape)) id _Nullable (^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(performAndReturn(_:));
/** Uses a dedicated NSManagedObjectContext for readonly access within a performBlock call. An attempt to save the context will fail with an error. Since the supplied ManagedObjectContext may have been used by prior calls to this method, you may want to call -refreshAllObjects to clear any unintended changes, if it is important that those changes are not used. */
- (void)performReadOnly:(BOOL)readOnly withBlock:(void(^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(perform(readOnly:_:));
/** Uses a dedicated NSManagedObjectContext for readonly access within a performBlockAndWait call. Client code may wish to use an autorelease pool inside the block. Since the supplied ManagedObjectContext may have been used by prior calls to this method, you may want to call -refreshAllObjects to clear any unintended changes, if it is important that those changes are not used. */
- (void)performReadOnly:(BOOL)readOnly withBlockAndWait:(__attribute__((noescape)) void(^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(performAndWait(readOnly:_:));
/** Uses a dedicated NSManagedObjectContext for readonly access within a performBlockAndWait call, and assigns the result to a __block variable. Client code may wish to use an autorelease pool inside the block. Since the supplied ManagedObjectContext may have been used by prior calls to this method, you may want to call -refreshAllObjects to clear any unintended changes, if it is important that those changes are not used. ALSO IMPORTANT: If this method is called in the main thread, NSManagedObjects should not be directly returned to the caller, as they are unusable in the main thread. */
- (id _Nullable)performReadOnly:(BOOL)readOnly withBlockAndReturn:(__attribute__((noescape)) id _Nullable (^)(NSManagedObjectContext* context))block NS_SWIFT_NAME(performAndReturn(readOnly:_:));

@end

@interface ASECoreDataManager : NSObject <ASECoreDataService>

@property (weak, nonatomic) id<ASECoreDataManagerDelegate> _Nullable delegate;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithDelegate:(nullable id<ASECoreDataManagerDelegate>)delegate NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
