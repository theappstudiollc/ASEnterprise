//
//  NSMutableAttributedString+ASEnterpriseCategories.h
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

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@interface NSMutableAttributedString (ASEnterpriseCategories)

- (void)ase_AppendParagraph:(NSString*)paragraph withAttributes:(NSDictionary*)attributes;
- (void)ase_AppendString:(NSString*)string withAttributes:(NSDictionary*)attributes;
- (void)ase_ReplaceOpenTags:(NSString*)openTag closeTags:(NSString*)closeTag andAddAttributes:(NSDictionary*)attributes;
// The following are not really necessary given existing methods with NSMutableAttributedStrings
#if TARGET_OS_IPHONE
- (void)ase_ApplyColor:(UIColor*)color toRange:(NSRange)range;
- (void)ase_ApplyFont:(UIFont*)font toRange:(NSRange)range;
- (void)ase_ApplyFont:(UIFont*)font toRange:(NSRange)range withColor:(UIColor*)color;
#endif
- (void)ase_ApplyUnderlineStyle:(CTUnderlineStyle)style ToRange:(NSRange)range;

@end
