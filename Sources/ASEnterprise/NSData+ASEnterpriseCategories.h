//
//  NSData+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/15/13.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (ASEnterpriseCategories)

typedef void(^ASESecureDecodeCompletionHandler)(id _Nullable decodedObject, NSException* _Nullable exception);

@property (readonly, copy, NS_NONATOMIC_IOSONLY) NSString* ase_Base64String;
@property (readonly, copy, NS_NONATOMIC_IOSONLY) NSString* ase_HexString;

- (NSString*)ase_HashWithSaltValues:(nullable NSString*)saltValues, ... NS_REQUIRES_NIL_TERMINATION;
- (NSString*)ase_Base64StringWithEncodingTable:(const uint8_t [_Nonnull 64])encodingTable;
- (nullable id)ase_SecureDecodeAsClass:(Class)asClass completionHandler:(__attribute__((noescape)) ASESecureDecodeCompletionHandler _Nullable)completionHandler;

@end

NS_ASSUME_NONNULL_END
