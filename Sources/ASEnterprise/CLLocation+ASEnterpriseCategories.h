//
//  CLLocation+ASEnterpriseCategories.h
//  ASEnterprise
//
//  Created by David Mitchell on 10/24/13.
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

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocation (ASEnterpriseCategories)

- (CLLocationDirection)ase_BearingToLocation:(CLLocation*)location;
#if TARGET_OS_TV == 0 && TARGET_OS_WATCH == 0
- (CLLocationDirection)ase_BearingToLocation:(CLLocation*)location fromHeading:(CLHeading*)heading;
#endif
- (CLLocationCoordinate2D)ase_CoordinateAtDistance:(CLLocationDistance)distance withBearing:(CLLocationDirection)bearing;

@end

NS_ASSUME_NONNULL_END
