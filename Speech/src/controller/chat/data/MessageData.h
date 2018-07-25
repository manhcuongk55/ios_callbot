//
//  MessageData.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AsyncDisplayKit.h"

typedef enum {
    MessageTypeText = 1,
    MessageTypeTyping = 2,
    MessageTypeAnswerNotification = 3,
    MessageTypePhoto = 4,
    MessageTypeWeather = 5,
    MessageTypeMusic = 6,
    MessageTypeWebView = 7,
} MessageType;

@interface MessageData : NSObject

@property (nonatomic, assign) MessageType type;
@property (nonatomic, strong) NSString *textMsg;
@property (nonatomic, strong) NSString *textVoice;
@property (nonatomic, assign) BOOL fromMe;
@property (nonatomic, assign) long long localId;
@property (nonatomic, assign) long long timestamp;
@property (nonatomic, strong) NSString *msgId;
@property (nonatomic, strong) NSArray *listOtherAnswer;
@property (nonatomic, strong) NSDictionary *jsonResponse;
@property (nonatomic, strong) NSDictionary *jsonNotification;
@property (nonatomic, strong) NSString *question;
@property (nonatomic, strong) NSString *source;
@property (nonatomic, strong) NSString *linkSource;
@property (nonatomic, strong) NSString *htmlStr;
@property (nonatomic, assign) float htmlRatio;
@property (nonatomic, weak) id weakCell;
@property (nonatomic, assign) int answerCode;
@property (nonatomic, assign) int answerIdx;
@property (nonatomic, assign) int rateMessage;
@property (nonatomic, assign) int sendExpertState;
@property (nonatomic, assign) CGRect avatarRect;

// Text cell
@property (nonatomic, assign) CGRect bubbleRect;
@property (nonatomic, assign) CGRect textRect;
@property (nonatomic, assign) CGRect sourceRect;
// Answer cell
@property (nonatomic, assign) CGRect answerCellTitleRect;
@property (nonatomic, assign) CGRect answerCellQuestionRect;
@property (nonatomic, assign) CGRect answerCellAnswerRect;
// WebView Cell
@property (nonatomic, assign) CGRect webViewRect;

- (float) getHeight;
- (float) getWidth;
- (void) calculateSize: (float) wiCell;
- (void) sendMessage;
- (void) rateMessage: (BOOL) isLike;
+ (void) readDataAnswerV1:(NSDictionary *)reponse forMsg: (MessageData *) data;
- (BOOL) canSendExpert;
- (void) sendExpert;
- (void) selectAnswerAtIdx: (int) idx;
@end
