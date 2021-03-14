//
//  ASEnterprise-macOS.h
//  ASEnterprise
//
//  Created by David Mitchell on 3/8/16.
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

#ifndef ASEnterprise_macOS_h
#define ASEnterprise_macOS_h

#import "ASEnterprise-Common.h"
#import "ASEnterpriseCategories-Common.h"
#import "ASEFetchedResultsControllerDataSource.h"
#import "ASEMultipeerMessageManager.h"
#import "ASEMultipeerMessagePayload.h"
#import "ASEVideoPlayerView.h"

#define ASE_NSColorFromRGB(__rgbValue__) [NSColor colorWithRed:((CGFloat)((__rgbValue__ & 0xFF0000) >> 16))/255.0 green:((CGFloat)((__rgbValue__ & 0xFF00) >> 8))/255.0 blue:((CGFloat)(__rgbValue__ & 0xFF))/255.0 alpha:1.0]
#define ASE_NSColorFromRGBAlpha(__rgbValue__, __alphaValue__) [NSColor colorWithRed:((CGFloat)((__rgbValue__ & 0xFF0000) >> 16))/255.0 green:((CGFloat)((__rgbValue__ & 0xFF00) >> 8))/255.0 blue:((CGFloat)(__rgbValue__ & 0xFF))/255.0 alpha:__alphaValue__]

#endif /* ASEnterprise_macOS_h */
