//
//  WeatherMessageCell.m
//  Speech
//
//  Created by Phu on 6/20/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "WeatherMessageCell.h"
#import "Manager.h"
#import "UIImageView+WebCache.h"

@interface WeatherMessageCell () {
}

@end

@implementation WeatherMessageCell

- (instancetype)initWithData: (MessageData *) data
{
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor purpleColor];
    }
    return self;
}
- (void) calculateFrame {
    [super calculateFrame];
}

@end
