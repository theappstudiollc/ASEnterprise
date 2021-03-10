//
//  ASEFetchedResultsTableViewDataSource.h
//  ASEnterprise
//
//  Created by David Mitchell on 8/6/15.
//  Copyright (c) 2015 The App Studio LLC. All rights reserved.
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

#import "ASEFetchedResultsControllerDataSource.h"

@class ASEFetchedResultsTableViewDataSource;

@protocol ASEFetchedResultsTableViewDataSourceDelegate <ASEFetchedResultsControllerDataSourceDelegate>

@optional
- (UITableViewRowAnimation)dataSource:(__kindof ASEFetchedResultsTableViewDataSource*)dataSource rowAnimationForChangeType:(NSFetchedResultsChangeType)changeType forObject:(id)object;
- (UITableViewRowAnimation)dataSource:(__kindof ASEFetchedResultsTableViewDataSource*)dataSource rowAnimationForChangeType:(NSFetchedResultsChangeType)changeType forSectionIndex:(NSUInteger)sectionIndex;

@end

/** Abstact class for implementing a UITableView's dataSource */
@interface ASEFetchedResultsTableViewDataSource : ASEFetchedResultsControllerDataSource <UITableViewDataSource>

@property (weak, nonatomic) id<ASEFetchedResultsTableViewDataSourceDelegate> delegate;
@property (readonly, nonatomic) UITableView* tableView;

- (instancetype)init;
- (instancetype)initWithTableView:(UITableView*)tableView;
- (instancetype)initWithTableView:(UITableView*)tableView andFetchedResultsControllerBlock:(ASEFetchedResultsControllerBlock)fetchedResultsControllerBlock;
- (void)reloadIfNeeded;

@end

@interface ASEFetchedResultsTableViewDataSource (AbstractMethods)

/** This UITableViewDataSource method must be overridden by subclasses */
- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath;

@end

#endif
