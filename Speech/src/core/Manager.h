//
//  Manager.h
//  sources
//
//  Created by Phu on 1/25/17.
//
//

#import <Foundation/Foundation.h>
#import "../../library/gvuserdefaults/GVUserDefaults+Properties.h"
#import "ChatController.h"
#import "UserData.h"
#import "NotificationController.h"

@interface Manager : NSObject

@property (nonatomic, weak) ChatController *currentChatVC;
@property (nonatomic, strong) NotificationController *notificationVC;
@property (nonatomic, strong) UIColor *colorBubbleFromMe;
@property (nonatomic, strong) UIColor *colorBubbleFromBot;
@property (nonatomic, strong) UIColor *colorBubbleFromBotSelected;
@property (nonatomic, strong) NSArray *listColorBubble;
@property (nonatomic, strong) NSArray *listColorText;
@property (nonatomic, strong) UserData *myUser;
@property (nonatomic, strong) NSMutableDictionary *jsonAnswerIdNotifi;
@property (nonatomic, strong) NSMutableArray *listTappedNotifications;
@property (nonatomic, strong) NSTimer *timerSendFirebaseToken;
//
+ (Manager*)instance;
- (void) loadJsonAnswerIdNotifi;
- (void) saveAnswerIdToJsonData: (NSString *) answerId;
//
- (void) sendFirebaseToken;
- (void) stopTimerSendFirebaseToken;
//
@end
