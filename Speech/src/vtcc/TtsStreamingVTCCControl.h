//
//  TtsStreamingVTCCControl.h
//  Speech
//
//  Created by Phu on 7/23/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface TtsStreamingVTCCControl : NSObject

+ (TtsStreamingVTCCControl*)instance;

- (void) vocalize: (NSString *) text;

@end
