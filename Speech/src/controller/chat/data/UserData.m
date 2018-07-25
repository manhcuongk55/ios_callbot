//
//  UserData.m
//  Speech
//
//  Created by Phu on 5/16/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "UserData.h"

@implementation UserData
- (BOOL) isExpert {
    if (self.userType) {
        return [self.userType isEqualToString:@"Experts"];
    }
    return NO;
}
@end
