//
//  NavBarView.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "NavBarView.h"
#import "Utils.h"

@interface NavBarView () {
    ASDisplayNode *statusBarBg;
    ASTextNode *titleNav;
}

@end

@implementation NavBarView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        statusBarBg = [ASDisplayNode new];
        [self addSubnode:statusBarBg];
        statusBarBg.backgroundColor = [UIColor whiteColor];
        //
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeMake(0.0, 2.0f);
        self.layer.shadowRadius = 2;
        //
        titleNav = [ASTextNode new];
        [self addSubnode:titleNav];
        //
        self.rightBtn = [ASButtonNode new];
        [self addSubnode:self.rightBtn];
        //
        self.leftBtn = [NotiButton new];
        [self addSubnode:self.leftBtn];
        //
        
    }
    return self;
}
- (void) setTitle: (NSString *) title {
    titleNav.attributedText = [[NSAttributedString alloc] initWithString: title attributes:[self titleStyle]];
}
- (void) layout {
    [super layout];
    statusBarBg.frame = CGRectMake(0, -20, self.bounds.size.width, 20);
    //
    CGSize sizeT = [titleNav calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    float xT = (self.bounds.size.width - sizeT.width)/2.0;
    float yT = (self.bounds.size.height - sizeT.height)/2.0;
    titleNav.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
    xT = self.bounds.size.width - 44 - [Utils instance].edgeInsets.right;
    yT = 0;
    self.rightBtn.frame = CGRectMake(xT, yT, 44, 44);
    //
    xT = [Utils instance].edgeInsets.left;
    yT = 0;
    self.leftBtn.frame = CGRectMake(xT, yT, 44, 44);
    //
}
- (NSDictionary *) titleStyle {
    UIFont *font = [UIFont boldSystemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0],
             };
}
@end
