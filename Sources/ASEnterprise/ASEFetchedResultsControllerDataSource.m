//
//  ASEFetchedResultsControllerDataSource.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/17/15.
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

#import "ASEFetchedResultsControllerDataSource.h"
#import "NSObject+ASEnterpriseCategories.h"
#import "NSManagedObjectID+ASEnterpriseCategories.h"

@interface ASEFetchedResultsControllerDataSource ()

@property (copy, nonatomic) ASEFetchedResultsControllerBlock fetchedResultsControllerBlock;

@end

@implementation ASEFetchedResultsControllerDataSource
#pragma mark - NSObject overrides

- (void)dealloc {
#if TARGET_OS_IPHONE == 1 && !TARGET_OS_WATCH
	NSNotificationCenter* defaultCenter = [NSNotificationCenter defaultCenter];
	[defaultCenter removeObserver:self name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
#endif
}

- (BOOL)respondsToSelector:(SEL)aSelector {
	// NSFetchedResultsController assumes tracking is enabled when these methods are implemented
	if (!self.trackResults) {
		if (aSelector == @selector(controllerDidChangeContent:)) {
			return NO;
		}
		if (aSelector == @selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)) {
			return NO;
		}
		if (aSelector == @selector(controller:didChangeSection:atIndex:forChangeType:)) {
			return NO;
		}
		if (aSelector == @selector(controllerWillChangeContent:)) {
			return NO;
		}
	}
	return [super respondsToSelector:aSelector];
}

#pragma mark - Public properties and methods

@synthesize fetchedResultsController = _fetchedResultsController;
@synthesize fetchedResultsControllerBlock = _fetchedResultsControllerBlock;

- (NSFetchedResultsController*)fetchedResultsController {
	if (!_fetchedResultsController) {
		NSAssert(_fetchedResultsControllerBlock, @"A fetchedResultsControllerBlock must be set by this time");
		_fetchedResultsController = self.fetchedResultsControllerBlock();
		_fetchedResultsController.delegate = self;
		NSError* error = nil;
		if ([self.delegate respondsToSelector:@selector(dataSource:producedException:)]) {
			@try {
				if (![_fetchedResultsController performFetch:&error]) {
					if ([self.delegate respondsToSelector:@selector(dataSource:producedError:)]) {
						[self.delegate dataSource:self producedError:error];
					}
				}
			} @catch (NSException* exception) {
				[self.delegate dataSource:self producedException:exception];
			}
		} else {
			if (![_fetchedResultsController performFetch:&error]) {
				if ([self.delegate respondsToSelector:@selector(dataSource:producedError:)]) {
					[self.delegate dataSource:self producedError:error];
				}
			}
		}
		NSAssert(!error, @"Error fetching data: %@", error);
	}
	return _fetchedResultsController;
}

- (instancetype)initWithFetchedResultsControllerBlock:(ASEFetchedResultsControllerBlock)fetchedResultsControllerBlock {
	self = [super init];
#if TARGET_OS_IPHONE == 1 && !TARGET_OS_WATCH
	[self ase_SetSelector:@selector(didReceiveMemoryWarning:) forNotification:UIApplicationDidReceiveMemoryWarningNotification];
#endif
	self.fetchedResultsControllerBlock = fetchedResultsControllerBlock;
	return self;
}

- (void)setNeedsReload {
	_fetchedResultsController = nil;
}

- (BOOL)trackResults {
	return NO;
}

#pragma mark - Notifications

- (void)didReceiveMemoryWarning:(NSNotification*)notification {
	[self setNeedsReload]; // This effectively unloads data
}
#if TARGET_OS_IPHONE == 1 && !TARGET_OS_WATCH
#pragma mark - <UIDataSourceModelAssociation> methods

- (NSString*)modelIdentifierForElementAtIndexPath:(NSIndexPath*)indexPath inView:(UIView*)view {
	NSManagedObject* object = [self.fetchedResultsController objectAtIndexPath:indexPath];
	return [object.objectID isTemporaryID] ? nil : object.objectID.URIRepresentation.absoluteString;
}

- (NSIndexPath*)indexPathForElementWithModelIdentifier:(NSString*)identifier inView:(UIView*)view {
	NSManagedObjectContext* context = self.fetchedResultsController.managedObjectContext;
	NSURL* URIRepresentation = [NSURL URLWithString:identifier];
	NSManagedObjectID* objectID = [context.persistentStoreCoordinator managedObjectIDForURIRepresentation:URIRepresentation];
	NSManagedObject* object = [objectID ase_ManagedObjectForContext:context];
	return object ? [self.fetchedResultsController indexPathForObject:object] : nil;
}
#endif
@end
