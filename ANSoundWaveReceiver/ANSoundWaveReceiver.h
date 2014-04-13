//
//  ANSoundWaveReceiver.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <Accelerate/Accelerate.h>
#import "ANFrequencyTable.h"

#define kANSoundWaveReceiverBufferCount 2
#define kANSoundWaveReceiverWindowCount 8

typedef void (^ ANSoundReceiverBlock)(ANFrequencyTable * table);

@interface ANSoundWaveReceiver : NSObject {
  AudioStreamBasicDescription audioFormat;
  AudioQueueRef audioQueue;
  AudioQueueBufferRef buffers[kANSoundWaveReceiverBufferCount];
  
  NSUInteger sampleRate;
  int framesPerBuffer;
  int framesPerWindow;
  int windowLog;
  
  DSPSplitComplex input;
  FFTSetup fftSetup;
  NSInteger buffFilled;
}

@property (nonatomic, copy) ANSoundReceiverBlock callback;

- (id)initWithSampleRate:(NSUInteger)rate;
- (void)start;
- (void)stop;

@end
