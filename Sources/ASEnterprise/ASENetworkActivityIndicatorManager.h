//
//  ASENetworkActivityIndicatorManager.h
//  ASEnterprise
//
//  Created by David Mitchell on 3/13/16.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import <Foundation/Foundation.h>

@class UIApplication;

NS_ASSUME_NONNULL_BEGIN

/** Simple service that manages multiple requestors of the single device network activity indicator. */
@protocol ASENetworkActivityIndicatorService

/** Starts, if necessary, the device network activity indicator using a requestor (used as a unique token by the service). The requestor may be weakly held by the implementation. */
- (void)beginNetworkActivityForRequestor:(id)requestor;
/** Stops, if no other requestors are outstanding, the device network activity indicator for the requestor token provided by beginNetworkActivityForRequestor: */
- (void)endNetworkActivityForRequestor:(id)requestor;

@end

/** Class that implements the ASENetworkActivityIndicatorService for a given UIApplication. */
@interface ASENetworkActivityIndicatorManager : NSObject <ASENetworkActivityIndicatorService>

/** Use initWithApplication: instead */
- (instancetype)init NS_UNAVAILABLE;
/** Initializes the class with the UIApplication instance */
- (instancetype)initWithApplication:(UIApplication*)application NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END

#endif
