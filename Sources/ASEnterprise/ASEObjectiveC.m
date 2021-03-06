//
//  ASEObjectiveC.m
//  ASEnterprise
//
//  Created by David Mitchell on 4/28/18.
//  Copyright © 2018 The App Studio LLC.
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

#import "ASEObjectiveC.h"

@implementation ASEObjectiveC

+ (BOOL)catchException:(__attribute__((noescape)) void (^)(void))tryBlock error:(NSError* __autoreleasing _Nullable *)error {
	@try {
		tryBlock();
		return YES;
	}
	@catch (NSException* exception) {
		if (error != NULL) {
			*error = [[NSError alloc] initWithDomain:exception.name code:0 userInfo:exception.userInfo];
		}
		return NO;
	}
}

@end
