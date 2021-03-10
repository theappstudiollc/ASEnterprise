//
//  ASEMultipeerMessagePayload.m
//  ASEnterprise
//
//  Created by David Mitchell on 7/16/16.
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

#import "ASEMultipeerMessagePayload.h"

static int32_t const kASEMultipeerMessagePayloadCurrentVersion = 1;
static NSString* const kASEMultipeerMessagePayloadKeyData = @"data";
static NSString* const kASEMultipeerMessagePayloadKeyResourceURL = @"resourceURL";
static NSString* const kASEMultipeerMessagePayloadKeyUUID = @"UUID";
static NSString* const kASEMultipeerMessagePayloadVersion = @"version";

@interface ASEMultipeerMessagePayload ()

@property (nonatomic) NSUUID* UUID;

@end

@implementation ASEMultipeerMessagePayload
#pragma mark - Public properties and methods

- (instancetype)initWithData:(NSData*)data withResourceAtURL:(NSURL*)resourceURL {
	self = [super init];
	self.data = data;
	self.resourceURL = resourceURL;
	self.UUID = [NSUUID UUID];
	return self;
}

#pragma mark - <NSSecureCoding> methods

- (void)encodeWithCoder:(NSCoder*)aCoder {
	[aCoder encodeObject:self.data forKey:kASEMultipeerMessagePayloadKeyData];
	if (self.resourceURL) {
		[aCoder encodeObject:self.resourceURL forKey:kASEMultipeerMessagePayloadKeyResourceURL];
	}
	[aCoder encodeObject:self.UUID forKey:kASEMultipeerMessagePayloadKeyUUID];
	[aCoder encodeInt32:kASEMultipeerMessagePayloadCurrentVersion forKey:kASEMultipeerMessagePayloadVersion];
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
	self = [super init];
	int32_t version = [aDecoder decodeInt32ForKey:kASEMultipeerMessagePayloadVersion];
	if (version == kASEMultipeerMessagePayloadCurrentVersion) {
		self.data = [aDecoder decodeObjectOfClass:[NSData class] forKey:kASEMultipeerMessagePayloadKeyData];
		self.resourceURL = [aDecoder decodeObjectOfClass:[NSURL class] forKey:kASEMultipeerMessagePayloadKeyResourceURL];
		self.UUID = [aDecoder decodeObjectOfClass:[NSUUID class] forKey:kASEMultipeerMessagePayloadKeyUUID];
	}
	return self;
}

+ (BOOL)supportsSecureCoding {
	return YES;
}

@end
