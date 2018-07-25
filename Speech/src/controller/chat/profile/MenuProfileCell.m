//
//  MenuProfileCell.m
//  Speech
//
//  Created by Phu on 5/16/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "MenuProfileCell.h"

@interface MenuProfileCell () {
    ASTextNode *title;
    ASTextNode *des;
}

@end

@implementation MenuProfileCell

- (instancetype)initWithData: (NSDictionary *) data
{
    self = [super init];
    if (self) {
        title = [ASTextNode new];
        title.attributedText = [[NSAttributedString alloc] initWithString: data[@"title"] attributes:[self titleStyle]];
        [self addSubnode:title];
        
        des = [ASTextNode new];
        des.attributedText = [[NSAttributedString alloc] initWithString: data[@"des"] attributes:[self desStyle]];
        [self addSubnode:des];
    }
    return self;
}
- (void) layout {
    [super layout];
    CGSize size = [title calculateSizeThatFits:CGSizeMake(self.bounds.size.width - 20 - 5, MAXFLOAT)];
    title.frame = CGRectMake(20, 10, size.width, size.height);
    
    size = [des calculateSizeThatFits:CGSizeMake(self.bounds.size.width - 20 - 5, MAXFLOAT)];
    des.frame = CGRectMake(20, title.frame.origin.y + title.frame.size.height + 5, size.width, size.height);
}
- (NSDictionary *) titleStyle {
    UIFont *font = [UIFont systemFontOfSize:18];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor blackColor],
             };
}
- (NSDictionary *) desStyle {
    UIFont *font = [UIFont systemFontOfSize:15];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor lightGrayColor],
             };
}
@end
