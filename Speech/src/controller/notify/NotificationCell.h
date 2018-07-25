//
//  NotificationCell.h
//  Speech
//
//  Created by Phu on 5/17/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AsyncDisplayKit.h"

@interface NotificationCell : ASCellNode

@property (nonatomic, weak) NSDictionary *data;

- (instancetype)initWithData: (NSDictionary *) data;

@end
