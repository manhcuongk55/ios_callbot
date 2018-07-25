//
//  CheckBoxRememberLogin.m
//  Speech
//
//  Created by Phu on 5/16/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "CheckBoxRememberLogin.h"

@interface CheckBoxRememberLogin () {
    ASImageNode *img;
    ASTextNode *title;
    BOOL checked;
}

@end

@implementation CheckBoxRememberLogin

- (instancetype)init
{
    self = [super init];
    if (self) {
        checked = YES;
        self.backgroundColor = [UIColor clearColor];
        img = [ASImageNode new];
        img.image = [UIImage imageNamed: @"checkbox_on"];
        [self.view addSubnode:img];
        
        title = [ASTextNode new];
        title.attributedText = [[NSAttributedString alloc] initWithString:@"Lưu tài khoản" attributes:[self titleStyle]];
        [self addSubnode:title];
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
        [self.view addGestureRecognizer:gesture];
    }
    return self;
}
- (void) handleTapGesture {
    checked = !checked;
    img.image = [UIImage imageNamed:checked?@"checkbox_on":@"checkbox_off"];
}
- (void) layout {
    [super layout];
    CGSize size = CGSizeMake(15, 15);
    img.frame = CGRectMake(0, (self.bounds.size.height - size.height)/2.0, size.width, size.height);
    
    size = [title calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    title.frame = CGRectMake(15 + 10, (self.bounds.size.height - size.height)/2.0, size.width, size.height);
}
- (NSDictionary *) titleStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
@end
