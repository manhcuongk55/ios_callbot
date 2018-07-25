//
//  BaseViewController.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "ASViewController.h"
#import "AsyncDisplayKit.h"
#import "Utils.h"
#import "NavBarView.h"
@interface BaseViewController : ASViewController

@property (nonatomic, strong) NavBarView *navBar;
- (CGRect) getContentRect;

- (void) addNavBar;

@end
