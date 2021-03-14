//
//  ASEFetchedResultsCollectionViewDataSource.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/17/15.
//  Copyright © 2015 The App Studio LLC.
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

#import "ASEFetchedResultsCollectionViewDataSource.h"

@interface ASEFetchedResultsCollectionViewDataSource ()

@property (nonatomic) NSMutableArray* fetchedResultSectionChanges;
@property (nonatomic) NSMutableArray* fetchedResultItemChanges;

@end

@implementation ASEFetchedResultsCollectionViewDataSource
#pragma mark - Public properties and methods

- (instancetype)init {
	self = [super initWithFetchedResultsControllerBlock:NULL];
	[self setupWithCollectionView:nil];
	return self;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView {
	self = [super initWithFetchedResultsControllerBlock:NULL];
	[self setupWithCollectionView:collectionView];
	return self;
}

- (instancetype)initWithCollectionView:(UICollectionView*)collectionView andFetchedResultsControllerBlock:(ASEFetchedResultsControllerBlock)fetchedResultsControllerBlock {
	self = [super initWithFetchedResultsControllerBlock:fetchedResultsControllerBlock];
	[self setupWithCollectionView:collectionView];
	return self;
}

- (void)setCollectionView:(UICollectionView*)collectionView {
	_collectionView.dataSource = nil;
	collectionView.dataSource = self;
	_collectionView = collectionView;
}

- (void)reloadIfNeeded {
	if (!_fetchedResultsController) {
		[self.collectionView reloadData];
	}
}

#pragma mark - Private properties and methods

- (void)setupWithCollectionView:(UICollectionView*)collectionView {
	self.collectionView = collectionView;
}

#pragma mark - <NSFetchedResultsControllerDelegate> methods

- (void)controllerWillChangeContent:(NSFetchedResultsController*)controller {
	_fetchedResultSectionChanges = [[NSMutableArray alloc] init];
	_fetchedResultItemChanges = [[NSMutableArray alloc] init];
	if ([self.delegate respondsToSelector:@selector(dataSourceWillStartChangingContent:)]) {
		[self.delegate dataSourceWillStartChangingContent:self];
	}
}

- (void)controller:(NSFetchedResultsController*)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
	[_fetchedResultSectionChanges addObject:@ {
		@(type) : @(sectionIndex),
	}];
}

- (void)controller:(NSFetchedResultsController*)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath*)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath*)newIndexPath {
	NSMutableDictionary* change = [[NSMutableDictionary alloc] initWithCapacity:1];
	switch(type) {
		case NSFetchedResultsChangeInsert:
			change[@(type)] = newIndexPath;
			break;
		case NSFetchedResultsChangeDelete:
		case NSFetchedResultsChangeUpdate:
			change[@(type)] = indexPath;
			break;
		case NSFetchedResultsChangeMove:
			change[@(type)] = @[indexPath, newIndexPath];
			break;
	}
	[_fetchedResultItemChanges addObject:change];
}

- (void)controllerDidChangeContent:(NSFetchedResultsController*)controller {
	[self.collectionView performBatchUpdates:^{
		for (NSDictionary* change in self->_fetchedResultSectionChanges) {
			[change enumerateKeysAndObjectsUsingBlock:^(id key, id sectionIndex, BOOL* stop) {
				NSFetchedResultsChangeType type = [key unsignedIntegerValue];
				switch(type) {
					case NSFetchedResultsChangeInsert:
						[self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[sectionIndex unsignedIntegerValue]]];
						break;
					case NSFetchedResultsChangeDelete:
						[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[sectionIndex unsignedIntegerValue]]];
						break;
					default:
						NSAssert(false, @"unsupported section change type: %lu", (unsigned long)type);
						break;
				}
			}];
		}
		for (NSDictionary* change in self->_fetchedResultItemChanges) {
			[change enumerateKeysAndObjectsUsingBlock:^(id key, id indexPath, BOOL* stop) {
				NSFetchedResultsChangeType type = [key unsignedIntegerValue];
				switch(type) {
					case NSFetchedResultsChangeInsert:
						[self.collectionView insertItemsAtIndexPaths:@[indexPath]];
						break;
					case NSFetchedResultsChangeDelete:
						[self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
						break;
					case NSFetchedResultsChangeUpdate:
						[self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
						break;
					case NSFetchedResultsChangeMove:
						if ([indexPath[0] isEqual:indexPath[1]]) {
							[self.collectionView reloadItemsAtIndexPaths:@[indexPath[0]]];
						} else {
							[self.collectionView moveItemAtIndexPath:indexPath[0] toIndexPath:indexPath[1]];
						}
						break;
				}
			}];
		}
	} completion:^(BOOL finished) {
		self->_fetchedResultSectionChanges = nil;
		self->_fetchedResultItemChanges = nil;
		if ([self.delegate respondsToSelector:@selector(dataSourceDidFinishChangingContent:)]) {
			[self.delegate dataSourceDidFinishChangingContent:self];
		}
	}];
}

#pragma mark - <UICollectionViewDataSource> methods

- (UICollectionViewCell*)collectionView:(UICollectionView*)collectionView cellForItemAtIndexPath:(NSIndexPath*)indexPath {
	[self doesNotRecognizeSelector:_cmd];
	__builtin_unreachable();
}

- (NSInteger)collectionView:(UICollectionView*)collectionView numberOfItemsInSection:(NSInteger)section {
	id<NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:(NSUInteger)section];
	return (NSInteger)[sectionInfo numberOfObjects];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView {
	return (NSInteger)[[self.fetchedResultsController sections] count];
}

#pragma mark - <UIDataSourceModelAssociation> methods

- (NSString*)modelIdentifierForElementAtIndexPath:(NSIndexPath*)indexPath inView:(UIView*)view {
	NSAssert(view == self.collectionView, @"Method call is supposed to be for this UICollectionView only");
	return [super modelIdentifierForElementAtIndexPath:indexPath inView:view];
}

- (NSIndexPath*)indexPathForElementWithModelIdentifier:(NSString*)identifier inView:(UIView*)view {
	NSAssert(view == self.collectionView, @"Method call is supposed to be for this UICollectionView only");
	return [super indexPathForElementWithModelIdentifier:identifier inView:view];
}

@end

#endif
