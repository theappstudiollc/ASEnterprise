//
//  ASNSDictionaryCategoryTests.m
//  ASEnterprise
//
//  Created by David Mitchell on 3/27/14.
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

@interface ASNSDictionaryCategoryTests : XCTestCase

@property (nonatomic) NSDictionary* input;
@property (nonatomic) NSArray* output;

@end

@implementation ASNSDictionaryCategoryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_input = @ {
		@"1" : @1,
		@"2" : @2,
		@"3" : @3,
		@"4" : @4,
	};
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	_output = nil;
}

- (void)testNilBlock {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertThrows([_input ase_ArrayMappedWithBlock:nil], @"paramter assert not thrown");
	XCTAssertThrows([_input ase_MutableArrayMappedWithBlock:nil], @"paramter assert not thrown");
#pragma clang diagnostic pop
}

- (void)testEmptyReturn {
	_output = [_input ase_ArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return nil;
	}];
	XCTAssert(_output && [_output count] == 0, @"Non-zero count returned! %@", _output);
	
	_output = [_input ase_MutableArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return nil;
	}];
	XCTAssert(_output && [_output count] == 0, @"Non-zero count returned! %@", _output);
}

- (void)testSameKeyReturn {
	_output = [_input ase_ArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return key;
	}];
	XCTAssert([[_input allKeys] isEqualToArray:_output], @"input not equal to output!");
	
	_output = [_input ase_MutableArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return key;
	}];
	XCTAssert([[_input allKeys] isEqualToArray:_output], @"input not equal to output!");
}

- (void)testSameValueReturn {
	_output = [_input ase_ArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return object;
	}];
	XCTAssert([[_input allValues] isEqualToArray:_output], @"input not equal to output!");
	
	_output = [_input ase_MutableArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return object;
	}];
	XCTAssert([[_input allValues] isEqualToArray:_output], @"input not equal to output!");
}

- (void)testDifferentReturn {
	_output = [_input ase_ArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return [object stringValue];
	}];
	XCTAssert(![[_input allValues] isEqualToArray:_output], @"input is equal to output!");
	
	_output = [_input ase_MutableArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return [object stringValue];
	}];
	XCTAssert(![[_input allValues] isEqualToArray:_output], @"input is equal to output!");
}

- (void)testReturnType {
	_output = [_input ase_ArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return object;
	}];
	XCTAssert([_output isKindOfClass:[NSArray class]], @"output is wrong type (%@) !", [_output class]);
	XCTAssert(![_output isKindOfClass:[NSMutableArray class]], @"output is wrong type (%@) !", [_output class]);
	
	_output = [_input ase_MutableArrayMappedWithBlock:^id(id<NSCopying> key, id object, BOOL* stop) {
		return object;
	}];
	XCTAssert([_output isKindOfClass:[NSArray class]], @"output is wrong type (%@) !", [_output class]);
	XCTAssert([_output isKindOfClass:[NSMutableArray class]], @"output is wrong type (%@) !", [_output class]);
}
/*
- (void)testChangedKeys {
	NSDictionary* changed = @ {
		@"1" : @4,
		@"2" : @2,
		@"5" : @5,
	};
	
	_output = [_input changedKeysFrom:changed];
	
	XCTAssert([_output containsObject:@"1"], @"output does not contain key 1");
	XCTAssert(![_output containsObject:@"2"], @"output should not contain key 2");
	XCTAssert([_output containsObject:@"3"], @"output does not contain key 3");
	XCTAssert([_output containsObject:@"4"], @"output does not contain key 4");
	XCTAssert([_output containsObject:@"5"], @"output does not contain key 5");
}
*/
@end

#endif
