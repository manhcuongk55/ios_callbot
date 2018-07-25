//
//  AudioQueuePlayer.m
//  Speech
//
//  Created by Phu on 7/23/18.
//  Copyright © 2018 Google. All rights reserved.
//

#import "AudioQueuePlayer.h"

#define MIN_SIZE_PER_FRAME 2000
#define QUEUE_BUFFER_SIZE 3

@interface AudioQueuePlayer() {
    
    AudioQueueRef audioQueue;
    AudioStreamBasicDescription _audioDescription;
    AudioQueueBufferRef audioQueueBuffers[QUEUE_BUFFER_SIZE];
    BOOL audioQueueBufferUsed[QUEUE_BUFFER_SIZE];
    NSLock *sysnLock;
    NSMutableData *tempData;
    OSStatus osState;
    BOOL isRunning;
    BOOL isLock;
}

@end


@implementation AudioQueuePlayer

- (instancetype)init
{
    self = [super init];
    if (self) {
        sysnLock = [[NSLock alloc]init];
        
        if (_audioDescription.mSampleRate <= 0) {
            _audioDescription.mSampleRate = 16000.0;
            _audioDescription.mFormatID = kAudioFormatLinearPCM;
            // The following is a description of the way to save audio data, such as can save data according to big endian or little endian, floating point or integer and different body positions.
            _audioDescription.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
            // 1 mono 2 stereo
            _audioDescription.mChannelsPerFrame = 1;
            // Each packet detects data, the number of turns under each packet, that is, how many flaws are in each packet.
            _audioDescription.mFramesPerPacket = 1;
            //
            _audioDescription.mBitsPerChannel = 16;
            _audioDescription.mBytesPerFrame = (_audioDescription.mBitsPerChannel / 8) * _audioDescription.mChannelsPerFrame;
            //The total number of bytes per packet, the number of bytes per * * the number of bytes per packet
            _audioDescription.mBytesPerPacket = _audioDescription.mBytesPerFrame * _audioDescription.mFramesPerPacket;
            //
            isRunning = NO;
            //
            isLock = NO;
        }
    }
    return self;
}
- (void) start {
    if (!isRunning) {
        isRunning = YES;
        
        // Use the player's internal thread to play New output
        AudioQueueNewOutput(&_audioDescription, AudioPlayerAQInputCallback, (__bridge void * _Nullable)(self), nil, 0, 0, &audioQueue);
        
        // Set the volume
        AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
        
        // Initialize the required buffer
        for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
            audioQueueBufferUsed[i] = false;
            
            osState = AudioQueueAllocateBuffer(audioQueue, MIN_SIZE_PER_FRAME, &audioQueueBuffers[i]);
            
            printf("\nThe %d AudioQueueAllocateBuffer initialization result %d (0 means success)", i + 1, osState);
        }
        
        osState = AudioQueueStart(audioQueue, NULL);
        if (osState != noErr) {
            printf("\nAudioQueueStart Error");
        }
    }
}

- (void) stop {
    
    isRunning = NO;
    
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        audioQueueBufferUsed[i] = false;
    }
    
    if (audioQueue != nil) {
        AudioQueueReset(audioQueue);
        AudioQueueStop(audioQueue,true);
        AudioQueueDispose(audioQueue, true);
    }
    
}

// Play data
-(void)playWithData:(NSData *)data {
    if (!isRunning) {
        if (isLock) {
            isLock = NO;
            [sysnLock unlock];
        }
        return;
    }
    
    isLock = YES;
    [sysnLock lock];
    
    tempData = [NSMutableData new];
    [tempData appendData: data];
    // Get data
    NSUInteger len = tempData.length;
    Byte *bytes = (Byte*)malloc(len);
    [tempData getBytes:bytes length: len];
    
    int i = 0;
    while (true) {
        if (!audioQueueBufferUsed[i]) {
            audioQueueBufferUsed[i] = true;
            break;
        }else {
            i++;
            if (i >= QUEUE_BUFFER_SIZE) {
                i = 0;
            }
        }
    }
    
    audioQueueBuffers[i] -> mAudioDataByteSize =  (unsigned int)len;
    // Give the len byte of the byte's head address to mAudioData
    memcpy(audioQueueBuffers[i] -> mAudioData, bytes, len);
    //
    free(bytes);
    //
    AudioQueueEnqueueBuffer(audioQueue, audioQueueBuffers[i], 0, NULL);
    
    printf("\nThe size of this play data: %lu", len);
    isLock = NO;
    [sysnLock unlock];
}

// ************************** Callback **********************************

// Callback to set the buffer status to unused
static void AudioPlayerAQInputCallback(void* inUserData,AudioQueueRef audioQueueRef, AudioQueueBufferRef audioQueueBufferRef) {
    
    AudioQueuePlayer* player = (__bridge AudioQueuePlayer*)inUserData;
    
    [player resetBufferState:audioQueueRef and:audioQueueBufferRef];
}

- (void)resetBufferState:(AudioQueueRef)audioQueueRef and:(AudioQueueBufferRef)audioQueueBufferRef {
    
    for (int i = 0; i < QUEUE_BUFFER_SIZE; i++) {
        // Set this buffer to unused
        if (audioQueueBufferRef == audioQueueBuffers[i]) {
            audioQueueBufferUsed[i] = false;
        }
    }
}

- (void)dealloc {
    
    [self stop];
    
    audioQueue = nil;
    
    sysnLock = nil;
}

@end
