//
//  ASEnterprise.h
//  ASEnterprise iOS Framework
//
//  Created by David Mitchell on 3/8/16.
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

#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#if TARGET_OS_WATCH
#import <WatchKit/WatchKit.h>
#endif
#elif TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

//! Project version number for ASEnterprise Framework.
FOUNDATION_EXPORT double ASEnterpriseVersionNumber;

//! Project version string for ASEnterprise Framework.
FOUNDATION_EXPORT const unsigned char ASEnterpriseVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <ASEnterprise/PublicHeader.h>

#if TARGET_OS_IPHONE
#if TARGET_OS_TV
#import <../ASEnterprise-tvOS.h>
#elif TARGET_OS_WATCH
#import <../ASEnterprise-watchOS.h>
#else
#import <../ASEnterprise-iOS.h>
#endif
#elif TARGET_OS_MAC
#import <../ASEnterprise-macOS.h>
#endif
