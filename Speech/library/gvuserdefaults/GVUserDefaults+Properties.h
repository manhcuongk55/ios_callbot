//
//  GVUserDefaults+Properties.h
//  GVUserDefaults
//
//  Created by Kevin Renskers on 18-12-12.
//  Copyright (c) 2012 Gangverk. All rights reserved.
//

#import "GVUserDefaults.h"

@interface GVUserDefaults (Properties)

@property (nonatomic, weak) NSString *versionDB;
@property (nonatomic, weak) NSString *muteSetting;
@property (nonatomic, weak) NSString *username;
@property (nonatomic, weak) NSString *password;
@property (nonatomic, weak) NSString *jsonLogin;
@property (nonatomic, weak) NSString *jsonAnswerIdNotifi;
@property (nonatomic, weak) NSString *sendTokenFirebaseSuccess;
@end
