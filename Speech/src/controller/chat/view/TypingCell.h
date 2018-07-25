//
//  TypingCell.h
//  Speech
//
//  Created by Phu on 5/10/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "BaseChatCell.h"

@interface TypingCell : BaseChatCell

- (instancetype)initWithData: (MessageData *) data;
- (void) calculateFrame;

@end
