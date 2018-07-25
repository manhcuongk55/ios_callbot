//
//  MusicMessageCell.h
//  Speech
//
//  Created by Phu on 6/20/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "BaseChatCell.h"

@interface MusicMessageCell : BaseChatCell

- (instancetype)initWithData: (MessageData *) data;
- (void) calculateFrame;

@end
