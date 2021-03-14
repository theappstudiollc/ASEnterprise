//
//  ASECoreDataManager.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/20/14.
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

#import "ASECoreDataManager.h"
#import "ASEnterprise-Common.h"
#import "ASEManagedObjectContext.h"
#import "ASEWeakMutableArray.h"
#import <libkern/OSAtomic.h>
#import "NSArray+ASEnterpriseCategories.h"
#import "NSManagedObjectContext+ASEnterpriseCategories.h"
#import "NSManagedObjectID+ASEnterpriseCategories.h"

/** Environment variable used in Xcode for debugging. Currently, values of 0 through 2 are supported. */
static NSString* const kASE_COREDATASERVICE_LOGLEVEL = @"ASE_COREDATASERVICE_LOGLEVEL";

@interface ASECoreDataManager ()

@property (nonatomic) NSPersistentStoreCoordinator* backgroundCoordinator;
@property (nonatomic) NSUInteger contextPoolSize;
@property (nonatomic) ASEWeakMutableArray<ASEManagedObjectContext*>* contexts;
@property (nonatomic) NSManagedObjectModel* model;
@property (nonatomic) NSPersistentStoreCoordinator* mainCoordinator;
@property (weak, nonatomic) ASEManagedObjectContext* mainThreadContext; // Main is a special context
@property (nonatomic) id<NSObject> mocChangedObserver;
@property (weak, nonatomic) ASEManagedObjectContext* readOnlyContext;
@property (nonatomic) NSOperationQueue* saveContextQueue;
@property (nonatomic) NSUInteger serviceLogLevel;
@property volatile int lockThreadCoordinator;

@end

@implementation ASECoreDataManager

static NSString* const kASE_THREAD_MOC_KEY = @"ASE_Thread_ManagedObjectContext";
static NSString* const kASE_THREAD_ROMOC_KEY = @"ASE_Thread_ReadOnlyManagedObjectContext";

#pragma mark - NSObject overrides

- (void)dealloc {
	[[[NSThread currentThread] threadDictionary] removeObjectForKey:kASE_THREAD_MOC_KEY];
	[[[NSThread currentThread] threadDictionary] removeObjectForKey:kASE_THREAD_ROMOC_KEY];
	[[NSNotificationCenter defaultCenter] removeObserver:self.mocChangedObserver];
}

#pragma mark - Public properties and methods

- (void)setDelegate:(id<ASECoreDataManagerDelegate>)delegate {
	if (_delegate == delegate || [delegate isEqual:_delegate]) return;
	_delegate = delegate;
	[self setupManagedObjectContexts];
}

- (instancetype)initWithDelegate:(id<ASECoreDataManagerDelegate>)delegate {
	self = [super init];
	self.serviceLogLevel = (NSUInteger)MAX(0, [[[NSProcessInfo processInfo] environment][kASE_COREDATASERVICE_LOGLEVEL] integerValue]);
	self.delegate = delegate;
	return self;
}

#pragma mark - Private properties and methods

- (NSPersistentStoreCoordinator*)backgroundCoordinator {
	while (!OSAtomicCompareAndSwapInt(0, 1, &_lockThreadCoordinator)) {};
	if (!_backgroundCoordinator) {
		_backgroundCoordinator = [self generateCoordinator];
	}
	if (!OSAtomicCompareAndSwapInt(1, 0, &_lockThreadCoordinator)) {
		_lockThreadCoordinator = 0;
	}
	return _backgroundCoordinator;
}

- (NSManagedObjectContext*)contextForThread:(NSThread*)thread readOnly:(BOOL)readOnly {
	if (readOnly) {
		return [self readOnlyContextForThread:thread];
	}
	NSManagedObjectContextConcurrencyType concurrencyType = [thread isMainThread] ? NSMainQueueConcurrencyType : NSPrivateQueueConcurrencyType;
	return [self contextForThread:thread withConcurrencyType:concurrencyType];
}

- (NSManagedObjectContext*)contextForThread:(NSThread*)thread withConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType {
	ASEManagedObjectContext* retVal = [thread threadDictionary][kASE_THREAD_MOC_KEY];
	if (!retVal) {
		NSAssert(concurrencyType == [NSThread isMainThread] ? NSMainQueueConcurrencyType : NSPrivateQueueConcurrencyType, @"Invalid concurrency type request");
		if (concurrencyType == NSMainQueueConcurrencyType || _contextPoolSize == 0) {
			retVal = self.mainThreadContext ?: [self contextWithConcurrencyType:NSMainQueueConcurrencyType readOnly:NO];
			self.mainThreadContext = retVal;
		} else {
			@synchronized(_contexts) {
				if ([_contexts count] >= _contextPoolSize) {
					// Use a round-robin pointer to return a context
					static NSUInteger indexPointer = 0;
					for (NSUInteger attempts = 0; attempts < _contextPoolSize; attempts++) {
						indexPointer = ((indexPointer + 1) % _contextPoolSize);
						retVal = _contexts[indexPointer]; // ASWeakMutableArray may return nil
						if (retVal && retVal.concurrencyType == concurrencyType) {
							break;
						} else {
							retVal = nil;
						}
					}
				}
				if (!retVal) {
					retVal = [self contextWithConcurrencyType:concurrencyType readOnly:NO];
					[_contexts addObject:retVal];
				}
				NSAssert([_contexts count] <= _contextPoolSize, @"Invalid pool size");
			}
		}
		[thread threadDictionary][kASE_THREAD_MOC_KEY] = retVal;
	}
	return retVal;
}

- (ASEManagedObjectContext*)contextWithConcurrencyType:(NSManagedObjectContextConcurrencyType)concurrencyType readOnly:(BOOL)readOnly {
	ASEManagedObjectContext* retVal = [[ASEManagedObjectContext alloc] initWithConcurrencyType:concurrencyType];
	retVal.ase_CatchesExceptions = [self.delegate respondsToSelector:@selector(saveContext:producedException:)];
	retVal.ase_CoreDataManager = self;
	if ([self.delegate respondsToSelector:@selector(initializeContext:asReadOnly:)]) {
		[self.delegate initializeContext:retVal asReadOnly:readOnly];
	}
	NSAssert(!retVal.persistentStoreCoordinator, @"delegate is not allowed to assign a persistentStoreCoordinator");
	NSAssert(!retVal.parentContext, @"delegate is not allowed to assign a parentContext");
	if (concurrencyType == NSMainQueueConcurrencyType && !readOnly) {
		retVal.persistentStoreCoordinator = self.mainCoordinator;
	} else if ([self.delegate respondsToSelector:@selector(stackConfiguration)] && [self.delegate stackConfiguration] != ASECoreDataStackConfigurationMultiCoordinatorWithBlockingMergeContexts) {
		retVal.persistentStoreCoordinator = self.mainCoordinator;
	} else {
		retVal.persistentStoreCoordinator = self.backgroundCoordinator;
	}
	retVal.ase_ReadOnlyContext = readOnly;
	retVal.ase_ServiceLogLevel = self.serviceLogLevel;
	if (self.serviceLogLevel > 0) {
		NSLog(@"%@ created new context: %@", [self class], [retVal debugDescription]);
	}
	return retVal;
}

- (NSPersistentStoreCoordinator*)generateCoordinator {
	NSPersistentStoreCoordinator* retVal = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
	if ([self.delegate respondsToSelector:@selector(configurations)]) {
		NSArray* configurations = [self.delegate configurations];
		if ([configurations count]) {
			for (NSString* configuration in configurations) {
				[self processConfiguration:configuration forPersistentStoreCoordinator:retVal];
			}
		} else {
			[self processConfiguration:nil forPersistentStoreCoordinator:retVal];
		}
	} else {
		[self processConfiguration:nil forPersistentStoreCoordinator:retVal];
	}
	return retVal;
}

- (NSPersistentStoreCoordinator*)mainCoordinator {
	while (!OSAtomicCompareAndSwapInt(0, 1, &_lockThreadCoordinator)) {};
	if (!_mainCoordinator) {
		_mainCoordinator = [self generateCoordinator];
	}
	if (!OSAtomicCompareAndSwapInt(1, 0, &_lockThreadCoordinator)) {
		_lockThreadCoordinator = 0;
	}
	return _mainCoordinator;
}

- (NSManagedObjectModel*)model {
	if (!_model) {
		NSArray<NSURL*>* modelURLs = self.delegate.modelURLs;
		if ([modelURLs count] == 1) {
			_model = [[NSManagedObjectModel alloc] initWithContentsOfURL:[modelURLs firstObject]];
		} else {
			NSArray* models = [self.delegate.modelURLs ase_ArrayMappedWithBlock:^id(NSURL* modelURL, NSUInteger index, BOOL* stop) {
				return [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
			}];
			_model = [NSManagedObjectModel modelByMergingModels:models];
		}
	}
	return _model;
}

- (void)processConfiguration:(NSString*)configuration forPersistentStoreCoordinator:(NSPersistentStoreCoordinator*)persistentStoreCoordinator {
	NSURL* persistentStoreUrl = nil;
	NSDictionary* options = nil;
	NSError* error = nil;
	NSString* storeType = NSInMemoryStoreType;
	if (!ASEnterpriseInUnitTest()) {
		if ([self.delegate respondsToSelector:@selector(persistentStoreTypeForConfiguration:)]) {
			storeType = [self.delegate persistentStoreTypeForConfiguration:configuration];
		} else {
			storeType = NSSQLiteStoreType;
		}
		persistentStoreUrl = [self.delegate persistentStoreUrlForConfiguration:configuration];
		if ([self.delegate respondsToSelector:@selector(persistentStoreOptionsForConfiguration:)]) {
			options = [self.delegate persistentStoreOptionsForConfiguration:configuration];
		}
	}
	[persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:configuration URL:persistentStoreUrl options:options error:&error];
	if (error && persistentStoreUrl) {
		if (self.serviceLogLevel > 0) {
			NSLog(@"%@.%@ error: %@", [self class], NSStringFromSelector(_cmd), error);
		}
		error = nil;
		if ([persistentStoreCoordinator respondsToSelector:@selector(destroyPersistentStoreAtURL:withType:options:error:)]) {
			[persistentStoreCoordinator destroyPersistentStoreAtURL:persistentStoreUrl withType:storeType options:options error:&error];
		} else {
			[[NSFileManager defaultManager] removeItemAtURL:persistentStoreUrl error:&error];
		}
		if (self.serviceLogLevel > 1) {
			NSLog(@"%@.%@ error: %@", [self class], NSStringFromSelector(_cmd), error);
		}
		error = nil;
		[persistentStoreCoordinator addPersistentStoreWithType:storeType configuration:configuration URL:persistentStoreUrl options:options error:&error];
	}
	if (error) {
		if (self.serviceLogLevel > 0) {
			NSLog(@"%@.%@ error: %@", [self class], NSStringFromSelector(_cmd), error);
		}
		abort();
	}
}

- (ASEManagedObjectContext*)readOnlyContextForThread:(NSThread*)thread {
	ASEManagedObjectContext* retVal = [thread threadDictionary][kASE_THREAD_ROMOC_KEY];
	if (!retVal) {
		@synchronized (_contexts) {
			retVal = _readOnlyContext;
			if (!retVal) {
				NSManagedObjectContextConcurrencyType concurrencyType = [thread isMainThread] ? NSMainQueueConcurrencyType : NSPrivateQueueConcurrencyType;
				retVal = [self contextWithConcurrencyType:concurrencyType readOnly:YES];
				_readOnlyContext = retVal;
			}
		}
		if (![thread isMainThread]) { // Do not save the context to the main thread, otherwise it will never deallocate
			[thread threadDictionary][kASE_THREAD_ROMOC_KEY] = retVal;
		}
	}
	return retVal;
}

- (void)saveContext:(NSManagedObjectContext*)context producedError:(NSError*)error {
	if ([self.delegate respondsToSelector:@selector(saveContext:producedError:)]) {
		[self.delegate saveContext:context producedError:error];
	}
}

- (void)saveContext:(NSManagedObjectContext*)context producedException:(NSException*)exception {
	if ([self.delegate respondsToSelector:@selector(saveContext:producedException:)]) {
		[self.delegate saveContext:context producedException:exception];
	} else {
		@throw exception;
	}
}

- (void)setupManagedObjectContexts {
	if (_mocChangedObserver || !_delegate) return;
	
	_contextPoolSize = 1;
	if ([self.delegate respondsToSelector:@selector(backgroundContextPoolSize)]) {
		_contextPoolSize = [self.delegate backgroundContextPoolSize];
	}
	_contexts = [[ASEWeakMutableArray alloc] initWithCapacity:_contextPoolSize];
	ASECoreDataStackConfiguration stackConfiguration = ASECoreDataStackConfigurationMultiCoordinatorWithBlockingMergeContexts;
	if ([self.delegate respondsToSelector:@selector(stackConfiguration)]) {
		stackConfiguration = [self.delegate stackConfiguration];
	}
	if (stackConfiguration == ASECoreDataStackConfigurationSingleCoordinatorWithAsynchronousMergeContexts) {
		NSAssert([[NSManagedObjectContext class] respondsToSelector:@selector(mergeChangesFromRemoteContextSave:intoContexts:)], @"Cannot use ASECoreDataStackConfigurationSingleCoordinatorWithAsynchronousMergeContexts with this version of the OS");
		self.saveContextQueue = [[NSOperationQueue alloc] init];
		self.saveContextQueue.maxConcurrentOperationCount = 1;
	}
	__weak typeof(self) weakSelf = self;
	_mocChangedObserver = [[NSNotificationCenter defaultCenter] addObserverForName:NSManagedObjectContextDidSaveNotification object:nil queue:self.saveContextQueue usingBlock:^(NSNotification* notification) {
		__strong typeof(weakSelf) strongSelf = weakSelf; // While we're in here, we should have a strong reference to self
		@synchronized(strongSelf.contexts) {
			NSMutableArray* allContexts = [[NSMutableArray alloc] initWithCapacity:self->_contextPoolSize + 2];
			id mainContext = strongSelf.mainThreadContext;
			if (mainContext) {
				[allContexts addObject:mainContext];
			}
			id readOnlyContext = strongSelf.readOnlyContext;
			if (readOnlyContext) {
				[allContexts addObject:readOnlyContext];
			}
			for (NSManagedObjectContext* backgroundContext in strongSelf.contexts) {
				[allContexts addObject:backgroundContext];
			}
			if ([allContexts containsObject:notification.object]) {
				NSArray* otherContexts = [allContexts ase_ArrayMappedWithBlock:^id _Nullable(NSManagedObjectContext* _Nonnull context, NSUInteger index, BOOL* _Nonnull stop) {
					return [notification.object isEqual:context] ? nil : context;
				}];
				if (self.serviceLogLevel > 0) {
					NSLog(@"%@ %@ pushing (%lu inserts, %lu updates, %lu deletes) to %lu contexts", [strongSelf class], [notification.object debugDescription], (unsigned long)[notification.userInfo[NSInsertedObjectsKey] count], (unsigned long)[notification.userInfo[NSUpdatedObjectsKey] count], (unsigned long)[notification.userInfo[NSDeletedObjectsKey] count], (unsigned long)[otherContexts count]);
				}
				BOOL useTry = [strongSelf.delegate respondsToSelector:@selector(saveContext:producedException:)];
				if (stackConfiguration == ASECoreDataStackConfigurationSingleCoordinatorWithAsynchronousMergeContexts) {
					if (useTry) {
						@try {
							[NSManagedObjectContext mergeChangesFromRemoteContextSave:notification.userInfo intoContexts:otherContexts];
						} @catch (NSException* exception) {
							[strongSelf.delegate saveContext:notification.object producedException:exception];
						}
					} else {
						[NSManagedObjectContext mergeChangesFromRemoteContextSave:notification.userInfo intoContexts:otherContexts];
					}
				} else {
					for (ASEManagedObjectContext* context in otherContexts) {
						[context performBlock:^{
							if (useTry) {
								@try {
									for (NSManagedObject* object in notification.userInfo[NSUpdatedObjectsKey]) {
										// This is not necessary on iOS 10 : Fixes problem with NSFetchedResultsController
										[[object.objectID ase_ManagedObjectForContext:context] willAccessValueForKey:nil];
									}
									[context mergeChangesFromContextDidSaveNotification:notification];
								} @catch (NSException* exception) {
									[strongSelf.delegate saveContext:notification.object producedException:exception];
								}
							} else {
								for (NSManagedObject* object in notification.userInfo[NSUpdatedObjectsKey]) {
									// This is not necessary on iOS 10 : Fixes problem with NSFetchedResultsController
									[[object.objectID ase_ManagedObjectForContext:context] willAccessValueForKey:nil];
								}
								[context mergeChangesFromContextDidSaveNotification:notification];
							}
						}];
					}
				}
			}
		}
	}];
}

#pragma mark - <ASECoreDataService> methods

- (void)performBlock:(void (^)(NSManagedObjectContext* _Nonnull))block {
	[self performReadOnly:NO withBlock:block];
}

- (void)performBlockAndWait:(__attribute__((noescape)) void (^)(NSManagedObjectContext* _Nonnull))block {
	[self performReadOnly:NO withBlockAndWait:block];
}

- (id)performBlockAndReturn:(__attribute__((noescape)) id _Nullable (^)(NSManagedObjectContext* _Nonnull))block {
	return [self performReadOnly:NO withBlockAndReturn:block];
}

- (void)performReadOnly:(BOOL)readOnly withBlock:(void (^)(NSManagedObjectContext* _Nonnull))block {
	NSParameterAssert(block);
	NSManagedObjectContext* context = [self contextForThread:[NSThread mainThread] readOnly:readOnly];
	[context performBlock:^{ // performBlock already encapsulates an @autoreleasepool
		block(context);
	}];
}

- (void)performReadOnly:(BOOL)readOnly withBlockAndWait:(__attribute__((noescape)) void (^)(NSManagedObjectContext* _Nonnull))block {
	NSParameterAssert(block);
	NSManagedObjectContext* context = [self contextForThread:[NSThread mainThread] readOnly:readOnly];
	[context performBlockAndWait:^{
		block(context);
	}];
}

- (id)performReadOnly:(BOOL)readOnly withBlockAndReturn:(__attribute__((noescape)) id _Nullable (^)(NSManagedObjectContext* _Nonnull))block {
	NSParameterAssert(block);
	NSManagedObjectContext* context = [self contextForThread:[NSThread mainThread] readOnly:readOnly];
	return [context ase_PerformBlockAndReturn:^id{
		return block(context);
	}];
}

@end
