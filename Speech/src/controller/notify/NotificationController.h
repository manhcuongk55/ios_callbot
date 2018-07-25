//
//  NotificationControllerViewController.h
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "BaseViewController.h"

@interface NotificationController : BaseViewController

@property (nonatomic, assign) BOOL isShow;
- (void) sendAnswer: (NSDictionary *) question answer: (NSString *) answer;
- (void) cleanData;
- (void) refreshData;
@end
