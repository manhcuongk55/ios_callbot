//
//  ChatBox.m
//  Speech
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "ChatBox.h"
#import "Utils.h"
#import "SpeechControl.h"
#import "BSLoadingView.h"
#import "Speech-Swift.h"
#import "Manager.h"

@interface ChatBox () <SpeechControlDelegate, ASEditableTextNodeDelegate> {
    ASDisplayNode *topDivi;
    ASButtonNode *micBtn;
    ASButtonNode *sendBtn;
    ASEditableTextNode *inputNode;
    ASButtonNode *fakeInputBtn;
    ASButtonNode *editModeBtn;
    SpeechControl *speechControl;
    NVActivityIndicatorView *recordingView;
    ASTextNode *transcript;
    int type;
}

@end

@implementation ChatBox

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        self.hiContent = 60;
        
        topDivi = [ASDisplayNode new];
        topDivi.backgroundColor = [UIColor lightGrayColor];
        [self addSubnode:topDivi];

        sendBtn = [ASButtonNode new];
        [sendBtn setImage:[Utils image:[UIImage imageNamed:@"send_chat_box"] size:CGSizeMake(25, 25)] forState:ASControlStateNormal];
        [self addSubnode:sendBtn];
        [sendBtn addTarget:self action:@selector(sendBtnClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        micBtn = [ASButtonNode new];
        [micBtn setImage:[Utils image:[UIImage imageNamed:@"mic_chat_box_with_bound"] size:CGSizeMake(40, 40)] forState:ASControlStateNormal];
        [self addSubnode:micBtn];
        [micBtn addTarget:self action:@selector(micBtnClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        
        fakeInputBtn = [ASButtonNode new];
        [self addSubnode:fakeInputBtn];
        [fakeInputBtn addTarget:self action:@selector(clickedFakeInputBtn) forControlEvents:ASControlNodeEventTouchUpInside];
        fakeInputBtn.borderColor = [UIColor colorWithRed:190.0/255.0 green:190.0/255.0 blue:190.0/255.0 alpha:1.0].CGColor;
        fakeInputBtn.borderWidth = 1.0f;
        fakeInputBtn.cornerRadius = 19.0f;
        
        inputNode = [ASEditableTextNode new];
        inputNode.attributedPlaceholderText = [[NSAttributedString alloc] initWithString: @"Nhập câu hỏi..." attributes:[self textStyle]];
        inputNode.textView.font = [UIFont systemFontOfSize:16.0];
        inputNode.delegate = self;
        [self addSubnode:inputNode];
        
        editModeBtn = [ASButtonNode new];
        [editModeBtn setImage:[Utils image:[UIImage imageNamed:@"edit_chat_box"] size:CGSizeMake(25, 25)] forState:ASControlStateNormal];
        [editModeBtn addTarget:self action:@selector(editModeBtnClicked) forControlEvents:ASControlNodeEventTouchUpInside];
        [self addSubnode:editModeBtn];
        
        transcript = [ASTextNode new];
        [self addSubnode:transcript];
        
        speechControl = [SpeechControl new];
        speechControl.delegate = self;
        
        [self setType: 1];
    }
    return self;
}
- (void) setType: (int) type_ {
    type = type_;
    if (recordingView) {
        [recordingView removeFromSuperview];
    }
    if (type == 1) { // For Voice
        sendBtn.hidden = YES;
        micBtn.hidden = NO;
        fakeInputBtn.hidden = YES;
        inputNode.hidden = YES;
        editModeBtn.hidden = NO;
        topDivi.hidden = NO;
        [micBtn setImage:[Utils image:[UIImage imageNamed:@"mic_chat_box_with_bound"] size:CGSizeMake(40, 40)] forState:ASControlStateNormal];
        self.hiContent = 60;
    }
    else { // For Text
        sendBtn.hidden = NO;
        micBtn.hidden = NO;
        fakeInputBtn.hidden = NO;
        inputNode.hidden = NO;
        editModeBtn.hidden = YES;
        topDivi.hidden = YES;
        [micBtn setImage:[Utils image:[UIImage imageNamed:@"mic_chat_box"] size:CGSizeMake(25, 25)] forState:ASControlStateNormal];
        self.hiContent = 50;
    }
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor lightGrayColor],
             };
}
- (void) sendBtnClicked {
    if (inputNode.textView.text.length > 0) {
        [self.delegate didSendTextMsg:inputNode.textView.text];
        [inputNode setAttributedText:[[NSAttributedString alloc] initWithString: @"" attributes:[self textStyle]]];
        self.hiContent = 50;
        [self.delegate updateFrameChatBox];
    }
}
- (void) micBtnClicked {
    [inputNode resignFirstResponder];
    [self setType:1];
    [inputNode setAttributedText:[[NSAttributedString alloc] initWithString: @"" attributes:[self textStyle]]];
    //micBtn.hidden = YES;
    
    if (recordingView) {
        [recordingView removeFromSuperview];
    }
    CGRect rect = self.bounds;
    rect.size.height = 10;
    rect.size.width = 65;
    rect.origin.y = (self.bounds.size.height - rect.size.height)/2.0;
    rect.origin.x = (self.bounds.size.width - rect.size.width)/2.0;
    if (!recordingView) {
        recordingView = [NVActivityIndicatorView createIndicatorView];
        recordingView.type = NVActivityIndicatorTypeBallScaleMultiple; //NVActivityIndicatorTypeLineScalePulseOut;
        recordingView.color = [UIColor colorWithRed:52.0/255.0 green:168.0/255.0 blue:234.0/255.0 alpha:1.0];
        recordingView.padding = 0.0;
        recordingView.frame = CGRectMake(0, 0, 75, 75);//CGRectMake(0, 0, 30, 30);
        [recordingView startAnimating];
    }
    //[self.view addSubview:recordingView];
    [self.view insertSubview:recordingView belowSubview:micBtn.view];
    
    [self.delegate updateFrameChatBox];
    [self calculateFrame];
    
    [speechControl recordAudio];
}
- (void) layout {
    [super layout];
    [self calculateFrame];
}
- (void) calculateFrame {
    
    CGRect rect = self.bounds;
    rect.size.height = 0.5;
    topDivi.frame = rect;
    
    if (type == 1) { // For voice
        rect = self.bounds;
        rect.origin.x = [Utils instance].edgeInsets.left + 5;
        rect.size.width = 44;
        rect.origin.y = (self.hiContent - 50)/2.0;
        rect.size.height = 50;
        editModeBtn.frame = rect;
        
        rect.origin.y = (self.hiContent - 60)/2.0;
        rect.origin.x = (self.bounds.size.width - 60) / 2.0;
        rect.size.width = 60;
        rect.size.height = 60;
        micBtn.frame = rect;
        
        if (recordingView && recordingView.superview == self.view) {
            rect = self.bounds;
            rect.size.height = recordingView.frame.size.height;
            rect.size.width = recordingView.frame.size.width;
            rect.origin.y = (self.bounds.size.height - rect.size.height)/2.0;
            rect.origin.x = (self.bounds.size.width - rect.size.width)/2.0;
            recordingView.frame = rect;
        }
    }
    else if (type == 2) { // For text
        
        rect.origin.y = (self.hiContent - 50)/2.0;
        rect.origin.x = self.bounds.size.width - [Utils instance].edgeInsets.right - 44;
        rect.size.width = 44;
        rect.size.height = 50;
        sendBtn.frame = rect;
        
        rect.origin.y = (self.hiContent - 50)/2.0;
        rect.origin.x = [Utils instance].edgeInsets.left;
        rect.size.width = 44;
        rect.size.height = 50;
        micBtn.frame = rect;
        
        rect = self.bounds;
        rect.origin.x = [Utils instance].edgeInsets.left + 44;
        rect.size.width = sendBtn.frame.origin.x - rect.origin.x;
        rect.origin.y = 5;
        rect.size.height -= 10;
        fakeInputBtn.frame = rect;
        
        rect = fakeInputBtn.frame;
        rect.origin.x += 15;
        rect.size.width -= 30;
        CGSize size = [inputNode calculateSizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
        rect.origin.y = (self.bounds.size.height - size.height)/2.0;
        rect.size.height = size.height;
        inputNode.frame = rect;
        
    }
}
// SpeechControlDelegate
- (void) receiveTextFromSpeech: (NSString *)text {
    transcript.hidden = YES;
    if (text && text.length > 0) {
        [self.delegate didSendTextMsg:text];
    }
    [self stopRecording];
}
- (void) stopRecording {
    if (recordingView) {
        [recordingView removeFromSuperview];
    }
    [self setType: type];
}
// EditTextNodeDelegate
- (void)editableTextNodeDidBeginEditing:(ASEditableTextNode *)editableTextNode {
}
- (BOOL)editableTextNode:(ASEditableTextNode *)editableTextNode shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [editableTextNode resignFirstResponder];
        return NO;
    }
    return YES;
}
- (void)editableTextNodeDidChangeSelection:(ASEditableTextNode *)editableTextNode fromSelectedRange:(NSRange)fromSelectedRange toSelectedRange:(NSRange)toSelectedRange dueToEditing:(BOOL)dueToEditing {
}
- (void)editableTextNodeDidUpdateText:(ASEditableTextNode *)editableTextNode {
    CGRect rect = inputNode.frame;
    CGSize size = [inputNode calculateSizeThatFits:CGSizeMake(rect.size.width, MAXFLOAT)];
    self.hiContent = size.height + 15 + 15;
    [self.delegate updateFrameChatBox];
}
- (void)editableTextNodeDidFinishEditing:(ASEditableTextNode *)editableTextNode {
}
// Clicked handle
- (void) clickedFakeInputBtn {
    if (![inputNode isFirstResponder]) {
        [inputNode becomeFirstResponder];
    }
}
- (void) editModeBtnClicked {
    if (recordingView && recordingView.superview == self.view) {
        [speechControl stopAudio];
    }
    [self setType:2];
    [self.delegate updateFrameChatBox];
    [self calculateFrame];
    if (![inputNode isFirstResponder]) {
        [inputNode becomeFirstResponder];
    }
}
- (NSDictionary *)transcriptStyle {
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue" size:16];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [Manager instance].colorBubbleFromBot,
             };
}
- (void) updateTranscript: (NSString *) transcriptStr {
    transcript.hidden = NO;
    transcript.attributedText = [[NSAttributedString alloc] initWithString: transcriptStr attributes:[self transcriptStyle]];
    CGSize size = [transcript calculateSizeThatFits:CGSizeMake(self.bounds.size.width - 30, MAXFLOAT)];
    transcript.frame = CGRectMake((self.bounds.size.width - size.width)/2.0, - 10 - size.height, size.width, size.height);
}
- (void) resignChatBox {
    [inputNode resignFirstResponder];
}
@end
