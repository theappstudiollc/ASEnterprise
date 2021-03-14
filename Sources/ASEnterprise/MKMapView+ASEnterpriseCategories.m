//
//  MKMapView+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 1/16/16.
//  Copyright © 2016 The App Studio LLC.
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

#import "MKMapView+ASEnterpriseCategories.h"

#if !TARGET_OS_WATCH

@implementation MKMapView (ASEnterpriseCategories)

#if TARGET_OS_IPHONE
- (MKMapRect)ase_VisibleMapRectWithInsets:(UIEdgeInsets)insets {
	MKMapRect retVal = self.visibleMapRect;
	retVal.origin.x += retVal.size.width * insets.left / self.bounds.size.width;
	retVal.origin.y += retVal.size.height * insets.top / self.bounds.size.height;
	retVal.size.width *= (self.bounds.size.width - insets.left - insets.right) / self.bounds.size.width;
	retVal.size.height *= (self.bounds.size.height - insets.top - insets.bottom) / self.bounds.size.height;
	return retVal;
}
#endif

@end

#endif
