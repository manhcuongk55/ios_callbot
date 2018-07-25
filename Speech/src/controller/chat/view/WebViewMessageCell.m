//
//  WebViewMessageCell.m
//  Speech
//
//  Created by Phu on 6/21/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "WebViewMessageCell.h"
#import "Manager.h"
#import "UIImageView+WebCache.h"
#import <WebKit/WebKit.h>
#import "CustomUIWebView.h"

@interface WebViewMessageCell () {
    CustomUIWebView *webView;
    BOOL loadedHTML;
}

@end

@implementation WebViewMessageCell

- (instancetype)initWithData: (MessageData *) data {
    self = [super initWithData:data];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        //
        webView = [[CustomUIWebView alloc] init];
        webView.msgData = self.weakData;
        [webView setShow: NO];
        //
        loadedHTML = NO;
        //
        [self addAvatarImg];
    }
    return self;
}
- (void) calculateFrame {
    [super calculateFrame];
    float xT, yT;
    xT = 10;
    yT = 10;
    self.avatarImg.frame = CGRectMake(xT, yT, self.weakData.avatarRect.size.width, self.weakData.avatarRect.size.height);
    xT = 10;
    yT += self.avatarImg.frame.size.height + 10;
    webView.frame = CGRectMake(xT, yT, self.weakData.webViewRect.size.width, self.weakData.webViewRect.size.height);
    [webView setShow: YES];
    [self.view addSubview:webView];
}
- (void) willDisplay {
    if (!loadedHTML) {
        loadedHTML = YES;
        [webView.webView loadHTMLString: self.weakData.htmlStr baseURL:[[NSBundle mainBundle] bundleURL]];
    }
    [webView setShow: YES];
    [self.view addSubview:webView];
}
- (void) didEndDisplay {
    [webView setShow: NO];
    [webView removeFromSuperview];
}
- (void) willBeginDragging {
}
- (void) didEndDragging: (BOOL) decelerate {
}
- (void) didEndDecelerating {
}
@end

