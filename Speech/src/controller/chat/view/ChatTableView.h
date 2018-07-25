//
//  ChatTableView.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "MessageData.h"

@interface ChatTableView : ASDisplayNode
@property (nonatomic, strong) ASTableNode *tableView;
- (void) addMsgData: (MessageData *) msgData;
- (void) showOptionMenuForCell: (ASCellNode *) cell;
- (void) hideOptionMenuForCell;
@end
