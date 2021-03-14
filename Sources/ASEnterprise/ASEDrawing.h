//
//  ASEDrawing.h
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

#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

//-----------------------------------------------------------------------//
// Public functions                                                      //
CGRect ASETransposeRect(CGRect rect);
CGRect ASERectFromSize(CGSize size, CGPoint center);
CGSize ASEAspectFitSize(CGSize size, CGSize boundingSize);
CGRect ASEAspectFitRect(CGRect rect, CGRect boundingRect);
CGRect ASEAspectFitRectInCoordinateSpace(CGRect rect, CGRect boundingRect, BOOL useCoordinateSpace);
CGRect ASEAspectFillRect(CGRect rect, CGRect fillRect);
CGContextRef ASECreateContextForSize(CGSize size);
CGContextRef ASECreateAlphaOnlyContextForSize(CGSize size);
#if TARGET_OS_IPHONE == 1 && TARGET_OS_WATCH == 0
CGFloat ASEDeviceNativeScale(void);
CGAffineTransform ASETransformForOrientation(UIImageOrientation orientation, CGSize size);
BOOL ASENeedsTranspose(UIImageOrientation orientation);
#endif
