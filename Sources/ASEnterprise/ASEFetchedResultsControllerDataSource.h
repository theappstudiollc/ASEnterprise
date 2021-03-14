//
//  ASEFetchedResultsControllerDataSource.h
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

#import <CoreData/CoreData.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE == 1
#import <UIKit/UIKit.h>
#endif

@class ASEFetchedResultsControllerDataSource;

@protocol ASEFetchedResultsControllerDataSourceDelegate <NSObject>

@optional
- (void)dataSource:(__kindof ASEFetchedResultsControllerDataSource*)dataSource producedError:(NSError*)error;
- (void)dataSource:(__kindof ASEFetchedResultsControllerDataSource*)dataSource producedException:(NSException*)exception;
- (void)dataSourceWillStartChangingContent:(__kindof ASEFetchedResultsControllerDataSource*)dataSource;
- (void)dataSourceDidFinishChangingContent:(__kindof ASEFetchedResultsControllerDataSource*)dataSource;

@end

/** Returns an NSFetchedResultsController that will act as the data source to the table view */
API_AVAILABLE(macos(10.12))
typedef NSFetchedResultsController*(^ASEFetchedResultsControllerBlock)(void);

/** Abstact class that enables a NSFetchedResultsController to become a dataSource. Subclasses are responsible for implementing the NSFetchedResultsControllerDelegate. */
#if TARGET_OS_IPHONE == 1
#if TARGET_OS_WATCH
@interface ASEFetchedResultsControllerDataSource : NSObject <NSFetchedResultsControllerDelegate> {
#else
@interface ASEFetchedResultsControllerDataSource : NSObject <NSFetchedResultsControllerDelegate, UIDataSourceModelAssociation> {
#endif
#else
	API_AVAILABLE(macos(10.12))
	@interface ASEFetchedResultsControllerDataSource : NSObject <NSFetchedResultsControllerDelegate> {
#endif
	@protected
	/** Provided so that subclasses may access this block without forcing a load. */
	NSFetchedResultsController* _fetchedResultsController;
}

@property (weak, nonatomic) id<ASEFetchedResultsControllerDataSourceDelegate> delegate;
/** Loads the controller if not loaded */
@property (readonly, nonatomic) NSFetchedResultsController* fetchedResultsController;
/** Subclasses must override to enable change tracking. Default is NO. */
@property (readonly, nonatomic) BOOL trackResults;

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithFetchedResultsControllerBlock:(ASEFetchedResultsControllerBlock)fetchedResultsControllerBlock NS_DESIGNATED_INITIALIZER;
/** Causes a need to reload next time by clearing fetchedResultsController. Subclasses should call super at the end of their overrides */
- (void)setNeedsReload NS_REQUIRES_SUPER;

@end
