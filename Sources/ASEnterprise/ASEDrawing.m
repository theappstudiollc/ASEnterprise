//
//  ASEDrawing.m
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

#import "ASEDrawing.h"
#import <tgmath.h>

//////////////////////////////////////////////////////////////////////////
#pragma mark - Public methods -
//////////////////////////////////////////////////////////////////////////

#if TARGET_OS_IPHONE
// Returns an affine transform that takes into account the image orientation when drawing a scaled image
CGAffineTransform ASETransformForOrientation(UIImageOrientation orientation, CGSize size) {
	CGAffineTransform retVal = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            retVal = CGAffineTransformTranslate(retVal, size.width, size.height);
            retVal = CGAffineTransformRotate(retVal, (CGFloat)M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            retVal = CGAffineTransformTranslate(retVal, size.height, 0);
            retVal = CGAffineTransformRotate(retVal, (CGFloat)M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            retVal = CGAffineTransformTranslate(retVal, 0, size.width);
            retVal = CGAffineTransformRotate(retVal, (CGFloat)-M_PI_2);
            break;
		default:
			break;
    }
    switch (orientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            retVal = CGAffineTransformTranslate(retVal, size.width, 0);
            retVal = CGAffineTransformScale(retVal, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            retVal = CGAffineTransformTranslate(retVal, size.height, 0);
            retVal = CGAffineTransformScale(retVal, -1, 1);
            break;
		default:
			break;
    }
    
    return retVal;
}

BOOL ASENeedsTranspose(UIImageOrientation orientation) {
	switch (orientation) {
		case UIImageOrientationLeft:
		case UIImageOrientationLeftMirrored:
		case UIImageOrientationRight:
		case UIImageOrientationRightMirrored:
			return YES;
		default:
			return NO;
	}
}
#endif

CGContextRef ASECreateContextForSize(CGSize size) {
	CGContextRef retVal = NULL;
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	size_t bits = 8;
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst;
	retVal = CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, bits, 0, colorSpace, bitmapInfo);
	if (colorSpace != NULL) CGColorSpaceRelease(colorSpace);
	
	return retVal;
}

CGContextRef ASECreateAlphaOnlyContextForSize(CGSize size) {
	size_t bytesPerRow = (size_t)(ceil(size.width / 4.0) * 4.0);
	return CGBitmapContextCreate(NULL, (size_t)size.width, (size_t)size.height, 8, bytesPerRow, NULL, kCGBitmapAlphaInfoMask & kCGImageAlphaOnly);
}

CGRect ASETransposeRect(CGRect rect) {
	return CGRectMake(rect.origin.y, rect.origin.x, rect.size.height, rect.size.width);
}

CGRect ASERectFromSize(CGSize size, CGPoint center) {
	CGFloat x = center.x - (size.width / 2);
	CGFloat y = center.y - (size.height / 2);
	return CGRectMake(floor(x), floor(y), size.width, size.height);
}

CGSize ASEAspectFitSize(CGSize size, CGSize boundingSize) {
	CGSize retVal = boundingSize;
	
	CGFloat originalAspectRatio = (size.width / size.height);
	CGFloat returnAspectRatio = (boundingSize.width / boundingSize.height);
	
	if (originalAspectRatio > returnAspectRatio) {
		// The original is "wider" than the return (return width stays the same)
		//retVal.height = retVal.width / originalAspectRatio; // Don't use this
		retVal.height = retVal.width * size.height / size.width;
	}
	else if (originalAspectRatio < returnAspectRatio) {
		// The return is "wider" than the original (return height stays the same)
		//retVal.width = retVal.height * originalAspectRatio; // Don't use this
		retVal.width = retVal.height * size.width / size.height;
	}
	return retVal;
}

CGRect ASEAspectFitRect(CGRect rect, CGRect boundingRect) {
	return ASEAspectFitRectInCoordinateSpace(rect, boundingRect, NO);
}

CGRect ASEAspectFitRectInCoordinateSpace(CGRect rect, CGRect boundingRect, BOOL useCoordinateSpace) {
	CGRect retVal = boundingRect;
	
	CGFloat originalAspectRatio = (rect.size.width / rect.size.height);
	CGFloat returnAspectRatio = (boundingRect.size.width / boundingRect.size.height);
	if (originalAspectRatio > returnAspectRatio) {
		// The original is "wider" than the return (return width stays the same)
		//retVal.size.height = retVal.size.width / originalAspectRatio;
		retVal.size.height = retVal.size.width * rect.size.height / rect.size.width;
		retVal.origin.y += (useCoordinateSpace ? -1 : 1) * ((boundingRect.size.height - retVal.size.height) / 2);
	}
	else if (originalAspectRatio < returnAspectRatio) {
		// The return is "wider" than the original (return height stays the same)
		//retVal.size.width = retVal.size.height * originalAspectRatio;
		retVal.size.width = retVal.size.height * rect.size.width / rect.size.height;
		retVal.origin.x += (boundingRect.size.width - retVal.size.width) / 2;
	}
	
	return retVal;
}

CGRect ASEAspectFillRect(CGRect rect, CGRect fillRect) {
	CGRect retVal = fillRect;
	
	CGFloat originalAspectRatio = (rect.size.width / rect.size.height);
	CGFloat fillAspectRatio = (fillRect.size.width / fillRect.size.height);
	if (originalAspectRatio > fillAspectRatio) {
		// The original is "wider" than the fill (return height stays the same)
		retVal.size.width = retVal.size.height * rect.size.width / rect.size.height;
		retVal.origin.x -= (retVal.size.width - fillRect.size.width) / 2;
	}
	else if (originalAspectRatio < fillAspectRatio) {
		// The fill is "wider" than the original (return width stays the same)
		retVal.size.height = retVal.size.width * rect.size.height / rect.size.width;
		retVal.origin.y -= (retVal.size.height - fillRect.size.height) / 2;
	}
	
	return retVal;
}

#if TARGET_OS_IPHONE == 1 && TARGET_OS_WATCH == 0
CGFloat ASEDeviceNativeScale() {
	if ([[UIScreen mainScreen] respondsToSelector:@selector(nativeScale)]) {
		return [UIScreen mainScreen].nativeScale;
	} //else if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
		return [UIScreen mainScreen].scale;
	//}
	//return 1.0;
}
#endif
//////////////////////////////////////////////////////////////////////////
