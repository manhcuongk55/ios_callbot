//
//  ChatController.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "BaseViewController.h"
#import "MessageData.h"
#import "ChatTableView.h"
#import "ChatBox.h"

@interface ChatController : BaseViewController

@property (nonatomic, strong) ChatTableView *listNode;
@property (nonatomic, strong) ChatBox *chatBox;
- (void) didReceiveTextMsg: (MessageData *) data;
- (void) receiveAnswerNotification: (NSDictionary *) json;
- (void) processTappedNoti;
@end
