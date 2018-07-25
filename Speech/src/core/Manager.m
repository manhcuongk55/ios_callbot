//
//  Manager.m
//  sources
//
//  Created by Phu on 1/25/17.
//
//

#import "Manager.h"
#import "HTTPNetworkControl.h"

@import Firebase;

//
@interface Manager () {
    int countRetrySendFirebaseMessage;
}
@end

@implementation Manager

static Manager *inst = nil;

+ (Manager*)instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.colorBubbleFromMe = [UIColor colorWithRed:217.0/255.0 green:237.0/255.0 blue:251.0/255.0 alpha:1.0];
        self.colorBubbleFromBot = [UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:234.0/255.0 alpha:1.0];
        self.colorBubbleFromBotSelected = [UIColor colorWithRed:42.0/255.0 green:138.0/255.0 blue:193.0/255.0 alpha:1.0];
        
        self.listColorBubble = @[[UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:234.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:181.0/255.0 green:176.0/255.0 blue:247.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:18.0/255.0 green:215.0/255.0 blue:229.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:187.0/255.0 blue:148.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:252.0/255.0 green:163.0/255.0 blue:163.0/255.0 alpha:1.0]];
        self.listColorText = @[[UIColor whiteColor],
                               [UIColor whiteColor],
                               [UIColor whiteColor],
                               [UIColor whiteColor],
                               [UIColor whiteColor]
                               ];
        self.listTappedNotifications = [[NSMutableArray alloc] init];
        countRetrySendFirebaseMessage = 0;
    }
    return self;
}
- (void) loadJsonAnswerIdNotifi {
    NSString *savedStr = [GVUserDefaults standardUserDefaults].jsonAnswerIdNotifi;
    NSDictionary *dic = [Utils convertStringToJsonObject: savedStr];
    [Manager instance].jsonAnswerIdNotifi = [[NSMutableDictionary alloc] initWithDictionary: dic];
}
- (void) saveAnswerIdToJsonData:(NSString *)answerId {
    [Manager instance].jsonAnswerIdNotifi[answerId] = @"";
    [GVUserDefaults standardUserDefaults].jsonAnswerIdNotifi = [Utils convertJsonObjectToString:[Manager instance].jsonAnswerIdNotifi];
}
- (void) sendFirebaseToken {
    if ([Manager instance].myUser.username.length == 0) {
        return;
    }
    if ([GVUserDefaults standardUserDefaults].sendTokenFirebaseSuccess.length > 0) {
        return;
    }
    NSString *firebaseToken = [FIRInstanceID instanceID].token;
    if (firebaseToken && firebaseToken.length > 0) {
        NSDictionary *params = @{@"username" : [Manager instance].myUser.username,
                                 @"userId" : @([Manager instance].myUser.userId),
                                 @"token" : [Manager instance].myUser.token,
                                 @"firebaseToken" : firebaseToken,
                                };
        [[HTTPNetworkControl instance] requestPOST:[HTTPNetworkControl instance].URL_PUSH_FIRE_BASE_TOKEN params:params success:^(NSURLSessionDataTask *task, id responseObj) {
            if ([Manager instance].myUser.username.length == 0) {
                return;
            }
            //NSLog (@"response %@", responseObj);
            NSDictionary *reponse = responseObj;
            NSNumber *status = reponse[@"status"];
            if (status.intValue == 200) {
                [GVUserDefaults standardUserDefaults].sendTokenFirebaseSuccess = @"1";
            }
            else {
                [self waitAndRetrySendFirebaseToken];
            }
        } failure:^(NSURLSessionDataTask *task, NSError *error) {
            
            //NSLog (@"response %@", error);
            if ([Manager instance].myUser.username.length == 0) {
                return;
            }
            [self waitAndRetrySendFirebaseToken];
        }];
    }
    else {
        [self waitAndRetrySendFirebaseToken];
    }
}
- (void) waitAndRetrySendFirebaseToken {
    if (self.timerSendFirebaseToken) {
        [self.timerSendFirebaseToken invalidate];
        self.timerSendFirebaseToken = nil;
    }
    countRetrySendFirebaseMessage ++;
    if (countRetrySendFirebaseMessage <= 10) {
        self.timerSendFirebaseToken = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(sendFirebaseToken) userInfo:nil repeats:NO];
    }
}
- (void) stopTimerSendFirebaseToken {
    if (self.timerSendFirebaseToken) {
        [self.timerSendFirebaseToken invalidate];
        self.timerSendFirebaseToken = nil;
    }
    countRetrySendFirebaseMessage = 0;
}
@end
