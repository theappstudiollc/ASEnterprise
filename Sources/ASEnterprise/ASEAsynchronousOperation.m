//
//  ASEAsynchronousOperation.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/25/15.
//  Copyright © 2015 The App Studio LLC. All rights reserved.
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

#import "ASEAsynchronousOperation.h"

@interface ASEAsynchronousOperation ()

@property (nonatomic) NSMutableArray<ASEAsynchronousOperationFinishBlock>* finishBlocks;

@end

@implementation ASEAsynchronousOperation
#pragma mark - NSOperation overrides

- (instancetype)init {
	self = [super init];
	_asynchronous = YES;
	_finishBlocks = [[NSMutableArray alloc] init];
	return self;
}

- (BOOL)isAsynchronous {
	return _asynchronous;
}

- (void)start {
	self.executing = YES;
	if (self.isCancelled) {
		[self finish];
	} else {
		[self startAsynchronously];
	}
}

- (void)setExecuting:(BOOL)executing {
	NSAssert(_isExecuting != executing, @"sloppy code re-setting executing");
	if (_isExecuting == executing) return;
	[self willChangeValueForKey:@"isExecuting"];
	_isExecuting = executing;
	[self didChangeValueForKey:@"isExecuting"];
}

- (void)setFinished:(BOOL)finished {
	NSAssert(_isFinished != finished, @"sloppy code re-setting finished");
	if (_isFinished == finished) return;
	[self willChangeValueForKey:@"isFinished"];
	_isFinished = finished;
	[self didChangeValueForKey:@"isFinished"];
}

#pragma mark - Public properties and methods

@synthesize asynchronous = _asynchronous;
@synthesize executing = _isExecuting;
@synthesize finished = _isFinished;

- (void)addFinishBlock:(ASEAsynchronousOperationFinishBlock)finishBlock {
	NSParameterAssert(finishBlock);
	NSAssert(_finishBlocks != nil, @"surprise nil finishBlocks");
	[self.finishBlocks addObject:finishBlock];
}

- (void)bridgeToOperation:(NSOperation*)operation withBlock:(ASEAsynchronousOperationFinishBlock)block {
	NSParameterAssert(operation);
	[operation addDependency:self];
	if (block) {
		[self addFinishBlock:block];
	}
}

- (void)finish {
	for (ASEAsynchronousOperationFinishBlock finishBlock in self.finishBlocks) {
		finishBlock(self);
	}
	[self.finishBlocks removeAllObjects]; // Allows this class to dealloc :)
	self.executing = NO;
	self.finished = YES;
}

@end

@implementation ASEAsynchronousOperation (AbstractMethods)

- (void)startAsynchronously {
	[self doesNotRecognizeSelector:_cmd];
}

@end
