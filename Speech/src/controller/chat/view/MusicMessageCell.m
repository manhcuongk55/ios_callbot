//
//  MusicMessageCell.m
//  Speech
//
//  Created by Phu on 6/20/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "MusicMessageCell.h"
#import "Manager.h"
#import "UIImageView+WebCache.h"

@interface MusicMessageCell () {
}

@end

@implementation MusicMessageCell

- (instancetype)initWithData: (MessageData *) data
{
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor yellowColor];
    }
    return self;
}
- (void) calculateFrame {
    [super calculateFrame];
}

@end
