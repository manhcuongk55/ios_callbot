//
// Copyright 2016 Google Inc. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import <AVFoundation/AVFoundation.h>

#import "SpeechControl.h"
#import "AudioController.h"
#import "SpeechRecognitionService.h"
#import "google/cloud/speech/v1/CloudSpeech.pbrpc.h"
#import "Speech-Swift.h"
#import "Manager.h"
#import "TtsVTCCControl.h"

#define SAMPLE_RATE 16000.0f

@interface SpeechControl () <AudioControllerDelegate> {
    NSTimeInterval lastTimeReceiveTranscript;
    NSString *currentText;
    NSTimer *timer;
}
@property (nonatomic, strong) NSMutableData *audioData;
@end

@implementation SpeechControl

- (instancetype)init
{
    self = [super init];
    if (self) {
        [AudioController sharedInstance].delegate = self;
    }
    return self;
}

- (void) recordAudio {
    
    [[TTSVocalizer sharedInstance] stopPlayer];
    [[TtsVTCCControl instance] stopPlayer];
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    _audioData = [[NSMutableData alloc] init];
    [[AudioController sharedInstance] prepareWithSampleRate:SAMPLE_RATE];
    [[SpeechRecognitionService sharedInstance] setSampleRate:SAMPLE_RATE];
    [[AudioController sharedInstance] start];
    
    [self cancelTimer];
    lastTimeReceiveTranscript = [[NSDate date] timeIntervalSince1970];
    currentText = @"";
    [self timerStopRecording];
}

- (void) stopAudio {
    [[AudioController sharedInstance] stop];
    [[SpeechRecognitionService sharedInstance] stopStreaming];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:NO error:nil];
    
}

- (void) processSampleData:(NSData *)data {
    [self.audioData appendData:data];
    //
    NSInteger frameCount = [data length] / 2;
    int16_t *samples = (int16_t *) [data bytes];
    int64_t sum = 0;
    for (int i = 0; i < frameCount; i++) {
        sum += abs(samples[i]);
    }
    
    // We recommend sending samples in 100ms chunks
    int chunk_size = 0.1 /* seconds/chunk */ * SAMPLE_RATE * 2 /* bytes/sample */ ; /* bytes/chunk */
    
    if ([self.audioData length] > chunk_size) {
        [[SpeechRecognitionService sharedInstance] streamAudioData:self.audioData
                                                    withCompletion:^(StreamingRecognizeResponse *response, NSError *error) {
                                                        //NSLog(@"response %@", response);
                                                        if (error) {
                                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                                [self.delegate receiveTextFromSpeech: @""];
                                                            });
                                                            [self stopAudio];
                                                            [self cancelTimer];
                                                        } else if (response) {
                                                            BOOL finished = NO;
                                                            
                                                            lastTimeReceiveTranscript = [[NSDate date] timeIntervalSince1970];
                                                            [self cancelTimer];
                                                            
                                                            currentText = @"";
                                                            for (StreamingRecognitionResult *result in response.resultsArray) {
                                                                if (!result.isFinal) {
                                                                    NSMutableArray *list = result.alternativesArray;
                                                                    if (list && list.count > 0) {
                                                                        for (int i = 0; i<list.count; i ++) {
                                                                            SpeechRecognitionAlternative *item = list[i];
                                                                            currentText = [NSString stringWithFormat:@"%@%@", currentText, item.transcript];
                                                                        }
                                                                        [[Manager instance].currentChatVC.chatBox updateTranscript:currentText];
                                                                    }
                                                                    [self timerStopRecording];
                                                                }
                                                                if (result.isFinal) {
                                                                    NSMutableArray *list = result.alternativesArray;
                                                                    if (list && list.count > 0) {
                                                                        SpeechRecognitionAlternative *firstItem = list[0];
                                                                        currentText = firstItem.transcript;
                                                                    }
                                                                    finished = YES;
                                                                }
                                                            }
                                                            if (finished) {
                                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                                    [self.delegate receiveTextFromSpeech: currentText];
                                                                });
                                                                [self stopAudio];
                                                                [self cancelTimer];
                                                            }
                                                        }
                                                    }
         ];
        self.audioData = [[NSMutableData alloc] init];
    }
}
- (void) cancelTimer {
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
- (void) timerStopRecording {
    [self cancelTimer];
    if (currentText.length == 0) {
        timer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(checkStopRecording) userInfo:nil repeats:NO];
    }
    else {
        timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(checkStopRecording) userInfo:nil repeats:NO];
    }
}
- (void) checkStopRecording {
    if ([[NSDate date] timeIntervalSince1970] - lastTimeReceiveTranscript >= 2) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate receiveTextFromSpeech: @""];
        });
        
        [self stopAudio];
        
        [self cancelTimer];
        
    }
}
@end

