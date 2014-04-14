//
//  ANSoundWaveEmitter.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import "ANWaveAdder.h"

#define kANSoundWaveEmitterBufferCount 3

@interface ANSoundWaveEmitter : NSObject {
  AudioStreamBasicDescription audioFormat;
  AudioQueueRef audioQueue;
  AudioQueueBufferRef buffers[kANSoundWaveEmitterBufferCount];
  
  NSUInteger sampleRate;
  UInt32 framesPerBuffer;
  
  ANWaveAdder * adder;
  NSTimeInterval lastTime;
}

- (id)initWithSampleRate:(NSUInteger)rate bufferTime:(NSTimeInterval)aPeriod;

- (id<ANWaveGenerator>)addWave:(id<ANWaveGenerator>)gen;
- (id<ANWaveGenerator>)makeWave:(float)frequency;
- (void)removeWave:(id<ANWaveGenerator>)gen;

- (void)start;
- (void)stop;

@end
