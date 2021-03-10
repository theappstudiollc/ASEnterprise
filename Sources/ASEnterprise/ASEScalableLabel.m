//
//  ASEScalableLabel.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/26/18.
//  Copyright © 2018 The App Studio LLC. All rights reserved.
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

#import "ASEScalableLabel.h"

@interface ASEScalableLabel ()

@property (nonatomic) UIFontTextStyle scalableTextStyle;

@end

@implementation ASEScalableLabel
#pragma mark - UILabel overrides

- (instancetype)init {
	self = [super init];
	self.scalableTextStyle = UIFontTextStyleBody;
	return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	self.scalableTextStyle = UIFontTextStyleBody;
	return self;
}

- (instancetype)initWithCoder:(NSCoder*)aDecoder {
	self = [super initWithCoder:aDecoder];
	self.scalableTextStyle = UIFontTextStyleBody;
	return self;
}

- (void)setFont:(UIFont*)font {
	@try {
		UIFontMetrics* fontMetrics = [UIFontMetrics metricsForTextStyle:_scalableTextStyle];
		[super setFont:[fontMetrics scaledFontForFont:font]];
	} @catch (NSException* exception) {
		NSLog(@"%@ exception setting font: %@", [self class], exception);
		[super setFont:font];
	}
}

#pragma mark - Public methods

- (instancetype)initWithScalableTextStyle:(UIFontTextStyle)scalableTextStyle {
	self = [super init];
	self.scalableTextStyle = scalableTextStyle;
	return self;
}

@end

#endif
