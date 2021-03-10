//
//  NSError+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/10/13.
//  Copyright (c) 2013 The App Studio LLC. All rights reserved.
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

#import "NSError+ASEnterpriseCategories.h"

NSString* const ASEnterpriseErrorDomain = @"ASEnterpriseErrorDomain";
NSString* const ASEnterpriseErrorHTTPResponseCodeKey = @"HTTPResponseCodeKey";

@implementation NSError (ASEnterpriseCategories)

///////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods -
///////////////////////////////////////////////////////////////////////////

+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code {
	NSDictionary* userInfo = [self ase_UserInfoForCode:code];
	return [self errorWithDomain:ASEnterpriseErrorDomain code:code userInfo:userInfo];
}

+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code andUnderlyingError:(NSError*)error {
	if (error == nil) {
		return [self ase_ErrorWithCode:code];
	}
	NSMutableDictionary* userInfo = [NSMutableDictionary dictionaryWithObject:error forKey:NSUnderlyingErrorKey];
	[userInfo addEntriesFromDictionary:[self ase_UserInfoForCode:code]];
	return [NSError errorWithDomain:ASEnterpriseErrorDomain code:code userInfo:[NSDictionary dictionaryWithDictionary:userInfo]];
}

+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code andUserInfo:(NSDictionary*)userInfo {
	if (userInfo == nil) {
		return [self ase_ErrorWithCode:code];
	}
	NSMutableDictionary* aggregatedUserInfo = [NSMutableDictionary dictionaryWithDictionary:[self ase_UserInfoForCode:code]];
	[aggregatedUserInfo addEntriesFromDictionary:userInfo];
	return [NSError errorWithDomain:ASEnterpriseErrorDomain code:code userInfo:[NSDictionary dictionaryWithDictionary:aggregatedUserInfo]];
}

+ (instancetype)ase_ErrorWithCode:(ASEnterpriseErrorCode)code underlyingError:(NSError*)error andUserInfo:(NSDictionary*)userInfo {
	if (error == nil) {
		return [self ase_ErrorWithCode:code andUserInfo:userInfo];
	}
	if (userInfo == nil) {
		return [self ase_ErrorWithCode:code];
	}
	NSMutableDictionary* aggregatedUserInfo = [NSMutableDictionary dictionaryWithDictionary:[self ase_UserInfoForCode:code]];
	aggregatedUserInfo[NSUnderlyingErrorKey] = error;
	[aggregatedUserInfo addEntriesFromDictionary:userInfo];
	return [NSError errorWithDomain:ASEnterpriseErrorDomain code:code userInfo:[NSDictionary dictionaryWithDictionary:aggregatedUserInfo]];
}

- (BOOL)ase_IsASEnterpriseErrorWithCode:(ASEnterpriseErrorCode)code {
	return [ASEnterpriseErrorDomain isEqualToString:self.domain] && self.code == code;
}

- (BOOL)ase_IsASEnterpriseErrorHTTPResponseCode:(NSInteger)responseCode {
	if ([self ase_IsASEnterpriseErrorWithCode:ASEnterpriseErrorCodeHTTPResponseCode]) {
		NSNumber* httpErrorCode = (self.userInfo)[ASEnterpriseErrorHTTPResponseCodeKey];
		return [httpErrorCode integerValue] == responseCode;
	}
	return NO;
}

- (BOOL)ase_IsCausedByErrorDomain:(NSString*)domain code:(NSInteger)code {
	NSParameterAssert(domain);
	if ([domain isEqualToString:self.domain] && code == self.code) {
		return YES;
	}
	return [self.userInfo[NSUnderlyingErrorKey] ase_IsCausedByErrorDomain:domain code:code];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods -
///////////////////////////////////////////////////////////////////////////

+ (NSDictionary*)ase_UserInfoForCode:(ASEnterpriseErrorCode)code {
	// TODO: This can be based off of a localizable strings file
	switch (code) {
		case ASEnterpriseErrorCodeHTTPResponseCode:
			return @{ NSLocalizedDescriptionKey : @"HTTP Server responded with an error" };
			
		default:
			return nil;
	}
	return nil;
}

@end
