//
//  TextMessageCell.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "TextMessageCell.h"
#import "Manager.h"
#import "OtherSourceView.h"
#import <SafariServices/SafariServices.h>
#import "NSAttributedString+DDHTML.h"
@interface TextMessageCell () <OtherSourceViewDelegate> {
    ASDisplayNode *bubbleNode;
    ASDisplayNode *bubbleCornerNode;
    ASTextNode *textNode;
    ASTextNode *sourceNode;
    OtherSourceView *otherSource;
}

@end

@implementation TextMessageCell

- (instancetype)initWithData: (MessageData *) data
{
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        bubbleNode = [ASDisplayNode new];
        UIColor *colorBubble;
        if (data.fromMe) {
            colorBubble = [Manager instance].colorBubbleFromMe;
        }
        else {
            if (self.weakData.listOtherAnswer.count > 0) {
                colorBubble = [Manager instance].listColorBubble[self.weakData.answerIdx % 5];
            }
            else {
                colorBubble = [Manager instance].colorBubbleFromBot;
            }
        }
        bubbleNode.backgroundColor = colorBubble;
        bubbleNode.cornerRadius = 7.0f;
        [self addSubnode:bubbleNode];
        //
        bubbleCornerNode = [ASDisplayNode new];
        bubbleCornerNode.backgroundColor = colorBubble;
        [bubbleNode addSubnode:bubbleCornerNode];
        //
        textNode = [ASTextNode new];
        textNode.attributedText = [NSAttributedString attributedStringFromHTMLForVBrowser: self.weakData.textMsg defaultTextColor:[self textColor]];
        [self addSubnode:textNode];
        //
        if (data.source && data.source.length > 0) {
            sourceNode = [ASTextNode new];
            sourceNode.attributedText = [[NSAttributedString alloc] initWithString: data.source attributes:[TextMessageCell sourceStyle]];
            [self addSubnode:sourceNode];
        }
        //
        if (self.weakData.listOtherAnswer.count > 0) {
            otherSource = [[OtherSourceView alloc] initWithData:self.weakData.listOtherAnswer andSelectIdx:self.weakData.answerIdx];
            otherSource.delegate = self;
            [self addSubnode:otherSource];
        }
        //
        [self addAvatarImg];
        [self checkShowRateMessage];
        [self checkShowSendExpertMessage];
        if (!self.weakData.fromMe && self.weakData.type != 2 && self.weakData.jsonResponse && self.weakData.answerCode != 1) {
            [self addPlusBtn];
            if ([self getUrl]) {
                [self addOpenLinkBtn];
                [self.openLinkBtn addTarget:self action:@selector(tapBubble) forControlEvents:ASControlNodeEventTouchUpInside];
            }
        }
    }
    return self;
}
- (UIColor *) textColor {
    UIColor *color = self.weakData.fromMe ? [UIColor blackColor] : [UIColor whiteColor];
    if (self.weakData.listOtherAnswer.count > 0) {
        color = [Manager instance].listColorText[self.weakData.answerIdx % 5];
    }
    return color;
}
- (NSDictionary *)textStyle {
    UIFont *font = [UIFont systemFontOfSize:16.0];
    UIColor *color = self.weakData.fromMe ? [UIColor blackColor] : [UIColor whiteColor];
    if (self.weakData.listOtherAnswer.count > 0) {
        color = [Manager instance].listColorText[self.weakData.answerIdx % 5];
    }
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: color,
             };
}
+ (NSDictionary *) sourceStyle {
    UIFont *font = [UIFont italicSystemFontOfSize:13.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor whiteColor],
             };
}
- (void) calculateFrame {
    [super calculateFrame];
    float xT, yT;
    if (self.weakData.fromMe) {
        xT = self.bounds.size.width - [self.weakData getWidth] - 10;
        yT = 10;
        bubbleNode.frame = CGRectMake(xT, yT, self.weakData.bubbleRect.size.width, self.weakData.bubbleRect.size.height);
        bubbleCornerNode.frame = CGRectMake(bubbleNode.frame.size.width - 7, bubbleNode.frame.size.height - 7, 7, 7);
        xT = bubbleNode.frame.origin.x + 15;
        yT = bubbleNode.frame.origin.y + 10;
        textNode.frame = CGRectMake(xT, yT, self.weakData.textRect.size.width, self.weakData.textRect.size.height);
        xT = bubbleNode.frame.origin.x + bubbleNode.frame.size.width + 10;
        yT = bubbleNode.frame.origin.y;
        self.avatarImg.frame = CGRectMake(xT, yT + 2, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
    }
    else {
        xT = 10;
        yT = 10;
        self.avatarImg.frame = CGRectMake(xT, yT + 2, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
        
        xT = self.avatarImg.frame.origin.x + self.avatarImg.frame.size.width + 10;
        yT = 10;
        bubbleNode.frame = CGRectMake(xT, yT, self.weakData.bubbleRect.size.width, self.weakData.bubbleRect.size.height);
        bubbleCornerNode.frame = CGRectMake(0, 0, 7, 7);
        
        xT = bubbleNode.frame.origin.x + 15;
        yT = bubbleNode.frame.origin.y + 10;
        textNode.frame = CGRectMake(xT, yT, self.weakData.textRect.size.width, self.weakData.textRect.size.height);
        
        if (sourceNode) {
            xT = bubbleNode.frame.origin.x + bubbleNode.frame.size.width - 15 - self.weakData.sourceRect.size.width;
            yT = bubbleNode.frame.origin.y + bubbleNode.frame.size.height - 15 - self.weakData.sourceRect.size.height;
            sourceNode.frame = CGRectMake(xT, yT, self.weakData.sourceRect.size.width, self.weakData.sourceRect.size.height);
        }
        
        float yExpertBtn = bubbleNode.frame.origin.y + bubbleNode.frame.size.height + 10;
        if (self.weakData.listOtherAnswer.count > 0) {
            xT = 15;
            yT = bubbleNode.frame.origin.y + bubbleNode.frame.size.height + 15;
            
            otherSource.frame = CGRectMake(xT, yT, self.bounds.size.width - xT, 35);
            yExpertBtn = otherSource.frame.origin.y + otherSource.frame.size.height + 10;
        }
        xT = bubbleNode.frame.origin.x + bubbleNode.frame.size.width - 10 - 20;
        if (self.plusBtn) {
            CGRect rect = bubbleNode.frame;
            rect.origin.x = xT + 10 - 22;
            rect.origin.y = bubbleNode.frame.origin.y + bubbleNode.frame.size.height - 22;
            rect.size.width = 44;
            rect.size.height = 44;
            self.plusBtn.frame = rect;
            xT -= 10 + 20;
        }
        if (self.sendExpertImg) {
            CGRect rect = bubbleNode.frame;
            rect.origin.x = xT;
            rect.origin.y = bubbleNode.frame.origin.y + bubbleNode.frame.size.height - 10;
            rect.size.width = 20;
            rect.size.height = 20;
            self.sendExpertImg.frame = rect;
            xT -= 10 + 20;
        }
        
        if (self.rateMessageImg) {
            CGRect rect = bubbleNode.frame;
            rect.origin.x = xT;
            rect.origin.y = bubbleNode.frame.origin.y + bubbleNode.frame.size.height - 10;
            rect.size.width = 20;
            rect.size.height = 20;
            self.rateMessageImg.frame = rect;
        }
        if (self.openLinkBtn) {
            CGRect rect = self.openLinkBtn.frame;
            rect.origin.x = bubbleNode.frame.origin.x + bubbleNode.frame.size.width;
            rect.size.width = 30;
            rect.size.height = 30;
            rect.origin.y = bubbleNode.frame.origin.y + (bubbleNode.frame.size.height - rect.size.height)/2.0;
            self.openLinkBtn.frame = rect;
        }
//        if ([self.weakData canSendExpert]) {
//            xT = bubbleNode.frame.origin.x;
//            yT = yExpertBtn;
//            
//            self.sendExpertBtn.frame = CGRectMake(xT, yT, 150, 31);
//        }
    }
}
- (CGRect) getBubbleRect {
    return bubbleNode.frame;
}
- (void) setSelectBubble: (BOOL) selected {
    if (selected) {
        bubbleCornerNode.backgroundColor = [Manager instance].colorBubbleFromBotSelected;
        bubbleNode.backgroundColor = [Manager instance].colorBubbleFromBotSelected;
    }
    else {
        bubbleCornerNode.backgroundColor = [Manager instance].colorBubbleFromBot;
        bubbleNode.backgroundColor = [Manager instance].colorBubbleFromBot;
    }
}
- (void) sendExpertHandle {
    [self.weakData sendExpert];
}
// OtherSourceViewDelegate

- (void) didSelectSourceAtIdx:(int)idx {
    if (idx != self.weakData.answerIdx) {
        [self.weakData selectAnswerAtIdx:idx];
        [[Manager instance].currentChatVC.listNode.tableView reloadRowsAtIndexPaths:@[self.indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}
// Tap Bubble
- (void) tapBubble {
    NSString *url = [self getUrl];
    if (url) {
        SFSafariViewController *controller = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [[Manager instance].currentChatVC presentViewController:controller animated:YES completion:nil];
    }
    else {
        [[Manager instance].currentChatVC.chatBox resignChatBox];
    }
}
- (NSString *) getUrl {
    if (self.weakData.linkSource.length > 0) {
        return self.weakData.linkSource;
    }
    NSString *url;
    if (self.weakData.listOtherAnswer.count > 1) {
        NSDictionary *dic = self.weakData.listOtherAnswer[self.weakData.answerIdx];
        url = dic[@"url"];
    }
    if (url && ![url isKindOfClass:[NSNull class]] && url.length > 0) {
        return url;
    }
    return nil;
}
@end
