//
//  LoginTextBox.h
//  VA
//
//  Created by Phu on 5/8/18.
//  Copyright © 2018 Viettel VTCC. All rights reserved.
//

#import "AsyncDisplayKit.h"

@interface LoginTextBox : ASDisplayNode

@property (nonatomic, strong) UITextField *tf;

- (instancetype)initWithType: (int) type;

@end
