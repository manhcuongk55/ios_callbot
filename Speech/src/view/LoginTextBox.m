//
//  LoginTextBox.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "LoginTextBox.h"
#import "Utils.h"

@interface LoginTextBox () {
    ASDisplayNode *diviBottom;
    ASImageNode *icon;
    int type;
}

@end

@implementation LoginTextBox

- (instancetype)initWithType: (int) type_
{
    self = [super init];
    if (self) {
        type = type_;
        self.backgroundColor = [UIColor clearColor];
        diviBottom = [ASDisplayNode new];
        diviBottom.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        [self addSubnode:diviBottom];
        
        self.tf = [[UITextField alloc] init];
        self.tf.tintColor = [UIColor whiteColor];
        if (type == 2) self.tf.secureTextEntry = YES;
        self.tf.font = [UIFont systemFontOfSize:16.0];
        self.tf.textColor = [UIColor whiteColor];
        [self.tf setAttributedPlaceholder:[[NSAttributedString alloc] initWithString: (type == 1) ? @"Tên đăng nhập":@"Mật khẩu" attributes:[self textStyle]]];
        [self.view addSubview:self.tf];
        [self.tf setReturnKeyType:UIReturnKeyDone];
        
        icon = [ASImageNode new];
        icon.image = [Utils image:[UIImage imageNamed:(type == 1) ? @"username_icon_tf" : @"password_icon_tf"] color:[UIColor whiteColor]];
        [self.view addSubnode:icon];
    }
    return self;
}
- (void) layout {
    [super layout];
    CGRect rect = self.bounds;
    rect.size.height = 0.5;
    rect.origin.y = self.bounds.size.height - 0.5;
    diviBottom.frame = rect;
    rect = self.bounds;
    rect.origin.x = 30;
    rect.size.width -= rect.origin.x;
    self.tf.frame = rect;
    icon.frame = CGRectMake(0, (self.bounds.size.height - 18)/2.0, 18, 18);
}
- (NSDictionary *) textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.65],
             };
}
@end
