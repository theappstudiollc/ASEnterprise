//
//  ASEWeakMutableArray.m
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

#import "ASEWeakMutableArray.h"
#import "ASEWeakReference.h"

@interface ASEWeakMutableArray ()

@property (nonatomic) NSUInteger capacity;
@property (nonatomic) NSUInteger count;

@end

@implementation ASEWeakMutableArray
{
	id __strong * _pointer;
	unsigned long _mutations;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods -
////////////////////////////////////////////////////////////////////////////////

- (NSArray*)allObjects {
	NSMutableArray* retVal = [[NSMutableArray alloc] initWithCapacity:_capacity];
	for (id object in self) {
		[retVal addObject:object];
	}
	return [NSArray arrayWithArray:retVal];
}

- (void)cleanWeakReferences {
	// Remove all blocks that reference deallocated weak objects
	@autoreleasepool {
		// There are retains that ARC autoreleases inside here...
		for (NSUInteger i = 0; i < _count; i++) {
			id weakReference = _pointer[i];
			id storedObject = ASEObjectFromWeakReference(weakReference);
			if (!storedObject) {
				_mutations++;
				// Slide everyone down one slot. Make sure to decrement i.
				for (NSUInteger j = i--; j < _count; j++) {
					_pointer[j] = (j == _count - 1) ? nil : _pointer[j+1];
				}
				_count--;
			}
		}
	}
}

- (NSUInteger)countByAddingObject:(id)object {
	// Do we need to increase capacity to add this object?
	_mutations++;
	if (_count >= _capacity) {
		_capacity += 16;
		id __strong * newPointer = (id __strong *)(calloc(sizeof(id), _capacity));
		for (NSUInteger i = 0; i < _count; i++) {
			newPointer[i] = _pointer[i];
			_pointer[i] = nil; // To allow free to work properly
		}
		if (_pointer) free(_pointer);
		_pointer = newPointer;
	}
	// Wrap the object into a block that returns a weak reference to the object
	_pointer[_count++] = ASEMakeWeakReference(object);
	return _count;
}

- (NSUInteger)countByRemovingObject:(id)object {
	@autoreleasepool {
		// There are retains that ARC autoreleases inside here...
		_mutations++;
		for (NSUInteger i = 0; i < _count; i++) {
			id weakReference = _pointer[i];
			id storedObject = ASEObjectFromWeakReference(weakReference);
			if ([storedObject isEqual:object]) {
				// Slide everyone down one slot. Make sure to decrement i.
				for (NSUInteger j = i--; j < _count; j++) {
					_pointer[j] = (j == _count - 1) ? nil : _pointer[j+1];
				}
				_count--;
			}
		}
	}
	return _count;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSFastEnumeration methods -
////////////////////////////////////////////////////////////////////////////////

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState*)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len {
	state->itemsPtr = buffer;
	state->mutationsPtr = _allowMutations ? &state->extra[0] : &_mutations;
	
	NSUInteger retVal = 0;
	@autoreleasepool {
		// There are retains that ARC autoreleases inside here...
		while (state->state < _count && retVal < len) {
			id weakReference = _pointer[state->state++];
			id storedObject = ASEObjectFromWeakReference(weakReference);
			if (storedObject) {
				buffer[retVal++] = storedObject;
			}
		}
	}
	return retVal;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark - NSMutableArray overrides -
////////////////////////////////////////////////////////////////////////////////

+ (instancetype)arrayWithArray:(NSArray*)array {
	return [[self alloc] initWithArray:array];
}

- (void)addObject:(id)object {
	[self countByAddingObject:object];
}

- (void)addObjectsFromArray:(NSArray*)array {
	for (id object in array) {
		[self addObject:object];
	}
}

- (BOOL)containsObject:(id)anObject {
	@autoreleasepool {
		// There are retains that ARC autoreleases inside here...
		for (NSUInteger i = 0; i < _count; i++) {
			id weakReference = _pointer[i];
			id storedObject = ASEObjectFromWeakReference(weakReference);
			if ([storedObject isEqual:anObject]) {
				return YES;
			}
		}
		return NO;
	}
}

- (NSUInteger)count {
	[self cleanWeakReferences];
	return _count;
}

- (void)dealloc {
	if (_pointer) {
		for (NSUInteger i = 0; i < _count; i++) {
			_pointer[i] = nil;
		}
		free(_pointer);
	}
}

- (instancetype)init {
	self = [self initWithCapacity:16];
	return self;
}

- (instancetype)initWithArray:(NSArray*)array {
	self = [self initWithCapacity:[array count]];
	[self addObjectsFromArray:array];
	return self;
}

- (instancetype)initWithCapacity:(NSUInteger)capacity {
	self = [super init];
	_capacity = capacity;
	_mutations = 0;
	_pointer = (id __strong *)(calloc(sizeof(id), _capacity));
	return self;
}

- (instancetype)initWithObjects:(id)firstObj, ... {
	self = [self initWithCapacity:16];
	va_list args;
	va_start(args, firstObj);
	id arg = firstObj;
	do {
		[self addObject:arg];
	} while ((arg = va_arg(args, id)));
	va_end(args);
	return self;
}

- (id)objectAtIndex:(NSUInteger)index {
	@autoreleasepool {
		// There are retains that ARC autoreleases inside here...
		NSUInteger counted = 0, pointerIndex = 0;
		while (pointerIndex < _count && counted <= index) {
			id weakReference = _pointer[pointerIndex++];
			id storedObject = ASEObjectFromWeakReference(weakReference);
			if (storedObject && index == counted++) {
				return storedObject;
			}
		}
	}
	return nil;
}

- (id)objectAtIndexedSubscript:(NSUInteger)idx {
	return [self objectAtIndex:idx];
}

- (void)removeObject:(id)object {
	[self countByRemovingObject:object];
}

////////////////////////////////////////////////////////////////////////////////
@end
