//
//  LoginSocialButton.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "LoginButton.h"

@interface LoginButton () {
    ASTextNode *titleNode;
}

@end

@implementation LoginButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.cornerRadius = 22.0f;
        
        titleNode = [ASTextNode new];
        titleNode.attributedText = [[NSAttributedString alloc] initWithString:@"ĐĂNG NHẬP" attributes:[self titleStyle]];
        [self addSubnode:titleNode];
    }
    return self;
}
- (NSDictionary *) titleStyle {
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor colorWithRed:0.0/255.0 green:166.0/255.0 blue:235.0/255.0 alpha:1.0],
             };
}
- (void) layout {
    [super layout];
    CGSize size = [titleNode calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    CGRect rect = self.bounds;
    rect.origin.x = (rect.size.width - size.width)/2.0;
    rect.origin.y = (rect.size.height - size.height)/2.0;
    rect.size.width = size.width;
    rect.size.height = size.height;
    titleNode.frame = rect;
}
@end
