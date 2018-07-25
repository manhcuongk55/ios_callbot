//
//  MessageData.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "MessageData.h"
#import "HTTPNetworkControl.h"
#import "Manager.h"
#import "BaseChatCell.h"
#import "DatabaseControl.h"
#import "AnswerNotificationCell.h"
#import "TextMessageCell.h"
#import "NSAttributedString+DDHTML.h"
#import "WebViewMessageCell.h"

@import Firebase;

@interface MessageData () {
    CGSize sizeMsg;
    NSTimer *timerSendMsg;
    NSTimer *timerGetAnswer;
    int countRetrySendMsg;
    int countRetryGetAnswer;
}
@end

@implementation MessageData

static ASTextNode *textNode = nil;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.localId = [[NSDate date] timeIntervalSince1970]*1000;
        self.timestamp = self.localId;
        sizeMsg = CGSizeMake(-1, -1);
        countRetrySendMsg = 0;
        countRetryGetAnswer = 0;
        self.answerIdx = -1;
        self.rateMessage = 0;
        self.sendExpertState = 0;
        self.htmlRatio = 1.0f;
    }
    return self;
}
- (void) setHtmlRatio:(float)htmlRatio {
    if (htmlRatio != _htmlRatio && fabs(htmlRatio - _htmlRatio) >= 0.02) {
        _htmlRatio = htmlRatio;
        sizeMsg.width = -1;
        if (self.weakCell) {
            WebViewMessageCell *cell = self.weakCell;
            [[Manager instance].currentChatVC.listNode.tableView reloadRowsAtIndexPaths:@[cell.indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}
- (void) calculateSize: (float) wiCell {
    if (sizeMsg.width <= -1) {
        if (!textNode) {
            textNode = [ASTextNode new];
        }
        if (self.type == MessageTypeText) {
            textNode.attributedText = [NSAttributedString attributedStringFromHTMLForVBrowser: self.textMsg defaultTextColor:[UIColor blackColor]];
            sizeMsg = [textNode calculateSizeThatFits:CGSizeMake(wiCell * 0.65f, MAXFLOAT)];
            // Text
            self.textRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // source
            if (self.source && self.source.length > 0) {
                textNode.attributedText = [[NSAttributedString alloc] initWithString: self.source attributes:[TextMessageCell sourceStyle]];
                CGSize sizeSource = [textNode calculateSizeThatFits:CGSizeMake(wiCell * 0.65f, MAXFLOAT)];
                self.sourceRect = CGRectMake(0, 0, sizeSource.width, sizeSource.height);
                if (sizeSource.width > sizeMsg.width) {
                    sizeMsg.width = sizeSource.width;
                }
                sizeMsg.height += 7 + sizeSource.height + 5;
            }
            // Bubble
            sizeMsg.height += 20;
            sizeMsg.width += 30;
            self.bubbleRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // Top margin
            sizeMsg.height += 10;
            //
            if (self.listOtherAnswer && self.listOtherAnswer.count > 0) {
                sizeMsg.height += 15;
                sizeMsg.height += 35;
            }
            
            //Bottom margin
            sizeMsg.height += 10;
            
            //
//            if ([self canSendExpert]) {
//                sizeMsg.height += 10;
//                sizeMsg.height += 35;
//            }
            // Avatar
            sizeMsg.width += 30 + 10;
            self.avatarRect = CGRectMake(0, 0, 30, 30);
        }
        else if (self.type == MessageTypeTyping) {
            sizeMsg = CGSizeMake(30, 20);
            // Text
            self.textRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // Bubble
            sizeMsg.height += 20;
            sizeMsg.width += 30;
            self.bubbleRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // Top margin
            sizeMsg.height += 10;
            // Avatar
            sizeMsg.width += 30 + 10;
            self.avatarRect = CGRectMake(0, 0, 30, 30);
        }
        else if (self.type == MessageTypeAnswerNotification) {
            // title
            textNode.attributedText = [[NSAttributedString alloc] initWithString: @"Câu trả lời từ chuyên gia:" attributes:[AnswerNotificationCell titleStyle]];
            sizeMsg = [textNode calculateSizeThatFits:CGSizeMake(wiCell * 0.65f, MAXFLOAT)];
            self.answerCellTitleRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // question
            textNode.attributedText = [[NSAttributedString alloc] initWithString: self.jsonNotification[@"question"] attributes:[AnswerNotificationCell questionStyle]];
            sizeMsg = [textNode calculateSizeThatFits:CGSizeMake(wiCell * 0.65f, MAXFLOAT)];
            self.answerCellQuestionRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            //
            textNode.attributedText = [[NSAttributedString alloc] initWithString:self.jsonNotification[@"answer"] attributes:[AnswerNotificationCell answerStyle]];
            sizeMsg = [textNode calculateSizeThatFits:CGSizeMake(wiCell * 0.65f, MAXFLOAT)];
            self.answerCellAnswerRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            //
            sizeMsg.height = self.answerCellTitleRect.size.height + 5 + self.answerCellQuestionRect.size.height + 7 + 10 + self.answerCellAnswerRect.size.height;
            sizeMsg.width = self.answerCellTitleRect.size.width;
            if (sizeMsg.width < self.answerCellQuestionRect.size.width) sizeMsg.width = self.answerCellQuestionRect.size.width;
            if (sizeMsg.width < self.answerCellAnswerRect.size.width) sizeMsg.width = self.answerCellAnswerRect.size.width;
            // content size
            sizeMsg.height += 7; // top
            sizeMsg.height += 10; // bottom
            sizeMsg.width += 30;
            self.bubbleRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // top margin
            sizeMsg.height += 10; // top
            sizeMsg.height += 10; // bottom
            // avatar
            sizeMsg.width += 30 + 10;
            self.avatarRect = CGRectMake(0, 0, 30, 30);
            //
        }
        else if (self.type == MessageTypePhoto) {
            // content size
            sizeMsg.height = 100;
            sizeMsg.height = 100;
            // top margin
            sizeMsg.height += 10; // top
            sizeMsg.height += 10; // bottom
            // avatar
            sizeMsg.width += 30 + 10;
            //
        }
        else if (self.type == MessageTypeWeather) {
            // content size
            sizeMsg.height = 100;
            sizeMsg.height = 100;
            // top margin
            sizeMsg.height += 10; // top
            sizeMsg.height += 10; // bottom
            // avatar
            sizeMsg.width += 30 + 10;
            //
        }
        else if (self.type == MessageTypeMusic) {
            // content size
            sizeMsg.height = 100;
            sizeMsg.height = 100;
            // top margin
            sizeMsg.height += 10; // top
            sizeMsg.height += 10; // bottom
            // avatar
            sizeMsg.width += 30 + 10;
            //
        }
        else if (self.type == MessageTypeWebView) {
            // content size
            if (wiCell >= 414) {
                wiCell = 414;
            }
            sizeMsg.width = wiCell - 20;
            sizeMsg.height = sizeMsg.width * self.htmlRatio;
            self.webViewRect = CGRectMake(0, 0, sizeMsg.width, sizeMsg.height);
            // top margin
            sizeMsg.height += 10; // top
            sizeMsg.height += 10; // bottom
            // avatar
            sizeMsg.height += 30 + 10;
            //
            self.avatarRect = CGRectMake(0, 0, 30, 30);
        }
    }
}
- (BOOL) canSendExpert {
    return !self.fromMe && self.type == 1 && self.answerCode == 2;
}
- (float) getHeight {
    return sizeMsg.height;
}
- (float) getWidth {
    return sizeMsg.width;
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
#pragma mark - send network
- (void) rateMessage: (BOOL) isLike {
    if (!self.msgId) {
        return;
    }
    self.rateMessage = isLike?1:2;
    [[DatabaseControl instance] updateRateMsg:self];
    [((BaseChatCell *)self.weakCell) showRateMessage];
    [Utils showLoadingHUDInView:[Manager instance].currentChatVC.view];
    NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                             @"userId" : @([Manager instance].myUser.userId),
                             @"token" : [Manager instance].myUser.token,
                             @"mid" : self.msgId,
                             @"rate" : isLike?@"like":@"dislike"};
    [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_RATE_ANSWER params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
        NSDictionary *reponse = responseObj;
        //NSLog(@"%@", reponse);
        NSNumber *status = reponse[@"status"];
        if (status.intValue == 200) {
            [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Nhận xét của bạn đã gửi thành công!"];
        }
        else {
            [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Có lỗi xảy ra!"];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        //NSLog(@"%@", error);
        [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
        [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Có lỗi xảy ra!"];
    }];
}
- (void) sendMessage {
    if ([Manager instance].myUser.username.length == 0) {
        return;
    }
    NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                             @"userId" : @([Manager instance].myUser.userId),
                             @"token" : [Manager instance].myUser.token,
                             @"message" : self.textMsg,
                             @"timestamp" : @(self.timestamp),
                             @"type": @"text"};
    [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_SEND_MESSAGE params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        NSDictionary *reponse = responseObj;
        //NSLog(@"test send mssg %@", responseObj);
        NSNumber *status = reponse[@"status"];
        if (status.intValue == 200) {
            self.msgId = reponse[@"mid"];
            [self waitAndRetryGetAnswer];
        }
        else {
            [self waitAndRetrySendMessage];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [self waitAndRetrySendMessage];
    }];
}
- (void) sendGetAnswer {
    if ([Manager instance].myUser.username.length == 0) {
        return;
    }
    if (self.msgId && self.msgId.length > 0) {
        NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                                 @"userId" : @([Manager instance].myUser.userId),
                                 @"token" : [Manager instance].myUser.token,
                                 @"mid" : self.msgId
                                 };
        [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_GET_ANSWER params:params success:^(NSURLSessionDataTask *task, id responseObj) {
            NSDictionary *reponse = responseObj;
            NSNumber *status = reponse[@"status"];
            //NSLog(@"test get answer %@", responseObj);
            if (status.intValue == 200) {
                // =========== FAKE MSG ===================
//                MessageData *data = [MessageData new];
//                data.type = MessageTypeWebView;
//                data.fromMe = NO;
//                data.jsonResponse = @{@"url": @"http://via.placeholder.com/300", @"question": self.textMsg};
//                data.msgId = @"123";
//                data.question = reponse[@"question"];
//                [[Manager instance].currentChatVC didReceiveTextMsg:data];
                // =======================================
                MessageData *data = [MessageData new];
                NSMutableDictionary *newDic = [[NSMutableDictionary alloc] initWithDictionary:reponse];
                newDic[@"question"] = self.textMsg;
                [MessageData readDataAnswerV1:newDic forMsg: data];
                [[Manager instance].currentChatVC didReceiveTextMsg:data];
            }
            else {
                [self waitAndRetryGetAnswer];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            [self waitAndRetryGetAnswer];
        }];
    }
}
- (void) waitAndRetrySendMessage {
    if (timerSendMsg) {
        [timerSendMsg invalidate];
        timerSendMsg = nil;
    }
    if (countRetrySendMsg == 3) {
        MessageData *data = [MessageData new];
        data.type = MessageTypeText;
        data.fromMe = NO;
        data.textMsg = @"Không có kết nối mạng hoặc Server có vấn đề!";
        //
        [[Manager instance].currentChatVC didReceiveTextMsg:data];
        return;
    }
    countRetrySendMsg ++;
    timerSendMsg = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(sendMessage) userInfo:nil repeats:NO];
}
- (void) waitAndRetryGetAnswer {
    if (timerGetAnswer) {
        [timerGetAnswer invalidate];
        timerGetAnswer = nil;
    }
    if (countRetryGetAnswer == 20) {
        MessageData *data = [MessageData new];
        data.type = MessageTypeText;
        data.fromMe = NO;
        data.textMsg = @"Có lỗi khi lấy câu trả lời!";
        //
        [[Manager instance].currentChatVC didReceiveTextMsg:data];
        return;
    }
    countRetryGetAnswer ++;
    timerGetAnswer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(sendGetAnswer) userInfo:nil repeats:NO];
}
+ (void) readDataAnswerV1:(NSDictionary *)reponse forMsg: (MessageData *) data {
    NSArray *listAnswer = reponse[@"messageList"];
    //NSLog(@"%@", reponse);
    NSNumber *answerCode = reponse[@"answerCode"];
    data.answerCode = answerCode.intValue;
    if (listAnswer && listAnswer.count > 0) {
        NSDictionary *msgDic = listAnswer[0];
        //
        NSString *intentType = msgDic[@"intent_type"];
        if ([intentType isEqualToString:@"DEFAULT"]) {
            //
            data.type = MessageTypeText;
            data.fromMe = NO;
            data.jsonResponse = reponse;
            data.msgId = msgDic[@"mid"];
            data.question = reponse[@"question"];
            //
            NSMutableArray *listOtherAnswer = [NSMutableArray new];
            if (listAnswer.count > 1) {
                for (int i = 0; i<listAnswer.count; i++) {
                    NSDictionary *dic = listAnswer[i];
                    NSString *url = dic[@"url"];
                    if (url && ![url isKindOfClass:[NSNull class]] && url.length > 0) {
                        [listOtherAnswer addObject:dic];
                    }
                }
            }
            else {
                NSString *urlString = msgDic[@"url"];
                if (urlString && ![urlString isKindOfClass:[NSNull class]] && urlString.length > 0) {
                    NSURL* url = [NSURL URLWithString:urlString];
                    NSString* domain = [url host];
                    data.linkSource = urlString;
                    data.source = [NSString stringWithFormat:@"Nguồn: %@", domain];
                }
            }
            if (listOtherAnswer.count > 0) {
                data.listOtherAnswer = listOtherAnswer;
            }
            [data selectAnswerAtIdx: (data.answerIdx == -1 ? 0 : data.answerIdx)];
        }
        else {
            data.type = MessageTypeWebView;
            data.fromMe = NO;
            data.jsonResponse = reponse;
            data.msgId = msgDic[@"mid"];
            data.htmlStr = msgDic[@"html"];
            data.question = reponse[@"question"];
//            if ([intentType isEqualToString:@"WEATHER"]) {
//                data.htmlRatio = 1.5;
//            }
        }
    }
}
- (void) sendExpert {
    if (!self.msgId) {
        return;
    }
    self.sendExpertState = 1;
    [[DatabaseControl instance] updateSendExpert:self];
    [((BaseChatCell *)self.weakCell) showSendExpertMessage];
    
    // ---------------------------------------------------------------------------
    
    if ([Manager instance].myUser.username.length == 0) {
        return;
    }
    NSString *firebaseToken = [FIRInstanceID instanceID].token;
    if (firebaseToken && firebaseToken.length > 0) {
        
        [Utils showLoadingHUDInView:[Manager instance].currentChatVC.view];
        
        NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                                 @"userId" : @([Manager instance].myUser.userId),
                                 @"token" : [Manager instance].myUser.token,
                                 @"firebaseToken" : firebaseToken,
                                 };
        [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_PUSH_FIRE_BASE_TOKEN params:params success:^(NSURLSessionDataTask *task, id responseObj) {
            if ([Manager instance].myUser.username.length == 0) {
                [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
                return;
            }
            //NSLog (@"response %@", responseObj);
            NSDictionary *reponse = responseObj;
            NSNumber *status = reponse[@"status"];
            if (status.intValue == 200) {
                [self sendRequestExpert];
            }
            else {
                
                [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
                [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Có lỗi xảy ra!"];
                
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
            [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Có lỗi xảy ra!"];
            
        }];
    }
    else {
        [Utils showLoadingHUDInView:[Manager instance].currentChatVC.view];
        [self sendRequestExpert];
    }
    // ---------------------------------------------------------------------------
}
- (void) sendRequestExpert {
    NSString *question = self.question;
    if (question && question.length > 0) {} else question = @"Error";
    NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                             @"userId" : @([Manager instance].myUser.userId),
                             @"token" : [Manager instance].myUser.token,
                             @"mid" : self.msgId,
                             @"message" : question
                             };
    [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_SEND_EXPERT params:params success:^(NSURLSessionDataTask *task, id responseObj) {
        [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
        NSDictionary *reponse = responseObj;
        //NSLog(@"%@", reponse);
        NSNumber *status = reponse[@"status"];
        if (status.intValue == 200) {
            [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Gửi cho chuyên gia thành công!"];
        }
        else {
            NSString *message = reponse[@"error"];
            if (message && message.length > 0) {} else {message = @"Có lỗi xảy ra!";}
            [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage: message];
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        [Utils hideLoadingHUDInView:[Manager instance].currentChatVC.view];
        [Utils showToastHUDInView:[Manager instance].currentChatVC.view withMessage:@"Có lỗi xảy ra!"];
        
    }];
}
- (void) selectAnswerAtIdx: (int) idx {
    self.answerIdx = idx;
    sizeMsg = CGSizeMake(-1, -1);
    NSArray *listAnswer = self.jsonResponse[@"messageList"];
    if (listAnswer && listAnswer.count > 0 && listAnswer.count > idx) {
        NSDictionary *msgDic = listAnswer[idx];
        NSString *text = msgDic[@"text"];
        self.textMsg = text;
        if ([text isKindOfClass:[NSNull class]]) {
            self.textMsg = @"Xin hỏi lại.";
        }
        //
        NSString *voice = msgDic[@"voice"];
        self.textVoice = voice;
        if ([voice isKindOfClass:[NSNull class]]) {
            self.textVoice = @"Xin hỏi lại.";
        }
    }
}
- (void) dealloc {
    if (timerSendMsg) {
        [timerSendMsg invalidate];
        timerSendMsg = nil;
    }
    if (timerGetAnswer) {
        [timerGetAnswer invalidate];
        timerGetAnswer = nil;
    }
}
@end
