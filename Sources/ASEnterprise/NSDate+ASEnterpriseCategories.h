//
//  NSDate+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/19/13.
//  Copyright (c) 2013 The App Studio LLC.
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

@interface NSDate (ASEnterpriseCategories)

typedef NS_ENUM(NSInteger, ASEHistoryFormat) {
	ASEHistoryFormatPost,
	ASEHistoryFormatText,
};

@property (readonly, copy, NS_NONATOMIC_IOSONLY) NSDate* ase_DateValue;
@property (readonly, copy, NS_NONATOMIC_IOSONLY) NSDate* ase_TimeValue;

+ (instancetype)ase_DateFromUnixTimestamp:(NSNumber*)timestamp;
- (NSInteger)ase_NumberOfDaysSince:(NSDate*)date;
- (NSString*)ase_StringWithFormat:(NSString*)format;
- (NSString*)ase_StringWithFormat:(NSString*)format inLocale:(NSString*)locale;
- (NSString*)ase_StringWithHistoryFormat:(ASEHistoryFormat)format;

@end
