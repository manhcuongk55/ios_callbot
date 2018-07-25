//
//  OptionMenuChatCell.h
//  Speech
//
//  Created by Phu on 5/14/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"
@class BaseChatCell;

@interface OptionMenuButton : ASButtonNode

- (instancetype)initWithTitle: (NSString *) titleStr withImg: (NSString *) imgStr;
@property (nonatomic, assign) CGSize sizeContent;
- (void) addShadow;
@end

@interface OptionMenuChatCell : ASDisplayNode
@property (nonatomic, weak) BaseChatCell *weakCell;
@end
