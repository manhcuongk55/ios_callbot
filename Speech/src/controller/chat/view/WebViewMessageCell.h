//
//  WebViewMessageCell.h
//  Speech
//
//  Created by Phu on 6/21/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "BaseChatCell.h"

@interface WebViewMessageCell : BaseChatCell
- (instancetype)initWithData: (MessageData *) data;
- (void) calculateFrame;
- (void) willDisplay;
- (void) didEndDisplay;
- (void) willBeginDragging;
- (void) didEndDragging: (BOOL) decelerate;
- (void) didEndDecelerating;
@end
