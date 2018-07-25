//
//  OptionMenuChatCell.m
//  Speech
//
//  Created by Phu on 5/14/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "OptionMenuChatCell.h"
#import "Manager.h"
#import "HTTPNetworkControl.h"
#import "BaseChatCell.h"
// ================================================================
@interface OptionMenuButton () {
    ASImageNode *img;
    ASTextNode *title;
    CGSize sizeText;
    float xBegin;
}

@end
@implementation OptionMenuButton

- (instancetype)initWithTitle: (NSString *) titleStr withImg: (NSString *) imgStr
{
    self = [super init];
    if (self) {
        //
        xBegin = 0;
        self.backgroundColor = [UIColor clearColor];
        //
        img = [ASImageNode new];
        img.image = [UIImage imageNamed: imgStr];
        [self addSubnode:img];
        //
        title = [ASTextNode new];
        title.attributedText = [[NSAttributedString alloc] initWithString: titleStr attributes:[self titleStyle]];
        [self addSubnode:title];
        //
        sizeText = [title calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        self.sizeContent = CGSizeMake(sizeText.width + 10 + 20, sizeText.height);
    }
    return self;
}
- (void) addShadow {
    self.backgroundColor = [UIColor whiteColor];
    self.borderColor = [[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] colorWithAlphaComponent:0.35].CGColor;
    self.borderWidth = 0.5f;
    self.cornerRadius = 15.0;
    self.layer.masksToBounds = NO;
    self.layer.shadowColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0].CGColor;
    self.layer.shadowOpacity = 0.8;
    self.layer.shadowOffset = CGSizeMake(1.0, 2.0f);
    self.layer.shadowRadius = 2;
    xBegin = 15;
}
- (NSDictionary *)titleStyle {
    UIFont *font = [UIFont systemFontOfSize:13.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: [UIColor blackColor],
             };
}
- (void) layout {
    [super layout];
    img.frame = CGRectMake(xBegin, (self.bounds.size.height - 20)/2.0, 20.0, 20.0);
    title.frame = CGRectMake(img.frame.origin.x + img.frame.size.width + 10, (self.bounds.size.height - sizeText.height)/2.0, sizeText.width, sizeText.height);
    //NSLog(@"tst %f", title.frame.origin.x + title.frame.size.width + xBegin);
}
@end

// ================================================================
@interface OptionMenuChatCell () {
    OptionMenuButton *likeBtn;
    OptionMenuButton *errorBtn;
    OptionMenuButton *expertBtn;
}

@end
@implementation OptionMenuChatCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        self.borderColor = [[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] colorWithAlphaComponent:0.35].CGColor;
        self.borderWidth = 0.5f;
        self.cornerRadius = 20.0;
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeMake(1.0, 2.0f);
        self.layer.shadowRadius = 2;
        
        likeBtn = [[OptionMenuButton alloc] initWithTitle: @"Chính xác" withImg: @"like_option_menu_cell"];
        [likeBtn addTarget:self action:@selector(handleLike) forControlEvents:ASControlNodeEventTouchUpInside];
        [self addSubnode:likeBtn];
        
        errorBtn = [[OptionMenuButton alloc] initWithTitle: @"Sai rồi" withImg: @"error_option_menu_cell"];
        [errorBtn addTarget:self action:@selector(handleDislike) forControlEvents:ASControlNodeEventTouchUpInside];
        [self addSubnode:errorBtn];
        
        expertBtn = [[OptionMenuButton alloc] initWithTitle: @"Gửi chuyên gia" withImg: @"request_expert_option_menu_cell"];
        [expertBtn addTarget:self action:@selector(handleRequestExpert) forControlEvents:ASControlNodeEventTouchUpInside];
        [self addSubnode:expertBtn];
    }
    return self;
}
- (void) layout {
    [super layout];
    float xT;
    xT = 15;
    likeBtn.frame = CGRectMake(xT, 0, likeBtn.sizeContent.width, self.bounds.size.height);
    xT += likeBtn.sizeContent.width + 15;
    errorBtn.frame = CGRectMake(xT, 0, errorBtn.sizeContent.width, self.bounds.size.height);
    xT += errorBtn.sizeContent.width + 15;
    expertBtn.frame = CGRectMake(xT, 0, expertBtn.sizeContent.width, self.bounds.size.height);
//    xT += expertBtn.sizeContent.width + 15;
//    NSLog(@"%f", xT);
}
- (void) handleLike {
    [[Manager instance].currentChatVC.listNode hideOptionMenuForCell];
    [self.weakCell.weakData rateMessage:YES];
}
- (void) handleDislike {
    [[Manager instance].currentChatVC.listNode hideOptionMenuForCell];
    [self.weakCell.weakData rateMessage:NO];
}
- (void) handleRequestExpert {
    [[Manager instance].currentChatVC.listNode hideOptionMenuForCell];
    [self.weakCell.weakData sendExpert];
}
- (void) setWeakCell:(BaseChatCell *)weakCell {
    _weakCell = weakCell;
    if (_weakCell && [_weakCell.weakData canSendExpert]) {
        expertBtn.hidden = NO;
    }
    else {
        expertBtn.hidden = YES;
    }
}
@end
