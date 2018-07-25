//
//  TextMessageCell.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "BaseChatCell.h"

@interface TextMessageCell : BaseChatCell

- (instancetype)initWithData: (MessageData *) data;
- (void) calculateFrame;

+ (NSDictionary *) sourceStyle;

@end
