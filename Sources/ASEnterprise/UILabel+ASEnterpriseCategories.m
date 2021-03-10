//
//  UILabel+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 5/22/15.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import "NSDictionary+ASEnterpriseCategories.h"
#import "UILabel+ASEnterpriseCategories.h"

@implementation UILabel (ASEnterpriseCategories)

- (void)ase_ApplyText:(NSString*)text withOptions:(NSDictionary*)options {
	
	if ([text length] == 0) {
		self.text = text;
		return;
	}
	
	NSDictionary* mergedOptions = [[self ase_DefaultOptions] ase_DictionaryOverwrittenWithDictionary:options];
	self.attributedText = [text ase_AttributedStringWithOptions:mergedOptions];
}

- (NSDictionary*)ase_DefaultOptions {
	return @ {
#if TARGET_OS_TV
		kASETextOptionsFont : self.font ?: [UIFont systemFontOfSize:17],
#else
		kASETextOptionsFont : self.font ?: [UIFont systemFontOfSize:[UIFont systemFontSize]],
#endif
		kASETextOptionsAlignment : @(self.textAlignment),
		kASETextOptionsForegroundColor : self.textColor ?: [UIColor blackColor],
		kASETextOptionsLineBreak : @(self.lineBreakMode),
	};
}

- (void)ase_UpdateTextWithOptions:(NSDictionary*)options {
	[self ase_ApplyText:self.text withOptions:options];
}

@end

#endif
