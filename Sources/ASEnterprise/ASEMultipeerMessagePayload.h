//
//  ASEMultipeerMessagePayload.h
//  ASEnterprise
//
//  Created by David Mitchell on 7/16/16.
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/** Securely-encoded payload for ASEMultipeerMessageManager. */
@interface ASEMultipeerMessagePayload : NSObject <NSSecureCoding>

@property (copy, nonatomic) NSData* data;
@property (nullable, copy, nonatomic) NSURL* resourceURL;
@property (readonly, nonatomic) NSUUID* UUID;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithData:(NSData*)data withResourceAtURL:(nullable NSURL*)resourceURL;

@end

NS_ASSUME_NONNULL_END
