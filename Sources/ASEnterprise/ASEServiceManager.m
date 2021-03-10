//
//  ASEServiceManager.m
//  ASEnterprise
//
//  Created by David Mitchell on 3/28/15.
//  Copyright (c) 2015 The App Studio LLC. All rights reserved.
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

#import "ASEServiceManager.h"
#import "NSObject+ASEnterpriseCategories.h"

@interface ASEServiceManager ()
/** The collection of service allocator blocks, keyed by protocol as NSString */
@property (nonatomic) NSDictionary<ASEServiceName, ASEServiceInitializer>* serviceMappings;
/** The official collection of allocated services. Only holds weak references so that they may be automatically deallocated when unused. */
@property (nonatomic) NSMapTable<Protocol*, id>* resolvedServices;
/** The +1 collection that maintains a reference until/unless there's a memory warning */
@property (nonatomic) NSMutableSet* resolvedServiceReferences;
@end

@implementation ASEServiceManager
#pragma mark - NSObject overrides

#pragma mark - Public properties and methods

- (void)addServiceInitializer:(ASEServiceInitializer)serviceInitializer forProtocol:(Protocol*)protocol {
	NSParameterAssert(serviceInitializer != NULL && !!protocol);
	NSMutableDictionary* protocolResolvers = [NSMutableDictionary dictionaryWithCapacity:self.serviceMappings.count + 1];
	[protocolResolvers addEntriesFromDictionary:self.serviceMappings];
	protocolResolvers[ase_ServiceName(protocol)] = [serviceInitializer copy];
	self.serviceMappings = [protocolResolvers copy];
}

- (instancetype)initWithServiceMappings:(NSDictionary*)serviceMappings {
	self = [super init];
	// Protocol's hash function always returns the same number. Let's use NSPointerFunctionsOpaquePersonality
	self.resolvedServices = [[NSMapTable alloc] initWithKeyOptions:NSPointerFunctionsOpaqueMemory|NSPointerFunctionsOpaquePersonality valueOptions:NSPointerFunctionsWeakMemory capacity:[serviceMappings count]];
	self.resolvedServiceReferences = [[NSMutableSet alloc] initWithCapacity:[serviceMappings count]];
	self.serviceMappings = serviceMappings;
	return self;
}

- (void)releaseUnusedServices {
	// These are the only strong references to the currently resolved services
	[self.resolvedServiceReferences removeAllObjects];
}

#pragma mark - <ASEServiceResolver> methods

- (BOOL)canResolveServiceForProtocol:(Protocol*)serviceProtocol {
	ASEServiceName key = ase_ServiceName(serviceProtocol);
	return self.serviceMappings[key] != NULL;
}

- (id)resolveServiceForProtocol:(Protocol*)serviceProtocol {
	id retVal = [self.resolvedServices objectForKey:serviceProtocol];
	if (!retVal) {
		ASEServiceName key = ase_ServiceName(serviceProtocol);
		ASEServiceInitializer block = self.serviceMappings[key];
		if (block) {
			retVal = block();
		}
		if (retVal) {
			// This collection does not retain references so that they may be automatically removed
			[self.resolvedServices setObject:retVal forKey:serviceProtocol];
		}
	}
	if (retVal) {
		// Let's add a reference so that it can remain as long as there is no memory pressure
		[self.resolvedServiceReferences addObject:retVal];
	}
	return retVal;
}

- (id)resolveServiceIfLoadedForProtocol:(Protocol*)serviceProtocol {
	return [self.resolvedServices objectForKey:serviceProtocol];
}

@end
