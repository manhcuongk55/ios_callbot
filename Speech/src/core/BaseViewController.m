//
//  BaseViewController.m
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController () {
}
@end

@implementation BaseViewController

- (void) addNavBar {
    self.navBar = [NavBarView new];
    [self.node addSubnode:self.navBar];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [[Utils instance] updateScreenInfo:nil];
    if ([Utils instance].isPhoneX) {
        self.navBar.frame = CGRectMake(0, [Utils instance].edgeInsets.top, self.node.frame.size.width, 44);
    }
    else {
        self.navBar.frame = CGRectMake(0, 20, self.node.frame.size.width, 44);
    }
}
- (CGRect) getContentRect {
    if ([Utils instance].isPhoneX) {
        return CGRectMake([Utils instance].edgeInsets.left, [Utils instance].edgeInsets.top, self.node.bounds.size.width - [Utils instance].edgeInsets.left - [Utils instance].edgeInsets.right, self.node.bounds.size.height - [Utils instance].edgeInsets.top - [Utils instance].edgeInsets.bottom);
    }
    else {
        return CGRectMake(0, 20, self.node.bounds.size.width, self.node.bounds.size.height-20);
    }
}
@end
