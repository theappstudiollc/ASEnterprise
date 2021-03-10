//
//  ASProxyObjectTests.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/15/14.
//  Copyright (c) 2014 The App Studio LLC. All rights reserved.
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

#if !TARGET_OS_WATCH

#import <XCTest/XCTest.h>
@import ASEnterprise;

@interface ProxyObjectProxy1 : NSObject

@property (NS_NONATOMIC_IOSONLY, readonly) BOOL returnsYes;
@property (NS_NONATOMIC_IOSONLY, readonly) BOOL returnsNo;

@end

@implementation ProxyObjectProxy1

- (BOOL)returnsYes { return YES; }
- (BOOL)returnsNo { return NO; }

@end

@interface ProxyObjectProxy2 : NSObject

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString* returnsMaybe;

@end

@implementation ProxyObjectProxy2

- (NSString *)returnsMaybe { return @"Maybe"; }

@end

@interface ASProxyObjectTests : XCTestCase

@end

@implementation ASProxyObjectTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAssertNilBlock {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertThrows([ASEProxyObject proxyWithForwardingBlock:nil], @"Convenience constructor does not assert the block!");
#pragma clang diagnostic pop
}

- (void)testBlockForwarding {
	id proxy = [ASEProxyObject proxyWithForwardingBlock:^id(SEL selector) {
		return [[ProxyObjectProxy1 alloc] init];
	}];
	
	XCTAssertTrue([proxy returnsYes], @"Proxy does not return YES!");
	XCTAssertFalse([proxy returnsNo], @"Proxy does not return NO!");
}

- (void)testBlockReforwarding {
	id proxy = [ASEProxyObject proxyWithForwardingBlock:^id(SEL selector) {
		if (selector == @selector(returnsMaybe)) {
			return [[ProxyObjectProxy2 alloc] init];
		}
		return [[ProxyObjectProxy1 alloc] init];
	}];
	
	XCTAssertTrue([proxy returnsYes], @"Proxy does not return YES!");
	XCTAssertFalse([proxy returnsNo], @"Proxy does not return NO!");
	XCTAssertEqual([proxy returnsMaybe], @"Maybe", @"Proxy does not return Maybe!");
}

@end

#endif
