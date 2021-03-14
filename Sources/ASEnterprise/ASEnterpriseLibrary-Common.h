//
//  ASEnterprise-Common.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/16/13.
//  Copyright (c) 2013 The App Studio LLC.
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

#ifndef ASEnterprise_Common_h
#define ASEnterprise_Common_h

#import "ASEAsynchronousOperation.h"
#import "ASECoreDataManager.h"
#import "ASEDrawing.h"
#import "ASEFileStoreManager.h"
#import "ASEMath.h"
#import "ASEObjectiveC.h"
#import "ASEProxyObject.h"
#import "ASEScalableLabel.h"
#import "ASEServiceManager.h"
#import "ASEWeakMutableArray.h"
#import "ASEWeakReference.h"

// Unit testing functions
#define ASEnterpriseInUnitTest() (NSClassFromString(@"XCTestCase") || NSClassFromString(@"SenTestCase"))

#endif
