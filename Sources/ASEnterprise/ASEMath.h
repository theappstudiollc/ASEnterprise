//
//  ASEMath.h
//  ASEnterprise
//
//  Created by David Mitchell on 2/25/16.
//  Copyright © 2016 The App Studio LLC. All rights reserved.
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

#import <math.h>

#define _ASE_ATTRS __attribute__((__overloadable__, __always_inline__, unused))

static float _ASE_ATTRS ASEBounded(float value, float min, float max) {
	return value < min ? min : value > max ? max : value;
}

static double _ASE_ATTRS ASEBounded(double value, double min, double max) {
	return value < min ? min : value > max ? max : value;
}

static inline double ASEDegreesToRadians(double degrees) {
	return degrees * M_PI / 180.0;
}

static inline double ASERadiansToDegrees(double radians) {
	return radians * 180.0 / M_PI;
}

static float _ASE_ATTRS ASERatioOf(float value, float min, float max) {
	return (value - min) / (max - min);
}

static double _ASE_ATTRS ASERatioOf(double value, double min, double max) {
	return (value - min) / (max - min);
}
