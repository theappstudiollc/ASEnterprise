//
//  ASNSOrderedSetCategoryTests.m
//  ASEnterprise
//
//  Created by David Mitchell on 3/27/14.
//  Copyright (c) 2014 The App Studio LLC.
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

@interface ASNSOrderedSetCategoryTests : XCTestCase

@property (nonatomic) NSOrderedSet* input;
@property (nonatomic) NSOrderedSet* output;

@end

@implementation ASNSOrderedSetCategoryTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
	_input = [NSOrderedSet orderedSetWithArray:@[@1, @2, @3, @4]];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
	_output = nil;
}

- (void)testNilBlock {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnonnull"
	XCTAssertThrows([_input ase_OrderedSetMappedWithBlock:nil], @"paramter assert not thrown");
	XCTAssertThrows([_input ase_MutableOrderedSetMappedWithBlock:nil], @"paramter assert not thrown");
#pragma clang diagnostic pop
}

- (void)testEmptyReturn {
	_output = [_input ase_OrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return nil;
	}];
	XCTAssert(_output && [_output count] == 0, @"Non-zero count returned! %@", _output);
	
	_output = [_input ase_MutableOrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return nil;
	}];
	XCTAssert(_output && [_output count] == 0, @"Non-zero count returned! %@", _output);
}

- (void)testSameReturn {
	_output = [_input ase_OrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return object;
	}];
	XCTAssert([_input isEqualToOrderedSet:_output], @"input not equal to output!");
	
	_output = [_input ase_MutableOrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return object;
	}];
	XCTAssert([_input isEqualToOrderedSet:_output], @"input not equal to output!");
}

- (void)testDifferentReturn {
	_output = [_input ase_OrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return [object stringValue];
	}];
	XCTAssert(![_input isEqualToOrderedSet:_output], @"input is equal to output!");
	
	_output = [_input ase_MutableOrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return [object stringValue];
	}];
	XCTAssert(![_input isEqualToOrderedSet:_output], @"input is equal to output!");
}

- (void)testReturnType {
	_output = [_input ase_OrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return object;
	}];
	XCTAssert([_output isKindOfClass:[NSOrderedSet class]], @"output is wrong type (%@) !", [_output class]);
	XCTAssert(![_output isKindOfClass:[NSMutableOrderedSet class]], @"output is wrong type (%@) !", [_output class]);
	
	_output = [_input ase_MutableOrderedSetMappedWithBlock:^id(id object, NSUInteger index, BOOL *stop) {
		return object;
	}];
	XCTAssert([_output isKindOfClass:[NSOrderedSet class]], @"output is wrong type (%@) !", [_output class]);
	XCTAssert([_output isKindOfClass:[NSMutableOrderedSet class]], @"output is wrong type (%@) !", [_output class]);
}

@end

#endif
