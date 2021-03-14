//
//  NSData+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/15/13.
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

#import <CommonCrypto/CommonDigest.h>
#import "NSData+ASEnterpriseCategories.h"

@implementation NSData (ASEnterpriseCategories)

- (NSString*)ase_Base64String {
	static uint8_t const kAFBase64EncodingTable[64] = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";
	return [self ase_Base64StringWithEncodingTable:kAFBase64EncodingTable];
}

- (NSString*)ase_Base64StringWithEncodingTable:(const uint8_t [64])encodingTable {
	NSParameterAssert(sizeof(*encodingTable) / sizeof(uint8_t) == 64);
    NSUInteger length = [self length];
    NSMutableData* mutableData = [[NSMutableData alloc] initWithLength:((length + 2) / 3) * 4];
	
    uint8_t* input = (uint8_t*)[self bytes];
    uint8_t* output = (uint8_t*)[mutableData mutableBytes];
	
    for (NSUInteger i = 0; i < length; i += 3) {
        NSUInteger value = 0;
        for (NSUInteger j = i; j < (i + 3); j++) {
            value <<= 8;
            if (j < length) {
                value |= (0xFF & input[j]);
            }
        }

        NSUInteger idx = (i / 3) * 4;
        output[idx + 0] = encodingTable[(value >> 18) & 0x3F];
        output[idx + 1] = encodingTable[(value >> 12) & 0x3F];
        output[idx + 2] = (i + 1) < length ? encodingTable[(value >> 6)  & 0x3F] : '=';
        output[idx + 3] = (i + 2) < length ? encodingTable[(value >> 0)  & 0x3F] : '=';
    }

    return [[NSString alloc] initWithData:mutableData encoding:NSASCIIStringEncoding];
}

- (NSString*)ase_HashWithSaltValues:(NSString*)saltValues, ... {
	CC_MD5_CTX md5;
	CC_MD5_Init(&md5);
	
	va_list argList;
	va_start(argList, saltValues);
	for (NSString* saltValue = saltValues; saltValue != nil; saltValue = va_arg(argList, NSString*)) {
		// Hash with the current salt
		NSData* saltData = [saltValue dataUsingEncoding:NSUTF8StringEncoding];
		CC_MD5_Update(&md5, saltData.bytes, (CC_LONG)saltData.length);
	}
	va_end(argList);
	
	// Hash the data
	CC_MD5_Update(&md5, self.bytes, (CC_LONG)self.length);
	
	// Complete the answer
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5_Final(result, &md5);

	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3],
			result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11],
			result[12], result[13], result[14], result[15], nil];
}

- (NSString*)ase_HexString {
	const unsigned char* bytes = (const unsigned char*)[self bytes];
    NSUInteger byteCount = [self length];
	
    NSMutableString* retVal = [[NSMutableString alloc] initWithCapacity:byteCount * 2];
    for (NSUInteger index = 0; index < byteCount; index++) {
        [retVal appendFormat:@"%02x", bytes[index]];
    }
    return [retVal copy];
}

- (id)ase_SecureDecodeAsClass:(Class)asClass completionHandler:(__attribute__((noescape)) ASESecureDecodeCompletionHandler)completionHandler {
	id retVal = nil;
	@try {
		NSKeyedUnarchiver* unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:self];
		unarchiver.requiresSecureCoding = YES;
		retVal = [unarchiver decodeObjectOfClass:asClass forKey:NSKeyedArchiveRootObjectKey];
		[unarchiver finishDecoding];
		if (completionHandler) {
			completionHandler(retVal, nil);
		}
	} @catch (NSException* exception) {
		if (completionHandler) {
			completionHandler(nil, exception);
		}
	}
	return retVal;
}

@end
