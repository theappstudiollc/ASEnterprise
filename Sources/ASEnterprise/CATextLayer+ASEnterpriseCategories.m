//
//  CATextLayer+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 1/14/15.
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

#import "CATextLayer+ASEnterpriseCategories.h"

#if !TARGET_OS_WATCH

#import <CoreText/CoreText.h>

@implementation CATextLayer (ASEnterpriseCategories)

- (NSAttributedString*)ase_AttributedString {

	// Return string if self.string is nil or already attributed
	if (self.string == nil || [self.string isKindOfClass:[NSAttributedString class]]) {
		return self.string;
	}

	// Otherwise create one based on this instance's properties
	CFMutableAttributedStringRef attrString = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0);
	// First set the string
	CFAttributedStringReplaceString (attrString, CFRangeMake(0, 0), (CFStringRef)self.string);
	// Next set the color
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTForegroundColorAttributeName, self.foregroundColor);
	// Now set the font and font size
	CFStringRef fontName = CTFontCopyPostScriptName(self.font);
	if (fontName != NULL) {
		CTFontRef fontRef = CTFontCreateWithName(fontName, self.fontSize, NULL);
		if (fontRef != NULL)
		{
			CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, fontRef);
			CFRelease(fontRef);
		} else { // This is a fallback
			CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, self.font);
		}
		CFRelease(fontName);
	} else { // This is a fallback
		CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTFontAttributeName, self.font);
	}
	// Set the alignment
	CTTextAlignment alignment;
	if ([self.alignmentMode isEqualToString:kCAAlignmentLeft]) {
		alignment = kCTTextAlignmentLeft;
	} else if ([self.alignmentMode isEqualToString:kCAAlignmentRight]) {
		alignment = kCTTextAlignmentRight;
	} else if ([self.alignmentMode isEqualToString:kCAAlignmentCenter]) {
		alignment = kCTTextAlignmentCenter;
	} else if ([self.alignmentMode isEqualToString:kCAAlignmentJustified]) {
		alignment = kCTTextAlignmentJustified;
	} else if ([self.alignmentMode isEqualToString:kCAAlignmentNatural]) {
		alignment = kCTTextAlignmentNatural;
	}
	CTParagraphStyleSetting settings[] = {kCTParagraphStyleSpecifierAlignment, sizeof(alignment), &alignment};
	CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(settings, sizeof(settings) / sizeof(settings[0]));
	CFAttributedStringSetAttribute(attrString, CFRangeMake(0, CFAttributedStringGetLength(attrString)), kCTParagraphStyleAttributeName, paragraphStyle);
	CFRelease(paragraphStyle);

	return [[NSAttributedString alloc] initWithAttributedString:CFBridgingRelease(attrString)];
}

@end

#endif
