//
//  Style1Button.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "Style1Button.h"

@implementation Style1Button

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.borderColor = [UIColor whiteColor].CGColor;
        self.borderWidth = 1.0f;
    }
    return self;
}

@end
