//
//  ChatTableView.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "ChatTableView.h"
#import "TextMessageCell.h"
#import "Utils.h"
#import "TypingCell.h"
#import "OptionMenuChatCell.h"
#import "DatabaseControl.h"
#import "MJRefresh.h"
#import "Speech-Swift.h"
#import "Manager.h"
#import "AnswerNotificationCell.h"
#import "ImageMessageCell.h"
#import "WeatherMessageCell.h"
#import "MusicMessageCell.h"
#import "WebViewMessageCell.h"

@interface ChatTableView () <ASTableDelegate, ASTableDataSource> {
    NSMutableArray *datas;
    OptionMenuChatCell *optionMenuForCell;
    ASDisplayNode *overlayBtn;
    BOOL isFirstRun;
    long isFirtLoadDb;
    long long minMsgId;
    BOOL hasMoreData;
    ASDisplayNode *tableHeader;
    NVActivityIndicatorView *activity;
}
@property (nonatomic, weak) BaseChatCell *selectedCell;
@property (nonatomic, strong) MJRefreshNormalHeader *mjheader;
@end

@implementation ChatTableView

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
        isFirstRun = YES;
        isFirtLoadDb = YES;
        hasMoreData = YES;
        //
        datas = [NSMutableArray new];
        //
        minMsgId = -1;
        //
        self.tableView = [ASTableNode new];
        self.tableView.backgroundColor = [UIColor whiteColor];
        if ([Utils getIntSystemVersion] >= 11) {
            self.tableView.view.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            self.tableView.view.insetsLayoutMarginsFromSafeArea = NO;
        }
        self.tableView.view.estimatedRowHeight = 0;
        self.tableView.view.estimatedSectionHeaderHeight = 0;
        self.tableView.view.estimatedSectionFooterHeight = 0;
        self.tableView.view.contentInset = UIEdgeInsetsMake(10, 0, 44 + 20, 0);
        self.tableView.view.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.view.keyboardDismissMode = UIScrollViewKeyboardDismissModeOnDrag;
        self.tableView.anchorPoint = CGPointZero;
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self addSubnode:self.tableView];
        //
        tableHeader = [ASDisplayNode new];
        activity = [NVActivityIndicatorView createIndicatorView];
        activity.type = NVActivityIndicatorTypeBallRotateChase;
        activity.color = [Manager instance].colorBubbleFromBot;
        activity.padding = 5.0;
        activity.frame = CGRectMake(0, 0, 40, 40);
        [activity startAnimating];
        [tableHeader.view addSubview:activity];
        //
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTableview)];
        [self.tableView.view addGestureRecognizer:gesture];
    }
    return self;
}
- (void) layoutDidFinish {
    [super layoutDidFinish];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self loadMsgFromDb];
    });
}
- (void) loadMsgFromDb {
    if (isFirtLoadDb) {
        isFirtLoadDb = NO;
        [self loadMoreMessageFromDb];
    }
}
- (void) loadMoreMessageFromDb {
    BOOL isFirstLoad = NO;
    isFirstLoad = minMsgId == -1;
    NSMutableArray *listMsg = [[DatabaseControl instance] getMessagesHistory: minMsgId];
    hasMoreData = listMsg.count == 20;
    if (listMsg && listMsg.count > 0) {
        for (int i = 0; i < listMsg.count; i++) {
            MessageData *msg = listMsg[i];
            if (msg.localId < minMsgId || minMsgId == -1) {
                minMsgId = msg.localId;
            }
            [datas insertObject:msg atIndex:0];
        }
        NSMutableArray *listIdx = [NSMutableArray new];
        for (int i = 0; i < listMsg.count; i++) {
            [listIdx addObject:[NSIndexPath indexPathForRow:i inSection:0]];
        }
        //
        [UIView setAnimationsEnabled:NO];
        
        [self.tableView.view beginUpdates];
        [self.tableView.view insertRowsAtIndexPaths:listIdx withRowAnimation:UITableViewRowAnimationNone];
        [self.tableView.view endUpdatesAnimated:NO completion:^(BOOL completed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.tableView.view.contentSize.height + self.tableView.view.contentInset.bottom + self.tableView.view.contentInset.top < self.tableView.view.frame.size.height) {
                    [self.tableView.view setContentOffset:CGPointMake(0, - self.tableView.view.contentInset.top) animated:NO];
                }
                else {
                    if (isFirstLoad) {
                        int idx = listMsg.count - 1;
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: idx inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                    }
                    else {
                        int idx = listMsg.count - 2;
                        if (idx < 0) idx = 0;
                        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow: idx inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                    }
                }
                isFirstRun = NO;
                self.tableView.view.tableHeaderView = nil;
                [UIView setAnimationsEnabled:YES];
                
                [self checkCreateNotiVC];
                [[Manager instance].currentChatVC processTappedNoti];
                [[Manager instance] sendFirebaseToken];
            });
        }];
    }
    else {
        if (isFirstLoad) {
            MessageData *data = [MessageData new];
            data.type = MessageTypeText;
            data.fromMe = NO;
            data.textMsg = @"Xin chào bạn!";
            [datas addObject:data];
            
            [self.tableView.view beginUpdates];
            [self.tableView.view insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: 0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
            [self.tableView.view endUpdatesAnimated:NO completion:^(BOOL completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.tableView.view setContentOffset:CGPointMake(0, - self.tableView.view.contentInset.top) animated:NO];
                    isFirstRun = NO;
                });
                
                [self checkCreateNotiVC];
                [[Manager instance].currentChatVC processTappedNoti];
                [[Manager instance] sendFirebaseToken];
            }];
        }
        else {
            self.tableView.view.tableHeaderView = nil;
        }
    }
}
- (void) scrollToBottom: (BOOL) animated {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.tableView.view.contentSize.height + self.tableView.view.contentInset.bottom + self.tableView.view.contentInset.top < self.tableView.view.frame.size.height) {
            [self.tableView.view setContentOffset:CGPointMake(0, - self.tableView.view.contentInset.top) animated:NO];
        }
        else {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:datas.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
        }
    });
}
- (void) layout {
    [super layout];
    //
    float yCurrent = [Utils getCurrentYEndContent:self.tableView.view];
    //
    self.tableView.bounds = self.bounds;
    //
    if (self.selectedCell) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{            
            [self calculateFrameOptionMenuForCell:self.selectedCell];
        });
    }
    //
    [Utils scrollToYEndContent:yCurrent scrollView:self.tableView.view];
    tableHeader.frame = CGRectMake(0, 0, self.bounds.size.width, 60);
    activity.frame = CGRectMake((tableHeader.bounds.size.width - activity.frame.size.width)/2.0, (tableHeader.bounds.size.height - activity.frame.size.height)/2.0, activity.frame.size.width, activity.frame.size.height);
}
- (void) addMsgData: (MessageData *) msgData {
    [self tapOverlayBtn];
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isTypingMsg = (!msgData.fromMe && msgData.type == 2);
        if (msgData.fromMe || isTypingMsg) { // fromMe hoac Typing Msg
            
            [self.tableView.view beginUpdates];
            
            BOOL isShowTyping = [self isShowTyping];
            if (isShowTyping) {
                if (!isTypingMsg) {
                    int idx = datas.count - 1;
                    [datas insertObject:msgData atIndex: idx];
                    [self.tableView.view insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: idx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
                }
            }
            else {
                [datas addObject:msgData];
                [self.tableView.view insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datas.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            [self.tableView.view endUpdatesAnimated:YES completion:^(BOOL completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToBottom: YES];
                });
            }];
        }
        else {
            [self.tableView.view beginUpdates];
            
            if ([self isShowTyping]) {
                int lastIdx = datas.count - 1;
                [datas removeLastObject];
                [self.tableView.view deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow: lastIdx inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            }
            [datas addObject:msgData];
            [self.tableView.view insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:datas.count-1 inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            
            [self.tableView.view endUpdatesAnimated:YES completion:^(BOOL completed) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self scrollToBottom: YES];
                });
            }];
        }
    });
}
- (BOOL) isShowTyping {
    BOOL isShow = NO;
    if (datas && datas.count > 0) {
        int lastIdx = datas.count - 1;
        MessageData *lastMsgData = datas[lastIdx];
        if (lastMsgData.type == 2) {
            isShow = YES;
        }
    }
    return isShow;
}
#pragma mark - table delegate & datasource
- (void)tableNode:(ASTableNode *)tableNode_ didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableNode_ deselectRowAtIndexPath:indexPath animated:NO];
    [[Manager instance].currentChatVC.chatBox resignChatBox];
}
- (void) tableNode:(ASTableNode *)tableNode willDisplayRowWithNode:(ASCellNode *)node {
    if ([node isKindOfClass:[WebViewMessageCell class]]) {
        WebViewMessageCell *cell = node;
        [cell willDisplay];
    }
}
//- (void) scrollViewWillBeginDragging:(UIScrollView *)scrollView {
//    for (int i = 0; i<datas.count; i++) {
//        MessageData *itemData = datas[i];
//        ASCellNode *node = itemData.weakCell;
//        if ([node isKindOfClass:[WebViewMessageCell class]]) {
//            WebViewMessageCell *cell = node;
//            [cell willBeginDragging];
//        }
//    }
//}
//- (void) scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    for (int i = 0; i<datas.count; i++) {
//        MessageData *itemData = datas[i];
//        ASCellNode *node = itemData.weakCell;
//        if ([node isKindOfClass:[WebViewMessageCell class]]) {
//            WebViewMessageCell *cell = node;
//            [cell didEndDragging: decelerate];
//        }
//    }
//}
//- (void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
//    for (int i = 0; i<datas.count; i++) {
//        MessageData *itemData = datas[i];
//        ASCellNode *node = itemData.weakCell;
//        if ([node isKindOfClass:[WebViewMessageCell class]]) {
//            WebViewMessageCell *cell = node;
//            [cell didEndDecelerating];
//        }
//    }
//}
- (void) tableNode:(ASTableNode *)tableNode didEndDisplayingRowWithNode:(ASCellNode *)node {
    if ([node isKindOfClass:[WebViewMessageCell class]]) {
        WebViewMessageCell *cell = node;
        [cell didEndDisplay];
    }
}
- (ASSizeRange)tableNode:(ASTableNode *)tableNode constrainedSizeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageData *data = datas[indexPath.row];
    float minScr = [[UIScreen mainScreen] bounds].size.width;
    if (minScr > [[UIScreen mainScreen] bounds].size.height) {
        minScr = [[UIScreen mainScreen] bounds].size.height;
    }
    [data calculateSize: minScr];
    return ASSizeRangeMake(CGSizeMake(self.bounds.size.width, [data getHeight]));
}

- (NSInteger)numberOfSectionsInTableNode:(ASTableNode *)tableNode {
    return 1;
}

- (NSInteger)tableNode:(ASTableNode *)tableNode numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}
- (ASCellNode *)tableNode:(ASTableNode *)tableNode nodeForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageData *data = datas[indexPath.row];
    if (data.weakCell) {
        BaseChatCell *weakCell = data.weakCell;
        [weakCell calculateFrame];
        return weakCell;
    }
    if (data.type == MessageTypeText) { // text
        TextMessageCell *cell = [[TextMessageCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypeTyping) { // typing
        TypingCell *cell = [[TypingCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypeAnswerNotification) { // answer notification
        AnswerNotificationCell *cell = [[AnswerNotificationCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypePhoto) { // photo
        ImageMessageCell *cell = [[ImageMessageCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypeWeather) { // photo
        WeatherMessageCell *cell = [[WeatherMessageCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypeMusic) { // photo
        MusicMessageCell *cell = [[MusicMessageCell alloc] initWithData:data];
        return cell;
    }
    else if (data.type == MessageTypeWebView) { // photo
        WebViewMessageCell *cell = [[WebViewMessageCell alloc] initWithData:data];
        return cell;
    }
    return [BaseChatCell new];
}
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (!isFirstRun && hasMoreData && scrollView.contentOffset.y < 30 && !self.tableView.view.tableHeaderView) {
        self.tableView.view.tableHeaderView = tableHeader.view;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self loadMoreMessageFromDb];
        });
    }
}
// Option menu for cell
- (void) hideOptionMenuForCell {
    [self tapOverlayBtn];
}
- (void) showOptionMenuForCell: (ASCellNode *) cell {
    self.selectedCell = cell;
    if (!optionMenuForCell) {
        optionMenuForCell = [[OptionMenuChatCell alloc] init];
        overlayBtn = [ASDisplayNode new];
        //overlayBtn.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.35];
        UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOverlayBtn:)];
        [overlayBtn.view addGestureRecognizer:gesture];
        
        UITapGestureRecognizer *gesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOverlayBtn)];
        [overlayBtn.view addGestureRecognizer:gesture2];
        
        overlayBtn.zPosition = MAXFLOAT;
        optionMenuForCell.zPosition = MAXFLOAT;
    }
    [overlayBtn removeFromSupernode];
    [optionMenuForCell removeFromSupernode];
    [self.tableView addSubnode:overlayBtn];
    [self.tableView addSubnode:optionMenuForCell];
    self.tableView.view.scrollEnabled = NO;
    [self calculateFrameOptionMenuForCell:self.selectedCell];
    
    [self.selectedCell setSelectBubble:YES];
    optionMenuForCell.weakCell = cell;
    optionMenuForCell.alpha = 0.0f;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        optionMenuForCell.alpha = 1.0f;
    } completion:nil];
}
- (void) calculateFrameOptionMenuForCell: (BaseChatCell *) cell {
    BaseChatCell *baseCell = (BaseChatCell *) cell;
    CGRect rect = [self.tableView rectForRowAtIndexPath: baseCell.indexPath];
    CGRect bubbleRect = [baseCell getBubbleRect];
    float x = bubbleRect.origin.x;
    float wi = [cell.weakData canSendExpert]?337:202;
    if (x + wi > self.bounds.size.width) {
        x = (self.bounds.size.width - wi)/2.0f;
    }
    optionMenuForCell.frame = CGRectMake(x, rect.origin.y + bubbleRect.origin.y + bubbleRect.size.height + 5, wi, 40);
    overlayBtn.frame = CGRectMake(self.tableView.view.contentOffset.x, self.tableView.view.contentOffset.y, self.tableView.frame.size.width, self.tableView.frame.size.height);
}
- (void) panOverlayBtn: (UIPanGestureRecognizer *) gesture{
    if (gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateCancelled) {
        [self tapOverlayBtn];
    }
}
- (void) tapOverlayBtn {
    [self.selectedCell setSelectBubble:NO];
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        optionMenuForCell.alpha = 0.0f;
    } completion:^(BOOL finished) {
        self.selectedCell = nil;
        self.tableView.view.scrollEnabled = YES;
        [overlayBtn removeFromSupernode];
        [optionMenuForCell removeFromSupernode];
    }];
}
- (void) tapTableview {
    [[Manager instance].currentChatVC.chatBox resignChatBox];
}
- (void) checkCreateNotiVC {
    if (![Manager instance].notificationVC) {
        [Manager instance].notificationVC = [NotificationController new];
    }
}
@end
