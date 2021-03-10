//
//  ASEAsynchronousOperation.h
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASEAsynchronousOperation : NSOperation

typedef void(^ASEAsynchronousOperationFinishBlock)(__kindof ASEAsynchronousOperation* operation);

/** Adds an optional block that will be performed at the end of finish. */
- (void)addFinishBlock:(ASEAsynchronousOperationFinishBlock)finishBlock;

/** Sets the receiver as a dependency to the specified operation, and provides an optional block that is invoked after the receiver is finished and before the specified operation begins. Subclasses with specializations are encouraged to add their own version of this method. */
- (void)bridgeToOperation:(NSOperation*)operation withBlock:(nullable ASEAsynchronousOperationFinishBlock)block;

/** Call sometime after your startAsynchronously implementation to finish the operation. All paths, including cancellation, must lead to finish, otherwise the operation will forever consume its operation queue. This class' implementation of start already calls finish if the operation is cancelled before it begins. */
- (void)finish;

/** Since this is an asynchronous operation, no work should be done in main */
- (void)main NS_UNAVAILABLE;

/** NSOperation's start method is to be called by the NSOperationQueue only. Subclasses MUST call super if overridden. */
- (void)start NS_REQUIRES_SUPER;

@end

@interface ASEAsynchronousOperation (AbstractMethods)

/** Required override that implements the operation. DO NOT call super */
- (void)startAsynchronously;

@end

NS_ASSUME_NONNULL_END
