//
//  ASEServiceManager.h
//  ASEnterprise
//
//  Created by David Mitchell on 3/28/15.
//  Copyright (c) 2015 The App Studio LLC.
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

@class Protocol;

/** Methods to resolve services marked via protocols. Implementations are not required to make these methods thread-safe. Check with implementations before you go thread-crazy. */
@protocol ASEServiceResolver <NSObject>

/** Returns the service that implements the specified protocol */
- (id _Nullable)resolveServiceForProtocol:(Protocol*)serviceProtocol NS_SWIFT_NAME(resolveService(forProtocol:));
@optional
/** Returns whether the current service resolver is able to resolve a service for the specified protocol */
- (BOOL)canResolveServiceForProtocol:(Protocol*)serviceProtocol NS_SWIFT_NAME(canResolveService(forProtocol:));
/** Returns the service that implements the specified protocol IFF it is already loaded. Otherwise nil. */
- (id _Nullable)resolveServiceIfLoadedForProtocol:(Protocol*)serviceProtocol NS_SWIFT_NAME(resolveServiceIfLoaded(forProtocol:));

@end

/** STOP using singletons. And let this class help. This class' implementation of ASEServiceResolver is NOT thread-safe. Containing classes are encouraged to synchronize access to all ASEServiceResolver methods (NSRecursiveLock is a great way to do so). Or, you can just make sure that ALL calls to ASEServiceResolver methods are made within the same dispatch queue or thread. */
@interface ASEServiceManager : NSObject <ASEServiceResolver>
/** Type to define the name of a service in the service mappings. This must be an NSString generated from the Protocol. The inline function ase_ServiceName() is provided as a convenience */
typedef NSString* ASEServiceName;
/** Block signature for initializing a service */
typedef id _Nonnull(^ASEServiceInitializer)(void);
/** Use initWithServiceMappings: instead */
- (instancetype)init NS_UNAVAILABLE;
/** Initializes the receiver with a mapping of service protocols to serviceInitMethods */
- (instancetype)initWithServiceMappings:(nullable NSDictionary<ASEServiceName, ASEServiceInitializer>*)serviceMappings NS_DESIGNATED_INITIALIZER;
/** Adds a new service intializer to the dictionary */
- (void)addServiceInitializer:(ASEServiceInitializer)serviceInitializer forProtocol:(Protocol*)protocol;
/** Releases any currently unused services. Available if you wish to call this during low-memory situations */
- (void)releaseUnusedServices;

@end

FOUNDATION_STATIC_INLINE ASEServiceName ase_ServiceName(Protocol* protocol) {
	return NSStringFromProtocol(protocol);
}

NS_ASSUME_NONNULL_END
