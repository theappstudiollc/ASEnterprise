//
//  NSError+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/10/13.
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

#import <Foundation/Foundation.h>

OBJC_EXTERN NSString* const ASEnterpriseErrorDomain;
OBJC_EXTERN NSString* const ASEnterpriseErrorHTTPResponseCodeKey; // An NSNumber* containing the HTTP Response Code

@interface NSError (ASEnterpriseCategories)

typedef NS_ENUM(NSInteger, ASEnterpriseErrorCode) {
	ASEnterpriseErrorCodeHTTPResponseCode = -1,
	ASEnterpriseErrorCodeReadOnlyContextAttemptedSave = -2,
	ASEnterpriseErrorCodeApplicationReserved = -1000,
};

+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code;
+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code andUnderlyingError:(NSError*)error;
+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code andUserInfo:(NSDictionary*)userInfo;
+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code underlyingError:(NSError*)error andUserInfo:(NSDictionary*)userInfo;
- (BOOL)ase_IsASEnterpriseErrorWithCode:(ASEnterpriseErrorCode)code;
- (BOOL)ase_IsASEnterpriseErrorHTTPResponseCode:(NSInteger)responseCode;
- (BOOL)ase_IsCausedByErrorDomain:(NSString*)domain code:(NSInteger)code;

@end
