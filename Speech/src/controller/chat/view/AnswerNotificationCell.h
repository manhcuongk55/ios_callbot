//
//  AnswerNotificationCell.h
//  Speech
//
//  Created by Phu on 5/22/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "BaseChatCell.h"

@interface AnswerNotificationCell : BaseChatCell
+ (NSDictionary *) titleStyle;
+ (NSDictionary *) questionStyle;
+ (NSDictionary *) answerStyle;
@end
