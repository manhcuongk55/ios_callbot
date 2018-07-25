//
//  TtsVTCCControl.m
//  Speech
//
//  Created by Phu on 6/28/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "TtsVTCCControl.h"
#import <AVFoundation/AVFoundation.h>
#import "HTTPNetworkControl.h"

@interface TtsVTCCControl () <NSURLConnectionDelegate> {
    AVAudioPlayer *player;
    NSURLSessionDownloadTask *dataTask;
}
@end

@implementation TtsVTCCControl

static TtsVTCCControl *inst = nil;

+ (TtsVTCCControl*) instance {
    @synchronized(self) {
        if (inst == nil)
            inst = [[self alloc] init];
    }
    return inst;
}
- (void) vocalize: (NSString *) text {
    // Stop dataTask
    if (dataTask) {
        [dataTask cancel];
        dataTask = nil;
    }
    // Create post data
    NSString *post = [NSString stringWithFormat:@"data=%@&voices=phamtienquan-cleanbytool-balance-3k7&key=K9W6tNTeUuwrkyYARkAmzJ94D9vUR2Qdo5YwVI7D", text];
    NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
    NSString *postLength = [NSString stringWithFormat:@"%ld",[postData length]];
    // Create request //http://203.113.152.90/hmm-stream/syn //http://203.113.152.90/tts_demo/syn
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString: @"http://203.113.152.90/hmm-stream/syn"] cachePolicy: NSURLRequestReloadIgnoringCacheData timeoutInterval:15.0];
    [request setHTTPMethod:@"POST"];
    [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPBody: postData];
    // Send request
    NSURLSessionDownloadTask *dataTask =
    [[[HTTPNetworkControl instance] getManager]
     downloadTaskWithRequest:request
     progress:^(NSProgress * _Nonnull downloadProgress) {

     }
     destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
         // Create destination
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"va_tts.wav"];
         //
         if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
             [[NSFileManager defaultManager] removeItemAtPath: filePath error: nil];
         }
         return [[NSURL alloc] initFileURLWithPath: filePath];
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        NSLog(@"finish datatask - %@ - %@ - %@", response, filePath, error);
        [self startPlayer];
    }];
    
    [dataTask resume];
    //
}
- (void) startPlayer {
    dispatch_async(dispatch_get_main_queue(), ^{
        //
        [self stopPlayer];
        //
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"va_tts.wav"];
        //
        player = [[AVAudioPlayer alloc] initWithContentsOfURL:[[NSURL alloc] initFileURLWithPath: filePath] error: nil];
        [player setVolume:1.0];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
        [player prepareToPlay];
        [player play];
        //
    });
}
- (void) stopPlayer {
    if (player) {
        [player stop];
        player = nil;
    }
}
- (void) setMute: (BOOL) mute {
    if (player) {
        [player setVolume:mute?0.0:1.0];
    }
}
@end
