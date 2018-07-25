//
//  GVUserDefaults+Properties.m
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults+Properties.h"
#import "Utils.h"

@implementation GVUserDefaults (Properties)

@dynamic versionDB;
@dynamic muteSetting;
@dynamic username;
@dynamic password;
@dynamic jsonLogin;
@dynamic jsonAnswerIdNotifi;
@dynamic sendTokenFirebaseSuccess;
- (NSDictionary *)setupDefaults {
    return @{
             @"versionDB": @"1",
             @"muteSetting": @"",
             @"username": @"",
             @"password": @"",
             @"jsonLogin": @"",
             @"jsonAnswerIdNotifi": [Utils convertJsonObjectToString:@{}],
             @"sendTokenFirebaseSuccess": @""
    };
}

@end
