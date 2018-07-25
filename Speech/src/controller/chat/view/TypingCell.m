//
//  TypingCell.m
//  Speech
//
//  Created by Phu on 5/10/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "TypingCell.h"
#import "Manager.h"
#import "Speech-Swift.h"

@interface TypingCell () {
    ASDisplayNode *bubbleNode;
    ASDisplayNode *bubbleCornerNode;
    NVActivityIndicatorView *activity;
}

@end

@implementation TypingCell

- (instancetype)initWithData: (MessageData *) data
{
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bubbleNode = [ASDisplayNode new];
        if (data.fromMe) {
            bubbleNode.backgroundColor = [Manager instance].colorBubbleFromMe;
        }
        else {
            bubbleNode.backgroundColor = [Manager instance].colorBubbleFromBot;
        }
        bubbleNode.cornerRadius = 7.0f;
        [self addSubnode:bubbleNode];
        //
        bubbleCornerNode = [ASDisplayNode new];
        if (data.fromMe) {
            bubbleCornerNode.backgroundColor = [Manager instance].colorBubbleFromMe;
        }
        else {
            bubbleCornerNode.backgroundColor = [Manager instance].colorBubbleFromBot;
        }
        [bubbleNode addSubnode:bubbleCornerNode];
        //
        [self addAvatarImg];
        //
        activity = [NVActivityIndicatorView createIndicatorView];
        activity.type = NVActivityIndicatorTypeBallPulse;
        activity.color = [UIColor whiteColor];
        activity.padding = 5.0;
        activity.frame = CGRectMake(0, 0, 60, 40);
        [activity startAnimating];
        [bubbleNode.view addSubview:activity];
    }
    return self;
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: self.weakData.fromMe ? [UIColor blackColor] : [UIColor whiteColor],
             };
}
- (void) calculateFrame {
    [super calculateFrame];
    float xT, yT;
    xT = 10;
    yT = 10;
    self.avatarImg.frame = CGRectMake(xT, yT + 2, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
    
    xT = self.avatarImg.frame.origin.x + self.avatarImg.frame.size.width + 10;
    yT = 10;
    bubbleNode.frame = CGRectMake(xT, yT, self.weakData.bubbleRect.size.width, self.weakData.bubbleRect.size.height);
    bubbleCornerNode.frame = CGRectMake(0, 0, 7, 7);
}

@end
