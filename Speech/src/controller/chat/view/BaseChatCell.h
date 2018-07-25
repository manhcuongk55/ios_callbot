//
//  BaseChatCell.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "MessageData.h"
#import "OptionMenuChatCell.h"

@interface BaseChatCell : ASCellNode

- (instancetype)initWithData: (MessageData *) data;

@property (nonatomic, strong) UIImageView *avatarImg;
@property (nonatomic, strong) OptionMenuButton *sendExpertBtn;
@property (nonatomic, strong) ASImageNode *rateMessageImg;
@property (nonatomic, strong) ASImageNode *sendExpertImg;
@property (nonatomic, strong) ASButtonNode *plusBtn;
@property (nonatomic, strong) ASButtonNode *openLinkBtn;
@property (nonatomic, weak) MessageData *weakData;

- (void) calculateFrame;

- (void) addAvatarImg;

- (CGRect) getBubbleRect;

- (void) setSelectBubble: (BOOL) selected;
- (void) showRateMessage;
- (void) checkShowRateMessage;
- (void) checkShowSendExpertMessage;
- (void) showSendExpertMessage;
- (void) addPlusBtn;
- (void) addOpenLinkBtn;
@end
