//
//  AnswerNotificationCell.m
//  Speech
//
//  Created by Phu on 5/22/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AnswerNotificationCell.h"

@interface AnswerNotificationCell () {
    ASDisplayNode *content;
    
    ASDisplayNode *headerBg;
    
    ASTextNode *titleNode;
    ASTextNode *questionNode;
    
    ASTextNode *answerNode;
}

@end

@implementation AnswerNotificationCell

- (instancetype)initWithData:(MessageData *)data
{
    self = [super initWithData:data];
    if (self) {
        content = [ASDisplayNode new];
        content.backgroundColor = [UIColor whiteColor];
        [self addSubnode:content];
        
        headerBg = [ASDisplayNode new];
        headerBg.backgroundColor = [UIColor colorWithRed:112.0/255.0 green:199.0/255.0 blue:255.0/255.0 alpha:1.0];
        [content addSubnode:headerBg];
        
        titleNode = [ASTextNode new];
        titleNode.attributedText = [[NSAttributedString alloc] initWithString: @"Câu trả lời từ chuyên gia:" attributes:[AnswerNotificationCell titleStyle]];
        [content addSubnode:titleNode];
        
        questionNode = [ASTextNode new];
        questionNode.attributedText = [[NSAttributedString alloc] initWithString:self.weakData.jsonNotification[@"question"] attributes:[AnswerNotificationCell questionStyle]];
        [content addSubnode:questionNode];
        
        answerNode = [ASTextNode new];
        answerNode.attributedText = [[NSAttributedString alloc] initWithString:self.weakData.jsonNotification[@"answer"] attributes:[AnswerNotificationCell answerStyle]];
        [content addSubnode:answerNode];
        
        content.borderWidth = 1.0;
        content.borderColor = [UIColor colorWithRed:112.0/255.0 green:199.0/255.0 blue:255.0/255.0 alpha:1.0].CGColor;
        content.layer.masksToBounds = NO;
        content.layer.shadowColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0].CGColor;
        content.layer.shadowOpacity = 0.25;
        content.layer.shadowOffset = CGSizeMake(2.0, 3.0f);
        content.layer.shadowRadius = 2.5;
        
        [self addAvatarImg];
        [self addPlusBtn];
        [self checkShowRateMessage];
    }
    return self;
}
- (void) calculateFrame {
    [super calculateFrame];
    self.avatarImg.frame = CGRectMake(10, 12, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
    content.frame = CGRectMake(10 + self.weakData.avatarRect.size.width + 10, 10, self.weakData.bubbleRect.size.width, self.weakData.bubbleRect.size.height);
    float yT = 7;
    titleNode.frame = CGRectMake(15, yT, self.weakData.answerCellTitleRect.size.width, self.weakData.answerCellTitleRect.size.height);
    yT += self.weakData.answerCellTitleRect.size.height + 5;
    questionNode.frame = CGRectMake(15, yT, self.weakData.answerCellQuestionRect.size.width, self.weakData.answerCellQuestionRect.size.height);
    yT += self.weakData.answerCellQuestionRect.size.height + 7;
    headerBg.frame = CGRectMake(0, 0, content.frame.size.width, yT);
    yT += 10;
    answerNode.frame = CGRectMake(15, yT, self.weakData.answerCellAnswerRect.size.width, self.weakData.answerCellAnswerRect.size.height);
    
    float xT = content.frame.origin.x + content.frame.size.width - 10 - 20;
    if (self.plusBtn) {
        CGRect rect = content.frame;
        rect.origin.x = xT + 10 - 22;
        rect.origin.y = content.frame.origin.y + content.frame.size.height - 22;
        rect.size.width = 44;
        rect.size.height = 44;
        self.plusBtn.frame = rect;
        xT -= 10 + 20;
    }
    if (self.rateMessageImg) {
        CGRect rect = content.frame;
        rect.origin.x = xT;
        rect.origin.y = content.frame.origin.y + content.frame.size.height - 10;
        rect.size.width = 20;
        rect.size.height = 20;
        self.rateMessageImg.frame = rect;
    }
}
+ (NSDictionary *) titleStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:16.0];
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
+ (NSDictionary *) questionStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
+ (NSDictionary *) answerStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor colorWithRed:79.0/255.0 green:79.0/255.0 blue:79.0/255.0 alpha:1.0],
             };
}
- (CGRect) getBubbleRect {
    return content.frame;
}
@end
