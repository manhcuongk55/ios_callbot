//
//  TableWebView.m
//  TableWebView
//
//  Created by Sergey Gavrilyuk on 4/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CustomUIWebView.h"

@interface CustomUIWebView () <UIWebViewDelegate> {
    BOOL isFinishLoaded;
    BOOL canShow;
    UIActivityIndicatorView *loading;
}
@end

@implementation CustomUIWebView
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor lightGrayColor];
        self.layer.cornerRadius = 5.0f;
        //
        loading = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loading.frame = CGRectMake(0, 0, 24, 24);
        [loading startAnimating];
        [self addSubview: loading];
        //
        self.webView = [[UIWebView alloc] init];
        //self.webView.scrollView.scrollEnabled = NO;
        self.webView.scrollView.bounces = NO;
        //self.webView.userInteractionEnabled = NO;
        self.webView.scalesPageToFit = YES;
        self.webView.delegate = self;
        self.webView.hidden = YES;
        [self addSubview:self.webView];
        isFinishLoaded = NO;
    }
    return self;
}
//- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
//    NSLog(@"%@", request.URL.absoluteString);
//    return YES;
//}
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    //NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"a" ofType:@"html"];
    //NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

    //[webView stringByEvaluatingJavaScriptFromString:@"<script type=\"text/javascript\"> window.onload = function() { window.location.href = \"ready://\" + document.body.offsetHeight;} </script>"];
    if ([[webView stringByEvaluatingJavaScriptFromString:@"document.readyState"] isEqualToString:@"complete"]) {
        isFinishLoaded = YES;
        [loading stopAnimating];
        [loading removeFromSuperview];
        loading = nil;
        //
        if (canShow) {
            self.webView.hidden = NO;
        }
        //
        //NSLog(@"fitSize %f - %f",width, height);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CGFloat height = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetHeight"] floatValue];
            CGFloat width = [[self.webView stringByEvaluatingJavaScriptFromString:@"document.body.offsetWidth"] floatValue];
            //
//            CGFloat height1 = [[self.webView stringByEvaluatingJavaScriptFromString: @"document.height"] floatValue];
//            CGFloat height2 = [[self.webView stringByEvaluatingJavaScriptFromString: @"document.body.offsetHeight"] floatValue];
//            NSLog(@"debug height %f - %f - %f", height1, height2, self.webView.scrollView.contentSize.height);
            //
            [self.msgData setHtmlRatio: height/width];
        });
    }
}
- (void) layoutSubviews {
    [super layoutSubviews];
    self.webView.frame = self.bounds;
    loading.frame = CGRectMake((self.bounds.size.width - 24)/2.0, (self.bounds.size.height - 24)/2.0, 24, 24);
}
- (void) setShow: (BOOL) show {
    canShow = show;
    if (canShow) {
        if (isFinishLoaded) {
            self.webView.hidden = NO;
        }
        else {
            self.webView.hidden = YES;
        }
    }
    else {
        self.webView.hidden = YES;
    }
}
@end
