//
//  UserData.h
//  Speech
//
//  Created by Phu on 5/16/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserData : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, assign) int userId;
@property (nonatomic, strong) NSString *token;
@property (nonatomic, strong) NSString *userType;
- (BOOL) isExpert;
@end
