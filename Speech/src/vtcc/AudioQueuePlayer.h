//
//  AudioQueuePlayer.h
//  Speech
//
//  Created by Phu on 7/23/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AudioQueuePlayer : NSObject

- (void)playWithData: (NSData *)data;
- (void)stop;
- (void)start;

@end
