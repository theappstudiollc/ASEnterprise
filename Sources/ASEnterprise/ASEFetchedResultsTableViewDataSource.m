//
//  ASEFetchedResultsTableViewDataSource.m
//  ASEnterprise
//
//  Created by David Mitchell on 8/6/15.
//  Copyright (c) 2015 The App Studio LLC.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_WATCH)

#import "ASEFetchedResultsTableViewDataSource.h"

@interface ASEFetchedResultsTableViewDataSource ()

@property (nonatomic) IBOutlet UITableView* tableView;

@end

@implementation ASEFetchedResultsTableViewDataSource
#pragma mark - ASEFetchedResultsControllerDataSource overrides

@dynamic delegate;

#pragma mark - Public properties and methods

- (instancetype)init {
	self = [super initWithFetchedResultsControllerBlock:NULL];
	[self setupWithTableView:nil];
	return self;
}

- (instancetype)initWithTableView:(UITableView*)tableView {
	self = [super initWithFetchedResultsControllerBlock:NULL];
	[self setupWithTableView:tableView];
	return self;
}

- (instancetype)initWithTableView:(UITableView*)tableView andFetchedResultsControllerBlock:(ASEFetchedResultsControllerBlock)fetchedResultsControllerBlock {
	self = [super initWithFetchedResultsControllerBlock:fetchedResultsControllerBlock];
	[self setupWithTableView:tableView];
	return self;
}

- (void)setTableView:(UITableView*)tableView {
	_tableView.dataSource = nil;
	tableView.dataSource = self;
	_tableView = tableView;
}

- (void)reloadIfNeeded {
	if (!_fetchedResultsController) {
		[self.tableView reloadData];
	}
}

#pragma mark - Private properties and methods

- (void)setupWithTableView:(UITableView*)tableView {
	self.tableView = tableView;
}

#pragma mark - <NSFetchedResultsControllerDelegate> properties and methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
	if ([self.delegate respondsToSelector:@selector(dataSourceWillStartChangingContent:)]) {
		[self.delegate dataSourceWillStartChangingContent:self];
	}
	[self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {
	UITableViewRowAnimation rowAnimation = UITableViewRowAnimationAutomatic;
	if ([self.delegate respondsToSelector:@selector(dataSource:rowAnimationForChangeType:forObject:)]) {
		if (type == NSFetchedResultsChangeMove && [indexPath isEqual:newIndexPath]) {
			rowAnimation = [self.delegate dataSource:self rowAnimationForChangeType:NSFetchedResultsChangeUpdate forObject:anObject];
		} else {
			rowAnimation = [self.delegate dataSource:self rowAnimationForChangeType:type forObject:anObject];
		}
	}
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:rowAnimation];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
			break;
		case NSFetchedResultsChangeUpdate:
			[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
			break;
		case NSFetchedResultsChangeMove:
			if ([indexPath isEqual:newIndexPath]) {
				[self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:rowAnimation];
			} else {
				[self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
			}
			break;
	}
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	UITableViewRowAnimation rowAnimation = UITableViewRowAnimationAutomatic;
	if ([self.delegate respondsToSelector:@selector(dataSource:rowAnimationForChangeType:forSectionIndex:)]) {
		rowAnimation = [self.delegate dataSource:self rowAnimationForChangeType:type forSectionIndex:sectionIndex];
	}
	switch(type) {
		case NSFetchedResultsChangeInsert:
			[self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
			break;
		case NSFetchedResultsChangeDelete:
			[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
			break;
		case NSFetchedResultsChangeUpdate: // This is not supposed to occur, but we know how to handle it if it did
			[self.tableView reloadSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:rowAnimation];
			break;
			/* TODO: Support this if it ever becomes possible (e.g. examining sectionInfo in addition to sectionIndex)
		case NSFetchedResultsChangeMove:
			[self.tableView moveSection:sectionIndex toSection:sectionIndex];
			break;
			*/
		default:
			NSAssert(false, @"unsupported section change type: %lu", (unsigned long)type);
			break;
	}
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	[self.tableView endUpdates];
	if ([self.delegate respondsToSelector:@selector(dataSourceDidFinishChangingContent:)]) {
		[self.delegate dataSourceDidFinishChangingContent:self];
	}
}

#pragma mark - <UIDataSourceModelAssociation> methods

- (NSString*)modelIdentifierForElementAtIndexPath:(NSIndexPath*)indexPath inView:(UIView*)view {
	NSAssert(view == self.tableView, @"Method call is supposed to be for this UITableView only");
	return [super modelIdentifierForElementAtIndexPath:indexPath inView:view];
}

- (NSIndexPath*)indexPathForElementWithModelIdentifier:(NSString*)identifier inView:(UIView*)view {
	NSAssert(view == self.tableView, @"Method call is supposed to be for this UITableView only");
	return [super indexPathForElementWithModelIdentifier:identifier inView:view];
}

#pragma mark - <UITableViewDataSource> properties and methods

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath {
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView {
	return (NSInteger)[[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:(NSUInteger)section];
	return (NSInteger)[sectionInfo numberOfObjects];
}

@end

#endif
