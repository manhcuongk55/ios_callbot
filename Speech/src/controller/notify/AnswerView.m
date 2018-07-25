//
//  InputAnswerView.m
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AnswerView.h"
#import "AnswerButton.h"
#import "Manager.h"
#import "Utils.h"

@interface AnswerView () {
    ASDisplayNode *bg;
    ASDisplayNode *content;
    float wiContent;
    float hiContent;
    ASScrollNode *scrollNode;
    ASTextNode *question;
    ASTextNode *answerSection;
    ASDisplayNode *inputBg;
    ASEditableTextNode *inputNode;
    AnswerButton *cancelBtn;
    float keyboardHi;
}
@property (nonatomic, strong) NSDictionary *data;
@end

@implementation AnswerView

- (instancetype)init
{
    self = [super init];
    if (self) {
        wiContent = 300;
        hiContent = 285;
        keyboardHi = 0;
        self.backgroundColor = [UIColor clearColor];
        
        bg = [ASDisplayNode new];
        [self addSubnode:bg];
        bg.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.85];
        
        content = [ASDisplayNode new];
        content.backgroundColor = [UIColor whiteColor];
        content.cornerRadius = 6.0f;
        [self addSubnode:content];
        
        inputBg = [ASDisplayNode new];
        inputBg.backgroundColor = [UIColor whiteColor];
        inputBg.borderColor = [UIColor lightGrayColor].CGColor;
        inputBg.borderWidth = 1.0f;
        [content addSubnode:inputBg];
        
        scrollNode = [ASScrollNode new];
        [content addSubnode:scrollNode];
        //
        question = [ASTextNode new];
        [scrollNode addSubnode:question];
        //
        answerSection = [ASTextNode new];
        answerSection.attributedText = [[NSAttributedString alloc] initWithString: @"Câu trả lời: " attributes:[self question1Style]];
        [content addSubnode:answerSection];
        //
        inputNode = [ASEditableTextNode new];
        inputNode.textView.editable = NO;
        inputNode.attributedPlaceholderText = [[NSAttributedString alloc] initWithString: @"Nhập câu trả lời..." attributes:[self textStyle]];
        inputNode.textView.font = [UIFont systemFontOfSize:16.0];
        //inputNode.delegate = self;
        [content addSubnode:inputNode];
        
        cancelBtn = [AnswerButton new];
        [cancelBtn setStyle:3];
        [content addSubnode:cancelBtn];
        
        [cancelBtn addTarget:self action:@selector(handleCancel) forControlEvents:ASControlNodeEventTouchUpInside];
    }
    return self;
}
- (void) updateWithData:(NSDictionary *)data {
    self.data = [[NSDictionary alloc] initWithDictionary:data];
    NSString *quesStr = [NSString stringWithFormat:@"Câu hỏi: %@", data[@"question"]];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString: quesStr];
    [attrStr addAttributes:[self question1Style] range:NSMakeRange(0, 8)];
    [attrStr addAttributes:[self questionStyle] range:NSMakeRange(8, quesStr.length - 8)];
    question.attributedText = attrStr;
    [inputNode setAttributedText:[[NSAttributedString alloc] initWithString: data[@"answer"] attributes:[self textStyle]]];
    
    [self calculateFrame];
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor lightGrayColor],
             };
}
- (NSDictionary *) question1Style {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [Manager instance].colorBubbleFromBot,
             };
}
- (NSDictionary *) questionStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor darkGrayColor],
             };
}
- (void) setShow: (BOOL) animated {
    self.alpha = 0.0;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        //[inputNode becomeFirstResponder];
    }];
}

- (void) layout {
    [super layout];
    [self calculateFrame];
}
- (void) calculateFrame {
    bg.frame = self.bounds;
    
    CGSize size = [question calculateSizeThatFits:CGSizeMake(wiContent - 30, MAXFLOAT)];
    float hiScroll = size.height > 205 ? 205 : size.height;
    scrollNode.frame = CGRectMake(0, 15, wiContent, hiScroll);
    question.frame = CGRectMake(15, 0, size.width, size.height);
    scrollNode.view.contentSize = CGSizeMake(size.width, size.height);
    
    float yT;
    
    size = [answerSection calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
    yT = scrollNode.frame.origin.y + scrollNode.frame.size.height + 15;
    answerSection.frame = CGRectMake(15, yT, size.width, size.height);
    
    yT = answerSection.frame.origin.y + answerSection.frame.size.height + 15;
    inputBg.frame = CGRectMake(15, yT, wiContent - 30, 250);
    
    yT = inputBg.frame.origin.y + 10;
    float xT = inputBg.frame.origin.x + 10;
    inputNode.frame = CGRectMake(xT, yT, wiContent - 30 - 20, 250 - 20);
    
    xT = wiContent - 15 - 120;
    yT = inputBg.frame.origin.y + inputBg.frame.size.height + 15;
    cancelBtn.frame = CGRectMake(xT, yT, 120, 35);
    
    hiContent = cancelBtn.frame.origin.y + cancelBtn.frame.size.height + 15;
    
    content.frame = CGRectMake((self.bounds.size.width - wiContent)/2.0, (self.bounds.size.height - hiContent)/2.0, wiContent, hiContent);
    yT = self.bounds.size.height - hiContent - keyboardHi - 10;
    if (yT < content.frame.origin.y) {
        CGRect rect = content.frame;
        rect.origin.y = yT;
        content.frame = rect;
    }
    
    //NSLog(@"%f", cancelBtn.frame.origin.y + cancelBtn.frame.size.height + 15);
}
- (void) close {
    [self handleCancel];
}
- (void) handleCancel {
    [inputNode resignFirstResponder];
    self.alpha = 1.0;
    [UIView animateWithDuration:0.25 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [self removeFromSupernode];
        [[Manager instance].notificationVC setNeedsStatusBarAppearanceUpdate];
    }];
}
- (void) handleSend {
    NSString *answer = [inputNode.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (answer && answer.length == 0) {
        [Utils showToastHUDInView:[Manager instance].notificationVC.view withMessage:@"Bạn chưa nhập câu trả lời!"];
        return;
    }
    [[Manager instance].notificationVC sendAnswer:self.data answer: answer];
}
- (void) updateKeyboardHeight: (float) keyboardHi_ {
    keyboardHi = keyboardHi_;
    [self calculateFrame];
}
@end
