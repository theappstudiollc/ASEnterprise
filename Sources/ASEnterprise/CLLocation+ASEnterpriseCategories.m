//
//  CLLocation+ASEnterpriseCategories.m
//  ASEnterprise
//
//  Created by David Mitchell on 10/24/13.
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

#import "ASEMath.h"
#import "CLLocation+ASEnterpriseCategories.h"

@implementation CLLocation (ASEnterpriseCategories)
// NOTES: φ = latitude, λ = longitude, θ = bearing, δ = angular distance (all values in radians)

- (CLLocationDirection)ase_BearingToLocation:(CLLocation*)location {
	double θ = [self ase_BearingRadiansToLocation:location];
	return ASERadiansToDegrees(θ);
}
#if TARGET_OS_TV == 0 && TARGET_OS_WATCH == 0
- (CLLocationDirection)ase_BearingToLocation:(CLLocation*)location fromHeading:(CLHeading*)heading {
	double θ = [self ase_BearingRadiansToLocation:location] - ASEDegreesToRadians(heading.trueHeading);
	θ = fmod(θ + M_PI * 4.0, M_PI * 2.0); // Adjust so that we're in the range of 0 to 359.9
	return ASERadiansToDegrees(θ);
}
#endif
- (CLLocationCoordinate2D)ase_CoordinateAtDistance:(CLLocationDistance)distance withBearing:(CLLocationDirection)bearing {
	// Convert all degrees to radians
	double δ = distance / 6371000.0; // Mean radius of Earth in meters
	double θ = ASEDegreesToRadians(bearing);
	double φ1 = ASEDegreesToRadians(self.coordinate.latitude);
	double λ1 = ASEDegreesToRadians(self.coordinate.longitude);
	// Perform the math
	double φ2 = asin(sin(φ1) * cos(δ) + cos(φ1) * sin(δ) * cos(θ));
	double y = sin(θ) * sin(δ) * cos(φ1);
	double x = cos(δ) - sin(φ1) * sin(φ2);
	double λ2 = λ1 + atan2(y, x);
	// Adjust λ2 to be in the range of -180 to +180 and return
	λ2 = fmod(λ2 + M_PI * 3.0, M_PI * 2.0) - M_PI;
	return CLLocationCoordinate2DMake(ASERadiansToDegrees(φ2), ASERadiansToDegrees(λ2));
}

#pragma mark - Private methods

- (double)ase_BearingRadiansToLocation:(CLLocation*)location {
	// Convert all degrees to radians
	double Δλ = ASEDegreesToRadians(location.coordinate.longitude - self.coordinate.longitude);
	double φ1 = ASEDegreesToRadians(self.coordinate.latitude);
	double φ2 = ASEDegreesToRadians(location.coordinate.latitude);
	// Perform the math and return the value in radians
	double y = sin(Δλ) * cos(φ2);
	double x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ);
	return atan2(y, x);
}

@end
