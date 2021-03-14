//
//  NSMutableAttributedString+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/30/13.
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

#import "NSMutableAttributedString+ASEnterpriseCategories.h"

@implementation NSMutableAttributedString (ASEnterpriseCategories)

- (void)ase_AppendParagraph:(NSString*)paragraph withAttributes:(NSDictionary*)attributes {
	if ([paragraph length] == 0) {
		return;
	}
	NSString* input = [[NSString alloc] initWithFormat:@"%@\r\n", paragraph];
	[self ase_AppendString:input withAttributes:attributes];
}

- (void)ase_AppendString:(NSString*)string withAttributes:(NSDictionary*)attributes {
	if ([string length] == 0) {
		return;
	}
	[self appendAttributedString:[[NSAttributedString alloc] initWithString:string attributes:attributes]];
}

- (void)ase_ReplaceOpenTags:(NSString*)openTag closeTags:(NSString*)closeTag andAddAttributes:(NSDictionary*)attributes {
	BOOL replaced = NO;
	do {
		replaced = NO;
		NSString* searchString = [self string];
		NSRange openRange = [searchString rangeOfString:openTag];
		if (openRange.location != NSNotFound) {
			NSUInteger start = openRange.location + openRange.length;
			NSRange closeRange = [searchString rangeOfString:closeTag options:0 range:NSMakeRange(start, [searchString length] - start)];
			if (closeRange.location != NSNotFound) {
				if ([attributes count]) {
					NSRange applyRange = NSMakeRange(start, closeRange.location - start);
					[self addAttributes:attributes range:applyRange];
				}
				[self replaceCharactersInRange:closeRange withString:@""];
				[self replaceCharactersInRange:openRange withString:@""];
				replaced = YES;
			}
		}
	} while (replaced);
}

#if TARGET_OS_IPHONE
- (void)ase_ApplyColor:(UIColor*)color toRange:(NSRange)range {
	if (range.location == NSNotFound) {
		return;
	}
	[self addAttribute:(NSString*)kCTForegroundColorAttributeName value:(id)color.CGColor range:range];
}

- (void)ase_ApplyFont:(UIFont*)font toRange:(NSRange)range {
	if (range.location == NSNotFound) {
		return;
	}
	CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
	if (fontRef != NULL) {
		[self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:range];
		CFRelease(fontRef);
	}
}

- (void)ase_ApplyFont:(UIFont*)font toRange:(NSRange)range withColor:(UIColor*)color {
	if (range.location == NSNotFound) {
		return;
	}
	CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)font.fontName, font.pointSize, NULL);
	if (fontRef != NULL) {
		[self addAttribute:(NSString*)kCTFontAttributeName value:(__bridge id)fontRef range:range];
		CFRelease(fontRef);
	}
	[self ase_ApplyColor:color toRange:range];
}
#endif

- (void)ase_ApplyUnderlineStyle:(CTUnderlineStyle)style ToRange:(NSRange)range {
	if (range.location == NSNotFound) {
		return;
	}
	[self addAttribute:(NSString*)kCTUnderlineStyleAttributeName value:@(style) range:range];
}

@end
