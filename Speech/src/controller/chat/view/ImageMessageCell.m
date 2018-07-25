//
//  TypingCell.m
//  Speech
//
//  Created by Phu on 5/10/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "ImageMessageCell.h"
#import "Manager.h"
#import "UIImageView+WebCache.h"
@interface ImageMessageCell () {
    ASDisplayNode *bubbleNode;
    ASDisplayNode *bubbleCornerNode;
    UIImageView *img;
}

@end

@implementation ImageMessageCell

- (instancetype)initWithData: (MessageData *) data
{
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
        img = [UIImageView new];
        [self.view addSubview:img];
        [img sd_setImageWithURL:[NSURL URLWithString: @"http://via.placeholder.com/100"]];
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
        
    }
    return self;
}
- (void) calculateFrame {
    [super calculateFrame];
    img.frame = self.bounds;
//    float xT, yT;
//    xT = 10;
//    yT = 10;
//    self.avatarImg.frame = CGRectMake(xT, yT + 2, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
//
//    xT = self.avatarImg.frame.origin.x + self.avatarImg.frame.size.width + 10;
//    yT = 10;
//    bubbleNode.frame = CGRectMake(xT, yT, self.weakData.bubbleRect.size.width, self.weakData.bubbleRect.size.height);
//    bubbleCornerNode.frame = CGRectMake(0, 0, 7, 7);
}

@end
