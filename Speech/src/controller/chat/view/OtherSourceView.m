//
//  OtherSourceView.m
//  Speech
//
//  Created by Phu on 5/15/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "OtherSourceView.h"
#import <SafariServices/SafariServices.h>
#import "Manager.h"
#import "Utils.h"

// ================================================================
@interface OtherSourceButton () {
    ASTextNode *title;
    CGSize sizeText;
    BOOL isSelected;
    int idx;
}
@property (nonatomic, weak) NSDictionary *data;
@end
@implementation OtherSourceButton

- (instancetype)initWithTitle: (NSDictionary *) data_ isSelected: (BOOL) isSelected_ withIdx: (int) idx_
{
    self = [super init];
    if (self) {
        //
        isSelected = isSelected_;
        self.data = data_;
        idx = idx_;
        //
        BOOL hasBorder = NO;
        if (isSelected) {
            self.backgroundColor = [Manager instance].listColorBubble[idx % 5];
        }
        else {
            self.backgroundColor = [UIColor whiteColor];
            hasBorder = YES;
        }
        //
        self.cornerRadius = 15.0f;
        if (hasBorder) {
            self.borderWidth = 0.5;
            self.borderColor = [[UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0] colorWithAlphaComponent:0.35].CGColor;
        }
        self.layer.masksToBounds = NO;
        self.layer.shadowColor = [UIColor colorWithRed:150.0/255.0 green:150.0/255.0 blue:150.0/255.0 alpha:1.0].CGColor;
        self.layer.shadowOpacity = 0.8;
        self.layer.shadowOffset = CGSizeMake(0.0, 2.0f);
        self.layer.shadowRadius = 2;
        //
        title = [ASTextNode new];
        //
        NSString* urlString = self.data[@"url"];
        NSURL* url = [NSURL URLWithString:urlString];
        NSString* domain = [url host];
        //
        title.attributedText = [[NSAttributedString alloc] initWithString: domain attributes:[self titleStyle]];
        [self addSubnode:title];
        //
        sizeText = [title calculateSizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        self.sizeContent = CGSizeMake(sizeText.width + 30, sizeText.height);
        //
    }
    return self;
}
- (NSDictionary *)titleStyle {
    UIFont *font = [UIFont systemFontOfSize:15.0];
    
    return @{
             NSFontAttributeName: font,
             NSForegroundColorAttributeName: isSelected?[Manager instance].listColorText[idx % 5] : [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0],
             };
}
- (void) layout {
    [super layout];
    title.frame = CGRectMake(15, (self.bounds.size.height - sizeText.height)/2.0, sizeText.width, sizeText.height);
}
@end

// ================================================================

@interface OtherSourceView () {
    NSMutableArray *listItems;
    int idxSelected;
}
@property (nonatomic, weak) NSArray *listDatas;
@end

@implementation OtherSourceView

- (instancetype)initWithData: (NSArray *) listDatas_ andSelectIdx: (int) idx
{
    self = [super init];
    if (self) {
        idxSelected = idx;
        self.view.showsHorizontalScrollIndicator = NO;
        listItems = [NSMutableArray new];
        self.listDatas = listDatas_;
        for (int i = 0; i<self.listDatas.count; i++) {
            OtherSourceButton *item = [[OtherSourceButton alloc] initWithTitle: self.listDatas[i] isSelected:(i == idx) withIdx:i];
            [self addSubnode:item];
            [listItems addObject:item];
            item.view.tag = i + 1;
            [item addTarget:self action:@selector(clickedItem:) forControlEvents:ASControlNodeEventTouchUpInside];
        }
    }
    return self;
}
- (void) layout {
    [super layout];
    float xT = 3;
    for (int i = 0; i<self.listDatas.count; i++) {
        OtherSourceButton *item = listItems[i];
        item.frame = CGRectMake(xT, 0, item.sizeContent.width, self.bounds.size.height-5);
        xT += item.frame.size.width + 15;
    }
    self.view.contentSize = CGSizeMake(xT, self.bounds.size.height);
}
- (void) clickedItem: (ASButtonNode *) btn {
    int idx = btn.view.tag - 1;
    [self.delegate didSelectSourceAtIdx:idx];
}
@end
