//
//  ChatController.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "ChatController.h"
#import "ChatBox.h"
#import "Manager.h"
#import "Speech-Swift.h"
#import "ProfileNode.h"
#import "DatabaseControl.h"
#import "NotificationController.h"
#import "TtsVTCCControl.h"

@interface ChatController () <ChatBoxDelegate> {
    float keyboardHi;
    ProfileNode *profileNode;
    ASButtonNode *speakerBtn;
}
@end

@implementation ChatController

- (instancetype)init
{
    self = [super initWithNode:[ASDisplayNode new]];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    [Manager instance].currentChatVC = self;
    self.node.backgroundColor = [UIColor whiteColor];
    
    self.listNode = [[ChatTableView alloc] init];
    [self.node addSubnode:self.listNode];
    
    self.chatBox = [[ChatBox alloc] init];
    self.chatBox.delegate = self;
    [self.node addSubnode:self.chatBox];
    
    [self addNavBar];
    [self.navBar setTitle:@"Trợ lý ảo"];
    [self.navBar.rightBtn setImage:[Utils image:[UIImage imageNamed:@"more_nav"] size:CGSizeMake(20, 20)] forState:ASControlStateNormal];
    [self.navBar.leftBtn addRedNode:CGPointMake(28, 9)];
    [self.navBar.leftBtn showRedNode:NO];
    [self.navBar.leftBtn setImage:[Utils image:[UIImage imageNamed:@"notify_nav"] size:CGSizeMake(18, 22)] forState:ASControlStateNormal];
    //
    [self.navBar.rightBtn addTarget:self action:@selector(handleRightNavBtnClick) forControlEvents:ASControlNodeEventTouchUpInside];
    [self.navBar.leftBtn addTarget:self action:@selector(handleLeftNavBtnClick) forControlEvents:ASControlNodeEventTouchUpInside];
    //
    speakerBtn = [ASButtonNode new];
    speakerBtn.selected = [GVUserDefaults standardUserDefaults].muteSetting.length > 0;
    [speakerBtn setImage:[Utils image:[UIImage imageNamed:@"speaker_nav"] size:CGSizeMake(23, 23)] forState:ASControlStateNormal];
    [speakerBtn setImage:[Utils image:[UIImage imageNamed:@"speaker_off_nav"] size:CGSizeMake(23, 23)] forState:ASControlStateSelected];
    [speakerBtn addTarget:self action:@selector(handleClickSpeaker:) forControlEvents:ASControlNodeEventTouchUpInside];
    [self.navBar addSubnode: speakerBtn];
    //
    profileNode = [ProfileNode new];
    // Listen for keyboard appearances and disappearances
    keyboardHi = 0.0;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}
- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self calculateFrame];
}
- (void) calculateFrame {
    CGRect rect = [self getContentRect];
    
    rect.origin.x = 0;
    if (keyboardHi > 0) {
        rect.origin.y = self.node.bounds.size.height - keyboardHi - self.chatBox.hiContent;
    }
    else {
        rect.origin.y = rect.origin.y + rect.size.height - self.chatBox.hiContent - keyboardHi;
    }
    rect.size.width = self.node.bounds.size.width;
    rect.size.height = self.chatBox.hiContent;
    self.chatBox.frame = rect;
    
    rect = [self getContentRect];
    rect.origin.y += 44;
    rect.size.height = self.chatBox.frame.origin.y - rect.origin.y;
    if (rect.size.height < 0) rect.size.height = 0;
    self.listNode.frame = rect;
    
    profileNode.frame = self.node.bounds;
    //
    rect = [self getContentRect];
    rect.origin.y = 0;
    rect.origin.x = rect.origin.x + rect.size.width - 44 - 44;
    rect.size.width = 44;
    rect.size.height = 44;
    speakerBtn.frame = rect;
}
#pragma mark ChatBoxDelegate
- (void) didSendTextMsg:(NSString *)text {
    
    MessageData *data = [MessageData new];
    data.type = MessageTypeText;
    data.fromMe = YES;
    data.textMsg = text;
    [self.listNode addMsgData:data];
    [[DatabaseControl instance] saveMessage:data];
    [data sendMessage];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{

        [self addTypingMsg];

    });
}
- (void) addTypingMsg {
    MessageData *data = [MessageData new];
    data.type = MessageTypeTyping;
    data.fromMe = NO;
    data.textMsg = @"...";
    [self.listNode addMsgData:data];
}
- (void) didReceiveTextMsg: (MessageData *) data {
    if (![data.textVoice isKindOfClass:[NSNull class]] && data.textVoice && data.textVoice.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [TTSVocalizer sharedInstance].muteSetting = [GVUserDefaults standardUserDefaults].muteSetting.length > 0;
            //[[TTSVocalizer sharedInstance] vocalize: data.textVoice];
            [[TtsVTCCControl instance] vocalize: data.textVoice];
        });
    }
    [[DatabaseControl instance] saveMessage: data];
    [self.listNode addMsgData:data];
}
- (void) receiveAnswerNotification: (NSDictionary *) json {
    MessageData *data = [MessageData new];
    data.type = MessageTypeAnswerNotification;
    data.fromMe = NO;
    data.jsonNotification = json;
    data.msgId = json[@"answerId"];
    //
    [[DatabaseControl instance] saveMessage: data];
    [self.listNode addMsgData:data];
}
- (void) updateFrameChatBox {
    if (self.chatBox.frame.size.height != self.chatBox.hiContent) {
        [self calculateFrame];
    }
}
// Keyboard show/hide
- (void)keyboardDidShow: (NSNotification *) notif {
    
    CGFloat duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        keyboardHi = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [self calculateFrame];
    } completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif {
    keyboardHi = 0.0;
    [self calculateFrame];
}
// Hide/Show statusbar
- (BOOL) prefersStatusBarHidden {
    if (profileNode && profileNode.supernode == self.node) {
        return YES;
    }
    else {
        return NO;
    }
}
// nav clicked
- (void) handleRightNavBtnClick {
    [self.chatBox resignChatBox];
    [self.node addSubnode:profileNode];    
    [self setNeedsStatusBarAppearanceUpdate];
    [profileNode setShow:YES];
}
- (void) handleLeftNavBtnClick {
    [self.chatBox resignChatBox];
    [self.navigationController pushViewController:[Manager instance].notificationVC animated:YES];
}
- (void) processTappedNoti {
    if ([Manager instance].notificationVC && [Manager instance].myUser.username.length > 0) {
        if ([Manager instance].listTappedNotifications.count > 0) {
            if (![Manager instance].notificationVC.isShow) {
                [self.chatBox resignChatBox];
                [self.navigationController pushViewController:[Manager instance].notificationVC animated:YES];
                [[Manager instance].notificationVC refreshData];
                [[Manager instance].listTappedNotifications removeAllObjects];
            }
        }
    }
}
- (void) handleClickSpeaker: (ASButtonNode *) sender{
    if (sender.selected) {
        [GVUserDefaults standardUserDefaults].muteSetting = @"";
        [TTSVocalizer sharedInstance].muteSetting = [GVUserDefaults standardUserDefaults].muteSetting.length > 0;
        [sender setSelected:!sender.selected];
    }
    else {
        [GVUserDefaults standardUserDefaults].muteSetting = @"1";
        [TTSVocalizer sharedInstance].muteSetting = [GVUserDefaults standardUserDefaults].muteSetting.length > 0;
        [sender setSelected:!sender.selected];
    }
    [[TtsVTCCControl instance] setMute:[GVUserDefaults standardUserDefaults].muteSetting.length > 0];
}
@end
