//
//  NSDate+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/19/13.
//  Copyright (c) 2013 The App Studio LLC. All rights reserved.
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

#import "NSDate+ASEnterpriseCategories.h"

@implementation NSDate (ASEnterpriseCategories)

///////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods -
///////////////////////////////////////////////////////////////////////////

+ (instancetype)ase_DateFromUnixTimestamp:(NSNumber*)timestamp {
	if (timestamp != nil) {
		CFNumberType numberType = CFNumberGetType((CFNumberRef)timestamp);
		if (numberType == kCFNumberSInt64Type || numberType == kCFNumberLongLongType) {
			NSTimeInterval timeInterval = [timestamp longLongValue];
			return [self dateWithTimeIntervalSince1970:timeInterval];
		}
		else if (numberType == kCFNumberDoubleType) {
			NSTimeInterval timeInterval = [timestamp doubleValue];
			return [self dateWithTimeIntervalSince1970:timeInterval / 1000.0];
		}
		else if (numberType == kCFNumberLongType) {
			NSTimeInterval timeInterval = [timestamp longValue];
			return [self dateWithTimeIntervalSince1970:timeInterval];
		}
	}
	return nil;
}

- (NSDate*)ase_DateValue {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSUInteger components = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
	NSDateComponents* dateComponents = [calendar components:components fromDate:self];
	return [calendar dateFromComponents:dateComponents];
}

- (NSInteger)ase_NumberOfDaysSince:(NSDate*)date {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSDateComponents* components = [calendar components:NSCalendarUnitDay fromDate:date toDate:self options:0];
    return [components day];
}

- (NSString*)ase_StringWithFormat:(NSString*)format {
	return [self ase_StringWithFormat:format inLocale:@"en-US"];
}

- (NSString*)ase_StringWithFormat:(NSString*)format inLocale:(NSString*)locale {
	NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
	NSLocale* dateLocale = [[NSLocale alloc] initWithLocaleIdentifier:locale];
	[dateFormatter setLocale:dateLocale];
	[dateFormatter setDateFormat:format];
	NSString* retVal = [dateFormatter stringFromDate:self];
	return retVal;
}

- (NSString*)ase_StringWithHistoryFormat:(ASEHistoryFormat)format {
	switch (format)
	{
		case ASEHistoryFormatPost:
			return [self ase_StringWithHistoryPostFormat];
		case ASEHistoryFormatText:
			return [self ase_StringWithHistoryTextFormat];
	}
	return nil;
}

- (NSDate*)ase_TimeValue {
	NSCalendar* calendar = [NSCalendar currentCalendar];
	NSUInteger components = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
	NSDateComponents* timeComponents = [calendar components:components fromDate:self];
	return [calendar dateFromComponents:timeComponents];
}

///////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods -
///////////////////////////////////////////////////////////////////////////

- (NSString*)ase_StringWithHistoryPostFormat {
	const NSTimeInterval perMinute = 60.0;
	const NSTimeInterval perHour = perMinute * 60.0;
	const NSTimeInterval perDay = perHour * 24.0;
	const NSTimeInterval perWeek = perDay * 7.0;
	
	NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:self];
	if (interval < perMinute) {
		return @"A few seconds ago";
	}
	else if (interval < perHour) {
		NSUInteger minutes = (NSUInteger)floor(interval / perMinute);
		if (minutes == 1) {
			return @"1 minute ago";
		}
		return [NSString stringWithFormat:@"%lu minutes ago", (unsigned long)minutes];
	}
	else if (interval < perDay) {
		NSUInteger hours = (NSUInteger)floor(interval / perHour);
		if (hours == 1) {
			return @"1 hour ago";
		}
		return [NSString stringWithFormat:@"%lu hours ago", (unsigned long)hours];
	}
	else if (interval < perWeek) {
		NSUInteger days = (NSUInteger)floor(interval / perDay);
		if (days == 1) {
			return @"1 day ago";
		}
		return [NSString stringWithFormat:@"%lu days ago", (unsigned long)days];
	}
	NSUInteger weeks = (NSUInteger)floor(interval / perWeek);
	if (weeks == 1) {
		return @"1 week ago";
	}
	return [NSString stringWithFormat:@"%lu weeks ago", (unsigned long)weeks];
}

- (NSString*)ase_StringWithHistoryTextFormat {
	NSDate* now = [NSDate date];
	NSInteger numberOfDaysSince = [now ase_NumberOfDaysSince:self];
	
	if (numberOfDaysSince <= 0) {
		return [self ase_StringWithFormat:@"h:mm aa"];
	}
	else if (numberOfDaysSince == 1) {
		return @"Yesterday";
	}
	else if (numberOfDaysSince > 1 && numberOfDaysSince < 7) {
		return [self ase_StringWithFormat:@"EEEE"];
	}
	return [self ase_StringWithFormat:@"M/d/yy"];
}

@end
