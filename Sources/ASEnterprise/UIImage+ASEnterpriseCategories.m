//
//  UIImage+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 6/16/13.
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

#if TARGET_OS_IOS || (TARGET_OS_IPHONE && !TARGET_OS_TV)

#import <CoreGraphics/CoreGraphics.h>
#import "ASEDrawing.h"
#import "UIImage+ASEnterpriseCategories.h"

@implementation UIImage (ASEnterpriseCategories)

//////////////////////////////////////////////////////////////////////////
#pragma mark - Public properties and methods -
//////////////////////////////////////////////////////////////////////////

+ (instancetype)ase_LaunchImage {
	NSDictionary* imageDictionary = @ {
		@"320x480" : @"LaunchImage-700",
		@"320x568" : @"LaunchImage-700-568h",
		@"375x667" : @"LaunchImage-800-667h",
		@"414x736" : @"LaunchImage-800-Portrait-736h",
		@"736x414" : @"LaunchImage-800-Landscape-736h",
		@"768x1024": @"LaunchImage-700-Portrait~ipad",
	};
	CGRect mainBounds = [UIScreen mainScreen].bounds;
	NSString* key = [NSString stringWithFormat:@"%dx%d", (int)mainBounds.size.width, (int)mainBounds.size.height];
	UIImage* retVal = [UIImage imageNamed:imageDictionary[key]];
	if (!retVal) {
		retVal = [UIImage imageNamed:@"LaunchImage"];
	}
	NSAssert(retVal, @"No LaunchImage!");
	return retVal;
}

- (UIImage*)ase_CroppedToRect:(CGRect)crop {
	CGFloat maxSide = MAX(crop.size.width, crop.size.height);
	CGSize finalSize = CGSizeMake(maxSide, maxSide);
	return [self ase_CroppedToRect:crop withSize:finalSize];
}

- (UIImage*)ase_CroppedToRect:(CGRect)crop withSize:(CGSize)size {
	UIImage* retVal = nil;
	
	if (!CGSizeEqualToSize(crop.size, CGSizeZero)) {
		//Since the crop rect is in UIImageOrientationUp we need to transform it too
		CGAffineTransform cropTransform = ASETransformForOrientation(self.imageOrientation, self.size);
		CGRect transformedCrop = CGRectApplyAffineTransform(crop, cropTransform);
		CGImageRef croppedRef = CGImageCreateWithImageInRect(self.CGImage, transformedCrop);
		if (croppedRef) {
			CGContextRef context = ASECreateContextForSize(size);
			if (context) {
				CGAffineTransform contextTransform = ASETransformForOrientation(self.imageOrientation, size);
				CGContextConcatCTM(context, contextTransform);
				CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
#if false
				CGContextDrawImage(context, CGRectMakeFrom(size), croppedRef);
#else
				CGSize aspectFitSize = ASEAspectFitSize(transformedCrop.size, size);
				// TODO: Compare aspectFitSize with size to see if background fill is necessary
				CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
				CGContextFillRect(context, (CGRect){.origin = CGPointZero, .size = size});
				CGRect drawRect = CGRectMake((size.width-aspectFitSize.width)/2, (size.height-aspectFitSize.height)/2, aspectFitSize.width, aspectFitSize.height);
				CGContextDrawImage(context, drawRect, croppedRef);
#endif
				CGImageRelease(croppedRef);
				
				CGImageRef newimageRef = CGBitmapContextCreateImage(context);
				retVal = [UIImage imageWithCGImage:newimageRef];
				CGImageRelease(newimageRef);
				CGContextRelease(context);
			}
			else { // if (croppedRef)
				CGImageRelease(croppedRef);
			}
		}
	}
	
	return retVal;
}

- (UIImage*)ase_GrayScaleImage {
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
	
	CGSize size = CGSizeMake(self.size.width * self.scale, self.size.height * self.scale);
	CGRect imageRect = CGRectMake(0, 0, size.width, size.height);
	size_t bits = 8;
	
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaNone;
	CGContextRef context = CGBitmapContextCreate(nil, (size_t)size.width, (size_t)size.height, bits, 0, colorSpace, bitmapInfo);
	if (colorSpace != nil) CGColorSpaceRelease(colorSpace);
	
	CGContextDrawImage(context, imageRect, [self CGImage]);
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage* retVal = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
	CFRelease(imageRef);
	CGContextRelease(context);
	
	return retVal;
}

- (BOOL)ase_IsNotBlank {
	return !CGSizeEqualToSize(self.size, CGSizeZero);
}

- (UIImage*)ase_ScaledToSize:(CGSize)size withAspectType:(ASEImageAspectType)aspectType {
	switch (aspectType) {
		case ASEImageAspectTypeFill:
			return [self ase_ImageAspectFillWithSize:size];
		case ASEImageAspectTypeFit:
			return [self ase_ImageAspectFitWithSize:size];
		default:
			return nil;
	}
}

//////////////////////////////////////////////////////////////////////////
#pragma mark - Private methods -
//////////////////////////////////////////////////////////////////////////

- (UIImage*)ase_ImageAspectFitWithSize:(CGSize)size {
	UIImage* retVal = nil;
	
	if (!CGSizeEqualToSize(size, CGSizeZero)) {
		// Determine the pixel-scale of the display and adjust values accordingly
		CGSize imageSize = self.size;
		size = CGSizeMake(size.width * self.scale, size.height * self.scale);
		size = ASEAspectFitSize(imageSize, size);
		
		CGRect cropWindow = (CGRect){.origin = CGPointZero, .size = size};
		cropWindow = CGRectIntegral(cropWindow);
		
		// Scale the image using the best possible quality
		CGContextRef context = ASECreateContextForSize(size);
		if (context) {
			CGAffineTransform transform = ASETransformForOrientation(self.imageOrientation, size);
			CGContextConcatCTM(context, transform);
			CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
			
			CGImageRef imageRef = CGImageRetain(self.CGImage);
			if (ASENeedsTranspose(self.imageOrientation)) {
				CGRect transposedRect = ASETransposeRect(cropWindow);
				CGContextDrawImage(context, transposedRect, imageRef);
			}
			else {
				CGContextDrawImage(context, cropWindow, imageRef);
			}
			CGImageRelease(imageRef);
			
			CGImageRef newimageRef = CGBitmapContextCreateImage(context);
			retVal = [UIImage imageWithCGImage:newimageRef scale:self.scale orientation:UIImageOrientationUp];
			CGImageRelease(newimageRef);
			CGContextRelease(context);
		}
	}
	
	return retVal;
}

- (UIImage*)ase_ImageAspectFillWithSize:(CGSize)size {
	UIImage* retVal = nil;
	
	if (!CGSizeEqualToSize(size, CGSizeZero)) {
		// Determine the pixel-scale of the display and adjust values accordingly
		CGSize imageSize = self.size;
		size = CGSizeMake(size.width * self.scale, size.height * self.scale);
		
		CGRect cropWindow = ASEAspectFillRect((CGRect){.origin = CGPointZero, .size = imageSize}, (CGRect){.origin = CGPointZero, .size = size});
		cropWindow = CGRectIntegral(cropWindow);
		
		// Scale the image using the best possible quality
		CGContextRef context = ASECreateContextForSize(size);
		if (context) {
			CGAffineTransform transform = ASETransformForOrientation(self.imageOrientation, size);
			CGContextConcatCTM(context, transform);
			CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
			
			CGImageRef imageRef = CGImageRetain(self.CGImage);
			if (ASENeedsTranspose(self.imageOrientation)) {
				CGRect transposedRect = ASETransposeRect(cropWindow);
				CGContextDrawImage(context, transposedRect, imageRef);
			}
			else {
				CGContextDrawImage(context, cropWindow, imageRef);
			}
			CGImageRelease(imageRef);
			
			CGImageRef newimageRef = CGBitmapContextCreateImage(context);
			retVal = [UIImage imageWithCGImage:newimageRef scale:self.scale orientation:UIImageOrientationUp];
			CGImageRelease(newimageRef);
			CGContextRelease(context);
		}
	}
	
	return retVal;
}

@end

#endif
