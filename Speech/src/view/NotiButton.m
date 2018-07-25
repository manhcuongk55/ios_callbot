//
//  NotiButton.m
//  Speech
//
//  Created by Phu on 5/18/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "NotiButton.h"

@interface NotiButton () {
    ASDisplayNode *redNode;
    CGPoint offset;
}

@end

@implementation NotiButton

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}
- (void) addRedNode: (CGPoint) offset_ {
    redNode = [ASDisplayNode new];
    redNode.backgroundColor = [UIColor redColor];
    redNode.cornerRadius = 3.0;
    [self addSubnode:redNode];
    offset = offset_;
}
- (void) layout {
    [super layout];
    redNode.frame = CGRectMake(offset.x, offset.y, 6, 6);
}
- (void) showRedNode: (BOOL) show {
    redNode.hidden = !show;
}
@end
