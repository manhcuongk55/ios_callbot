//
//  TableWebView.h
//  TableWebView
//
//  Created by Sergey Gavrilyuk on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MessageData.h"

@interface CustomUIWebView : UIView

@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, weak) MessageData *msgData;
- (void) setShow: (BOOL) show;

@end
