//
//  BaseChatCell.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "BaseChatCell.h"
#import "Manager.h"

@implementation BaseChatCell

- (instancetype)initWithData:(MessageData *)data
{
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.weakData = data;
        data.weakCell = self;
    }
    return self;
}
-  (void)handleLongPressCell:(UILongPressGestureRecognizer*)sender {
    if (sender.state == UIGestureRecognizerStateEnded) {
    }
    else if (sender.state == UIGestureRecognizerStateBegan){
        [self showOptionMenu];
    }
}
- (void) showOptionMenu {
    [[Manager instance].currentChatVC.listNode showOptionMenuForCell: self];
}
- (void) layout {
    [super layout];
    [self calculateFrame];
}
- (void) addAvatarImg {
    self.avatarImg = [UIImageView new];
    if (self.weakData.fromMe) {
        self.avatarImg.image = [UIImage imageNamed:@"avatar_default_msg_cell"];
    }
    else {
        self.avatarImg.image = [UIImage imageNamed:@"va_avatar_default"];
    }
    [self.view addSubview:self.avatarImg];
}
- (void) calculateFrame {
}
- (CGRect) getBubbleRect {
    return self.bounds;
}
- (void) setSelectBubble: (BOOL) selected {
    
}
- (void) showRateMessage {
    [self checkShowRateMessage];
    [self calculateFrame];
}
- (void) checkShowRateMessage {
    if (self.weakData.rateMessage == 0) {
    }
    else {
        if (!self.rateMessageImg) {
            self.rateMessageImg = [ASImageNode new];
            self.rateMessageImg.zPosition = MAXFLOAT;
            [self addSubnode:self.rateMessageImg];
            self.rateMessageImg.borderColor = [UIColor whiteColor].CGColor;
            self.rateMessageImg.borderWidth = 1.0f;
            self.rateMessageImg.cornerRadius = 10.0;
        }
        self.rateMessageImg.image = self.weakData.rateMessage == 1?[UIImage imageNamed:@"like_option_menu_cell"]:[UIImage imageNamed:@"error_option_menu_cell"];
    }
}
- (void) checkShowSendExpertMessage {
    if (self.weakData.sendExpertState == 0) {
    }
    else {
        if (!self.sendExpertImg) {
            self.sendExpertImg = [ASImageNode new];
            self.sendExpertImg.zPosition = MAXFLOAT;
            [self addSubnode:self.sendExpertImg];
            self.sendExpertImg.borderColor = [UIColor whiteColor].CGColor;
            self.sendExpertImg.borderWidth = 1.0f;
            self.sendExpertImg.cornerRadius = 10.0;
        }
        self.sendExpertImg.image = [UIImage imageNamed:@"request_expert_option_menu_cell"];
    }
}
- (void) showSendExpertMessage {
    [self checkShowSendExpertMessage];
    [self calculateFrame];
}
- (void) addPlusBtn {
    self.plusBtn = [ASButtonNode new];
    self.plusBtn.backgroundColor = [UIColor clearColor];
    [self.plusBtn setImage: [Utils image:[UIImage imageNamed:@"plus_btn"] size:CGSizeMake(19, 19)] forState:ASControlStateNormal];
    [self.plusBtn addTarget:self action:@selector(showOptionMenu) forControlEvents:ASControlNodeEventTouchUpInside];
    [self addSubnode:self.plusBtn];
}
- (void) addOpenLinkBtn {
    self.openLinkBtn = [ASButtonNode new];
    [self.openLinkBtn setImage: [Utils image:[UIImage imageNamed:@"open_link_btn"] size:CGSizeMake(20, 20)] forState:ASControlStateNormal];
    [self addSubnode:self.openLinkBtn];
}
@end

