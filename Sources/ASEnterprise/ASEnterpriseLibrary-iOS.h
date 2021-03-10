//
//  ASEnterprise-iOS.h
//  ASEnterprise
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#ifndef ASEnterprise_iOS_h
#define ASEnterprise_iOS_h

#import "ASEnterpriseLibrary-Common.h"
#import "ASEnterpriseCategories-iOS.h"
#import "ASEBackgroundTaskManager.h"
#import "ASECustomTransition.h"
#import "ASEFetchedResultsCollectionViewController.h"
#import "ASEFetchedResultsCollectionViewDataSource.h"
#import "ASEFetchedResultsControllerDataSource.h"
#import "ASEFetchedResultsTableViewController.h"
#import "ASEFetchedResultsTableViewDataSource.h"
#import "ASEFetchedResultsTrackingCollectionViewController.h"
#import "ASEFetchedResultsTrackingTableViewController.h"
#import "ASEMultipeerMessageManager.h"
#import "ASEMultipeerMessagePayload.h"
#import "ASENavigationController.h"
#import "ASENavigationTransition.h"
#import "ASENetworkActivityIndicatorManager.h"
#import "ASERenavigateSegue.h"
#import "ASESlider.h"
#import "ASESwitchRootSegue.h"
#import "ASETouchProxyView.h"
#import "ASEVideoPlayerView.h"

// Fix a security warning by always adding an extra ", nil" to the string

 #define ASE_LocalizedText(__TEXT__, ...) [NSString stringWithFormat:NSLocalizedString(__TEXT__, nil), ##__VA_ARGS__, nil]
 
 // OS Version checking functions
 #define ASE_SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
 #define ASE_SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
 #define ASE_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
 #define ASE_SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
 #define ASE_SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)
 
 // Color macros for Objective C
 #define ASE_UIColorFromRGB(__rgbValue__) [UIColor colorWithRed:((CGFloat)((__rgbValue__ & 0xFF0000) >> 16))/255.0 green:((CGFloat)((__rgbValue__ & 0xFF00) >> 8))/255.0 blue:((CGFloat)(__rgbValue__ & 0xFF))/255.0 alpha:1.0]
 #define ASE_UIColorFromRGBAlpha(__rgbValue__, __alphaValue__) [UIColor colorWithRed:((CGFloat)((__rgbValue__ & 0xFF0000) >> 16))/255.0 green:((CGFloat)((__rgbValue__ & 0xFF00) >> 8))/255.0 blue:((CGFloat)(__rgbValue__ & 0xFF))/255.0 alpha:__alphaValue__]

#endif /* ASEnterprise_iOS_h */

#endif
