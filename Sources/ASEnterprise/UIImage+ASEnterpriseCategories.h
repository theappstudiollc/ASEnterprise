//
//  UIImage+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 6/16/13.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ASEImageAspectType) {
	ASEImageAspectTypeFill,
	ASEImageAspectTypeFit,
};

@interface UIImage (ASEnterpriseCategories)

@property (readonly, nonatomic) UIImage* ase_GrayScaleImage;
@property (readonly, nonatomic) BOOL ase_IsNotBlank;

+ (instancetype)ase_LaunchImage;

- (UIImage*)ase_CroppedToRect:(CGRect)crop;
- (UIImage*)ase_CroppedToRect:(CGRect)crop withSize:(CGSize)size;
- (UIImage*)ase_ScaledToSize:(CGSize)size withAspectType:(ASEImageAspectType)aspectType;

@end

#endif
