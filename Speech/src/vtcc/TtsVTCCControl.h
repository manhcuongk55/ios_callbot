//
//  TtsVTCCControl.h
//  Speech
//
//  Created by Phu on 6/28/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TtsVTCCControl : NSObject

+ (TtsVTCCControl*)instance;
- (void) vocalize: (NSString *) text;
- (void) stopPlayer;
- (void) setMute: (BOOL) mute;
@end
