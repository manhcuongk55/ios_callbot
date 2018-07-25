//
//  NavBarView.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AsyncDisplayKit.h"
#import "NotiButton.h"
@interface NavBarView : ASDisplayNode

@property (nonatomic, strong) ASButtonNode *rightBtn;
@property (nonatomic, strong) NotiButton *leftBtn;
- (void) setTitle: (NSString *) title;
@end
