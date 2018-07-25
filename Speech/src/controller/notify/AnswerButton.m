//
//  AnswerButton.m
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AnswerButton.h"

@interface AnswerButton () {
    CAGradientLayer *gradientLayer;
    ASTextNode *title;
}

@end

@implementation AnswerButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = YES;
        self.cornerRadius = 17.5;
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.startPoint = CGPointMake(0.0, 0.5);
        gradientLayer.endPoint = CGPointMake(1.0, 0.5);
        [self.layer insertSublayer:gradientLayer atIndex:0];
        
        title = [ASTextNode new];
        [self addSubnode:title];
    }
    return self;
}
- (void) setStyle: (int) style {
    if (style == 1) {
        gradientLayer.colors = @[ (__bridge id)[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:130.0/255.0 green:130.0/255.0 blue:130.0/255.0 alpha:1.0].CGColor];
        title.attributedText = [[NSAttributedString alloc] initWithString:@"Huỷ" attributes:[self titleStyle]];
    }
    if (style == 2) {
        gradientLayer.colors = @[ (__bridge id)[UIColor colorWithRed:0.0/255.0 green:157.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:1.0/255.0 green:198.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor];
        title.attributedText = [[NSAttributedString alloc] initWithString:@"Gửi đi" attributes:[self titleStyle]];
    }
    if (style == 3) {
        gradientLayer.colors = @[ (__bridge id)[UIColor colorWithRed:0.0/255.0 green:157.0/255.0 blue:222.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:0.0/255.0 green:180.0/255.0 blue:239.0/255.0 alpha:1.0].CGColor,
                                  (__bridge id)[UIColor colorWithRed:1.0/255.0 green:198.0/255.0 blue:254.0/255.0 alpha:1.0].CGColor];
        title.attributedText = [[NSAttributedString alloc] initWithString:@"Đóng" attributes:[self titleStyle]];
    }
}
- (void) layout {
    [super layout];
    gradientLayer.frame = self.bounds;
    CGSize size = [title calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    title.frame = CGRectMake((self.bounds.size.width - size.width)/2.0, (self.bounds.size.height - size.height)/2.0, size.width, size.height);
}
- (NSDictionary *)titleStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
@end
