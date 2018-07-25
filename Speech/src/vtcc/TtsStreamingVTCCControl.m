//
//  TtsStreamingVTCCControl.m
//  Speech
//
//  Created by Phu on 7/23/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "TtsStreamingVTCCControl.h"
#import "HTTPNetworkControl.h"
#import "AudioQueuePlayer.h"

@interface TtsStreamingVTCCControl () <NSURLSessionDataDelegate>{
    NSURLSessionDataTask *dataTask;
    NSURLSession *session;
    AudioQueuePlayer *player;
    BOOL isRunning;
}

@end

@implementation TtsStreamingVTCCControl

static TtsStreamingVTCCControl *inst = nil;

+ (TtsStreamingVTCCControl *) instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
        isRunning = NO;
    }
    return self;
}
- (void) vocalize: (NSString *) text {
    // Stop dataTask
    if (dataTask) {
        isRunning = NO;
        [dataTask cancel];
        dataTask = nil;
    }
    if (player) {
        [player stop];
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        player = nil;
        // Create post data
        NSString *post = [NSString stringWithFormat:@"data=%@&voices=doanngocle.htsvoice&key=K9W6tNTeUuwrkyYARkAmzJ94D9vUR2Qdo5YwVI7D", text];
        NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
        // Create request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: @"http://203.113.152.90/hmm-stream/syn"] cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:30.0];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody: postData];
        // Send request
        dataTask = [session dataTaskWithRequest:request];
        [dataTask resume];
        //
        isRunning = YES;
    });
}
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data {
    if (!isRunning) {
        return;
    }
    if (!player) {
        player = [[AudioQueuePlayer alloc] init];
    }
    [player start];
    if (data.length > 2000) {
        NSUInteger dataLength = data.length;
        int i = 0;
        while (dataLength > 2000) {
            if (dataLength > 200) {
                [player playWithData: [data subdataWithRange:NSMakeRange(i*2000, 2000)]];
                dataLength -= 2000;
            }
            else {
                [player playWithData: [data subdataWithRange:NSMakeRange(i*2000, dataLength)]];
                dataLength -= dataLength;
            }
            i ++;
        }
    }
    else {
        [player playWithData:data];
    }
}

@end
