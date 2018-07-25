//
//  NotificationControllerViewController.m
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "NotificationController.h"
#import "Manager.h"
#import "NotificationCell.h"
#import "HTTPNetworkControl.h"
#import "MJRefresh.h"
#import "InputAnswerView.h"
#import "AnswerView.h"
#import "MessageData.h"

@interface NotificationController () <ASTableDelegate, ASTableDataSource> {
    ASTableNode *table;
    float keyboardHi;
    NSMutableArray *tableDatas;
    InputAnswerView *inputAnswerView;
    AnswerView *answerView;
    NSTimer *timerUpdate;
    ASDisplayNode *noDataView;
    ASTextNode *noNotificationsText;
    BOOL hasNewNotifi;
}
@property (nonatomic, strong) MJRefreshNormalHeader *mjheader;
@end

@implementation NotificationController

- (instancetype)init
{
    self = [super initWithNode:[ASDisplayNode new]];
    if (self) {
        self.automaticallyAdjustsScrollViewInsets = NO;
        self.node.backgroundColor = [UIColor whiteColor];
        
        hasNewNotifi = NO;
        
        table = [[ASTableNode alloc] init];
        table.view.separatorStyle = UITableViewCellSeparatorStyleNone;
        table.delegate = self;
        table.dataSource = self;
        [self.node addSubnode: table];
        
        [self addNavBar];
        //
        noDataView = [ASDisplayNode new];
        noNotificationsText = [ASTextNode new];
        noNotificationsText.attributedText = [[NSAttributedString alloc] initWithString: @"Không có thông báo!" attributes:[self textStyle]];
        [noDataView addSubnode:noNotificationsText];
        //
        [self.navBar setTitle:@"Thông báo"];
        [self.navBar.leftBtn setImage:[Utils image:[Utils image:[UIImage imageNamed:@"back_btn"] size:CGSizeMake(18, 18)] color:[Manager instance].colorBubbleFromBot] forState:ASControlStateNormal];
        [self.navBar.leftBtn addTarget:self action:@selector(handleLeftNavBtnClick) forControlEvents:ASControlNodeEventTouchUpInside];
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
        
        self.mjheader = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(requestGetListNotification)];
        self.mjheader.automaticallyChangeAlpha = YES;
        self.mjheader.lastUpdatedTimeLabel.hidden = YES;
        [self.mjheader setTitle:@"Kéo thả để cập nhật" forState:MJRefreshStateIdle];
        [self.mjheader setTitle:@"Kéo thả để cập nhật" forState:MJRefreshStatePulling];
        [self.mjheader setTitle:@"Đang tải..." forState:MJRefreshStateRefreshing];
        table.view.mj_header = self.mjheader;
        
        inputAnswerView = [InputAnswerView new];
        answerView = [AnswerView new];
        [self requestGetListNotification];
    }
    return self;
}
- (void) viewDidLoad {
    [super viewDidLoad];
}
- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    hasNewNotifi = NO;
    [[Manager instance].currentChatVC.navBar.leftBtn showRedNode:hasNewNotifi];
    self.isShow = NO;
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isShow = YES;
}
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self calculateFrame];
}
- (void) calculateFrame {
    CGRect rect = [self getContentRect];
    
    rect = [self getContentRect];
    rect.origin.y += 44;
    rect.size.height = self.node.bounds.size.height - rect.origin.y;
    if (rect.size.height < 0) rect.size.height = 0;
    table.frame = rect;
    noDataView.frame = table.frame;
    CGSize size = [noNotificationsText calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    noNotificationsText.frame = CGRectMake((noDataView.frame.size.width - size.width)/2.0, 65, size.width, size.height);
    inputAnswerView.frame = self.node.bounds;
    answerView.frame = self.node.bounds;
}
#pragma mark - table delegate & datasource
- (void)tableNode:(ASTableNode *)tableNode_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode_ deselectRowAtIndexPath:indexPath animated:NO];
    NSDictionary *data = tableDatas[indexPath.row];
    NSNumber *type = data[@"va_app_type"];
    if (type.intValue == 1) {
        [self showInputForAnswer:data];
    }
    else if (type.intValue == 2) {
        [self showAnswerView:data];
    }
}

- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    return ASSizeRangeMake(CGSizeMake(self.node.bounds.size.width, 79));
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return tableDatas.count;
}
- (ASCellNode *)tableNode:(ASTableNode *)tableNode nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *data = tableDatas[indexPath.row];
    NotificationCell *cell = [[NotificationCell alloc] initWithData: data];
    return cell;
}
- (void) tableNode:(ASTableNode *)tableNode_ willDisplayRowWithNode:(ASCellNode *)node {
}
// Keyboard show/hide
- (void)keyboardDidShow: (NSNotification *) notif {
    
    CGFloat duration = [notif.userInfo[UIKeyboardAnimationDurationUserInfoKey] floatValue];
    NSInteger curve = [notif.userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    [UIView animateWithDuration:duration delay:0 options:curve animations:^{
        keyboardHi = [notif.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
        [self calculateFrame];
        if (inputAnswerView && inputAnswerView.supernode == self.node) [inputAnswerView updateKeyboardHeight:keyboardHi];
    } completion:nil];
}

- (void)keyboardDidHide: (NSNotification *) notif {
    keyboardHi = 0.0;
    [self calculateFrame];
    if (inputAnswerView && inputAnswerView.supernode == self.node) [inputAnswerView updateKeyboardHeight: 0];
}
- (void) handleLeftNavBtnClick {
    [self.navigationController popViewControllerAnimated:YES];
}
// Get expert questions
- (void) checkHasNewNotification {
    [self requestGetListNotification];
}
- (void) requestGetListNotification {
    if ([Manager instance].myUser.username.length == 0) {
        return;
    }
    table.view.tableFooterView = nil;
    NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                             @"userId" : @([Manager instance].myUser.userId),
                             @"token" : [Manager instance].myUser.token};
    NSString *url = [HTTPNetworkControl instance].URL_GET_NOTIFI_ANSWERS;
    if ([[Manager instance].myUser isExpert]) {
        url = [HTTPNetworkControl instance].URL_GET_NOTIFI_QUESTIONS;
    }
    [[HTTPNetworkControl instance] requestPOST:url params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        [self.mjheader endRefreshing];
        
        if ([Manager instance].myUser.username.length == 0) {
            return;
        }
        
        NSDictionary *reponse = responseObj;
        //NSLog(@"response %@", reponse);
        NSNumber *status = reponse[@"status"];
        if (status.intValue == 200) {
            int type = 1;
            NSArray *list = reponse[@"questionList"];
            if (!list) {
                list = reponse[@"answerList"];
                type = 2;
            }
            
            NSArray *sortedArray;
            sortedArray = [list sortedArrayUsingComparator:^NSComparisonResult(id a, id b) {
                NSNumber *first = a[@"createdTime"];
                NSNumber *second = b[@"createdTime"];
                return [second compare:first];
            }];
            list = [[NSArray alloc] initWithArray:sortedArray];
            
            NSMutableArray *finalList = [NSMutableArray new];
            for (int i = 0; i<list.count; i++) {
                NSMutableDictionary *dicItem = [[NSMutableDictionary alloc] initWithDictionary:list[i]];
                dicItem[@"va_app_type"] = @(type);
                NSString *msgId = @"";
                if (type == 1) {
                    msgId = dicItem[@"mid"];
                }
                else if (type == 2) {
                    msgId = dicItem[@"answerId"];
                }
                if (msgId && msgId.length > 0) {
                    if (![Manager instance].jsonAnswerIdNotifi[msgId]) {
                        hasNewNotifi = YES;
                        if (type == 2) {
                            // Notify
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [[Manager instance].currentChatVC receiveAnswerNotification:dicItem];
                            });
                        }
                        [[Manager instance] saveAnswerIdToJsonData:msgId];
                        [[Manager instance].currentChatVC.navBar.leftBtn showRedNode:hasNewNotifi];
                    }
                }
                [finalList addObject:dicItem];
            }
            tableDatas = [[NSMutableArray alloc] initWithArray: finalList];
        }
        else {
            NSString *message = reponse[@"error"];
            if (message && message.length > 0) {} else {message = @"Có lỗi xảy ra!";}
            tableDatas = [NSMutableArray new];
        }
        if (table.frame.size.height > 0 && table.frame.size.width > 0) {
            [table reloadData];
        }
        if (tableDatas.count == 0) {
            table.view.tableFooterView = noDataView.view;
        }
        [self waitAndReloadNotifications];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self.mjheader endRefreshing];
        if ([Manager instance].myUser.username.length == 0) {
            return;
        }
        [self waitAndReloadNotifications];
    }];
}
- (void) sendAnswer: (NSDictionary *) question answer: (NSString *) answer {
    [Utils showLoadingHUDInView:[Manager instance].notificationVC.view];
    NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                             @"userId" : @([Manager instance].myUser.userId),
                             @"token" : [Manager instance].myUser.token,
                             @"mid" : question[@"mid"],
                             @"answer": answer,
                             };
    [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_PUSH_ANSWER params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        [Utils hideLoadingHUDInView:[Manager instance].notificationVC.view];
        NSDictionary *reponse = responseObj;
        //NSLog(@"response %@", reponse);
        NSNumber *status = reponse[@"status"];
        if (status.intValue == 200) {
            [Utils showToastHUDInView:[Manager instance].notificationVC.view withMessage:@"Gửi câu trả lời thành công!"];
            [inputAnswerView close];
        }
        else {
            NSString *message = reponse[@"error"];
            if (message && message.length > 0) {} else {message = @"Có lỗi xảy ra!";}
            [Utils showToastHUDInView:[Manager instance].notificationVC.view withMessage: message];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [Utils hideLoadingHUDInView:[Manager instance].notificationVC.view];
        [Utils showToastHUDInView:[Manager instance].notificationVC.view withMessage:@"Có lỗi xảy ra!"];
    }];
}
// Hide/Show statusbar
- (BOOL) prefersStatusBarHidden {
    if (answerView && answerView.supernode == self.node) {
        return YES;
    }
    if (inputAnswerView && inputAnswerView.supernode == self.node) {
        return YES;
    }
    return NO;
}
// Show input
- (void) showInputForAnswer: (NSDictionary *) question {
    [self.node addSubnode:inputAnswerView];
    [self setNeedsStatusBarAppearanceUpdate];
    [inputAnswerView updateWithData:question];
    [inputAnswerView setShow:YES];
}
- (void) showAnswerView: (NSDictionary *) answer {
    [self.node addSubnode:answerView];
    [self setNeedsStatusBarAppearanceUpdate];
    [answerView updateWithData:answer];
    [answerView setShow:YES];
}
- (void) waitAndReloadNotifications {
    if (timerUpdate) {
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
    timerUpdate = [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(checkHasNewNotification) userInfo:nil repeats:NO];
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:20.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0],
             };
}
- (void) cleanData {
    tableDatas = [NSMutableArray new];
    hasNewNotifi = NO;
    if (timerUpdate) {
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
    if (table.frame.size.height > 0 && table.frame.size.width > 0) {
        [table reloadData];
    }
}
- (void) refreshData {
    [self requestGetListNotification];
    //[self.mjheader beginRefreshing];
}
- (void) dealloc {
    if (timerUpdate) {
        [timerUpdate invalidate];
        timerUpdate = nil;
    }
}
@end
