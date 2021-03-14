//
//  NSString+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 5/22/15.
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

#import "NSString+ASEnterpriseCategories.h"
#import <tgmath.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#elif TARGET_OS_MAC
#import <AppKit/AppKit.h>
#endif

ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsAlignment = @"ASEParagraphAlignment";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsBaselineAdjustment = @"ASEBaselineAdjustment";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsCharacterSpacing = @"ASECharacterSpacing";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsForegroundColor = @"ASEForegroundColor";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsFont = @"ASEFont";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsLineBreak = @"ASELineBreak";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsLineHeight = @"ASELineHeight";
ASE_ATTRIBUTED_TEXT_OPTIONS const kASETextOptionsLineSpacing = @"ASELineSpacing";

@implementation NSString (ASEnterpriseCategories)

- (NSAttributedString*)ase_AttributedStringWithOptions:(NSDictionary<ASE_ATTRIBUTED_TEXT_OPTIONS,id>*)options {
	NSAssert(options[kASETextOptionsFont], @"Font not provided");
	
	NSNumber* textAlignment = options[kASETextOptionsAlignment] ?: @(NSTextAlignmentCenter);
#if TARGET_OS_IPHONE
	UIFont* font = options[kASETextOptionsFont];
#elif TARGET_OS_MAC
	NSFont* font = options[kASETextOptionsFont];
#endif
	
	NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
#if TARGET_OS_IPHONE
	paragraphStyle.alignment = [textAlignment integerValue];
#elif TARGET_OS_MAC
	paragraphStyle.alignment = [textAlignment integerValue];
#endif
	NSNumber* lineHeight = options[kASETextOptionsLineHeight];
	if (lineHeight != nil) {
#if CGFLOAT_IS_DOUBLE
		paragraphStyle.maximumLineHeight = [lineHeight doubleValue];
#else
		paragraphStyle.maximumLineHeight = [lineHeight floatValue];
#endif
	} else {
		paragraphStyle.maximumLineHeight = ceil(font.ascender - font.descender);
	}
	paragraphStyle.minimumLineHeight = paragraphStyle.maximumLineHeight;
	NSNumber* lineSpacing = options[kASETextOptionsLineSpacing];
	if (lineSpacing != nil) {
#if CGFLOAT_IS_DOUBLE
		paragraphStyle.lineSpacing = [lineSpacing doubleValue];
#else
		paragraphStyle.lineSpacing = [lineSpacing floatValue];
#endif
	}
	NSNumber* lineBreak = options[kASETextOptionsLineBreak];
	if (lineBreak != nil) {
#if TARGET_OS_IPHONE
		paragraphStyle.lineBreakMode = [lineBreak integerValue];
#elif TARGET_OS_MAC
		paragraphStyle.lineBreakMode = [lineBreak unsignedIntegerValue];
#endif
	}
	
	NSAttributedString* attributedText = [[NSAttributedString alloc] initWithString:self attributes:@ {
		NSBaselineOffsetAttributeName : options[kASETextOptionsBaselineAdjustment] ?: @(0.0),
#if TARGET_OS_IPHONE
		NSForegroundColorAttributeName : options[kASETextOptionsForegroundColor] ?: [UIColor blackColor],
#elif TARGET_OS_MAC
		NSForegroundColorAttributeName : options[kASETextOptionsForegroundColor] ?: [NSColor blackColor],
#endif
		NSFontAttributeName : font,
		NSKernAttributeName : options[kASETextOptionsCharacterSpacing] ?: @(0.0),
		NSParagraphStyleAttributeName : paragraphStyle,
	}];
	
	return attributedText;
}

@end
