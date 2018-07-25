//
//  TitleButton.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "TitleButton.h"
#import "ASTextNode.h"

@interface TitleButton () {
    ASTextNode *titleNode;
}
@end

@implementation TitleButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        titleNode = [ASTextNode new];
        [self addSubnode:titleNode];
        titleNode.attributedText = [[NSAttributedString alloc] initWithString:@"Forgot your password?" attributes:[self titleStyle]];
    }
    return self;
}
- (NSDictionary *) titleStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
- (void) layout {
    [super layout];
    //
    CGSize sizeT = [titleNode calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    float xT = (self.bounds.size.width - sizeT.width)/2.0;
    float yT = (self.bounds.size.height - sizeT.height)/2.0;
    titleNode.frame = CGRectMake( xT, yT, sizeT.width, sizeT.height);
    //
}
@end
