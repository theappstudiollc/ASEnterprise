//
//  ASWeakMutableArrayTests.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/19/14.
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
#import "Supporting Classes/ASEWrappedInteger.h"

#define DEMO_AUTORELEASE_FAIL 0

@interface ASWeakMutableArrayTests : XCTestCase

@end

@implementation ASWeakMutableArrayTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (NSMutableArray*)popuplatedArray {
	const NSInteger capacity = 30;
	// retVal will retain a reference to all objects we create. However,
	// with ARC, there are two different ways to create objects for our
	// set that leave retains exactly the same when leaving.
	NSMutableArray* retVal = [NSMutableArray arrayWithCapacity:capacity];
#if DEMO_AUTORELEASE_FAIL
	@autoreleasepool {
		for (NSInteger i = 1; i <= capacity; i++) {
			// convenience constructors require @autoreleasepool
			// because ARC returns autoreleased objects
			[retVal addObject:[ASEWrappedInteger wrappedInteger:i]];
		}
	}
#else
	for (NSInteger i = 1; i <= capacity; i++) {
		// No @autoreleasepool needed with alloc/init because ARC releases
		[retVal addObject:[[ASEWrappedInteger alloc] initWithInteger:i]];
	}
#endif
	// At this point all SRWrappedInteger instances have exactly
	// 1 retain count and are not in the autorelease pool.
	return retVal;
}

- (NSUInteger)countByEnumerating:(id<NSFastEnumeration>)enumerator {
	return [self countByEnumerating:enumerator breakAt:0];
}

- (NSUInteger)countByEnumerating:(id<NSFastEnumeration>)enumerator breakAt:(NSUInteger)breakAt {
	NSUInteger retVal = 0;
	for (ASEWrappedInteger* __unused wrapperInteger in enumerator) {
		retVal++;
		if (breakAt > 0 && --breakAt == 0) break;
	}
	return retVal;
}

- (void)testAutoreleasing {
	NSMutableArray* strongArray = [self popuplatedArray];
	ASEWeakMutableArray* weakArray = [ASEWeakMutableArray arrayWithArray:strongArray];
	
	// Test that objects are removed by calling count
	XCTAssertTrue([weakArray count] == [strongArray count], @"weakArray count doesn't match");
	[strongArray removeObject:[strongArray lastObject]];
	XCTAssertTrue([weakArray count] == [strongArray count], @"weakArray didn't remove object");
	[strongArray removeAllObjects];
	XCTAssertTrue([weakArray count] == [strongArray count], @"weakArray didn't remove objects");
}

- (void)testVarArgsConstruction {
	NSMutableArray* strongArray = [self popuplatedArray];
	ASEWeakMutableArray* weakArray = [[ASEWeakMutableArray alloc] initWithObjects:
									  strongArray[0],
									  strongArray[1],
									  strongArray[2],
									  strongArray[3], nil];
	XCTAssertTrue([weakArray count] == 4, @"weakArray didn't add all of the objects");
}

- (void)testEnumeration {
	NSMutableArray* strongArray = [self popuplatedArray];
	ASEWeakMutableArray* weakArray = [ASEWeakMutableArray arrayWithArray:strongArray];
	
	// Test that both classes enumerate with the same count
	NSUInteger strongCount = [self countByEnumerating:strongArray];
	NSUInteger weakCount = [self countByEnumerating:weakArray];
	XCTAssertTrue(weakCount == strongCount, @"weakArray(%lu) enumerated differently than strongArray(%lu)", (unsigned long)weakCount, (unsigned long)strongCount);
	
	// Test retains by enumerations by breaking early
	NSUInteger halfCount = weakCount / 2;
	XCTAssertEqual([self countByEnumerating:weakArray breakAt:halfCount], halfCount, @"BreakOut test did not work: %lu", (unsigned long)halfCount);
	
	// Now test by removing an equal object
	[strongArray removeObject:[ASEWrappedInteger wrappedInteger:2]];
	XCTAssertTrue(strongCount > [strongArray count], @"strongArray did not remove ASWrappedInteger");
	
	// Finally, verify that the equal object was removed in both collections
	strongCount = [self countByEnumerating:strongArray];
	weakCount = [self countByEnumerating:weakArray];
	XCTAssertTrue(weakCount == strongCount, @"weakArray(%lu) enumerated differently than strongArray(%lu) : %lu", (unsigned long)weakCount, (unsigned long)strongCount, (unsigned long)[weakArray count]);
}

@end

#endif
