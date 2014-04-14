//
//  ANSoundWaveEmitter.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANSoundWaveEmitter.h"
#import "ANSineGenerator.h"

static void _sample_callback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer);

@interface ANSoundWaveEmitter (Private)

- (void)sampleCallback:(AudioQueueBufferRef)buffer;

@end

@implementation ANSoundWaveEmitter

- (id)initWithSampleRate:(NSUInteger)rate bufferTime:(NSTimeInterval)aPeriod {
  if ((self = [super init])) {
    sampleRate = rate;
    audioFormat.mFormatID = kAudioFormatLinearPCM;
    audioFormat.mChannelsPerFrame = 1;
    audioFormat.mBitsPerChannel = 8 * sizeof(Float32);
    audioFormat.mFramesPerPacket = 1;
    audioFormat.mSampleRate = rate;
    audioFormat.mBytesPerFrame = sizeof(Float32);
    audioFormat.mBytesPerPacket = sizeof(Float32);
    audioFormat.mFormatFlags = kAudioFormatFlagIsNonInterleaved | kAudioFormatFlagIsPacked | kAudioFormatFlagIsFloat;
    
    // create the audio queue
    OSStatus status = AudioQueueNewOutput(&audioFormat, _sample_callback,
                        (__bridge void *)self, CFRunLoopGetCurrent(),
                        kCFRunLoopDefaultMode, 0, &audioQueue);
    if (status != noErr) {
      return nil;
    }
    
    framesPerBuffer = round((double)rate * aPeriod);
    adder = [[ANWaveAdder alloc] initWithSampleCount:framesPerBuffer rate:rate];
    
    // create the audio buffers
    for (int i = 0; i < kANSoundWaveEmitterBufferCount; i++) {
      status = AudioQueueAllocateBuffer(audioQueue, sizeof(Float32) * framesPerBuffer, &buffers[i]);
      if (status != noErr) {
        for (int j = i - 1; j >= 0; j--) {
          AudioQueueFreeBuffer(audioQueue, buffers[j]);
        }
        AudioQueueDispose(audioQueue, NO);
        return nil;
      }
    }
  }
  return self;
}

- (void)start {
  lastTime = [[NSDate date] timeIntervalSinceReferenceDate];
  [adder resetOffset];
  for (int i = 0; i < kANSoundWaveEmitterBufferCount; i++) {
    [self sampleCallback:buffers[i]];
  }
  
  AudioQueueStart(audioQueue, NULL);
  AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
}

- (void)stop {
  AudioQueueReset(audioQueue);
  AudioQueueStop(audioQueue, YES);
}

- (id<ANWaveGenerator>)addWave:(id<ANWaveGenerator>)gen {
  NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
  [adder fillForTime:now - lastTime];
  lastTime = now;
  
  [adder addGenerator:gen];
  return gen;
}

- (id<ANWaveGenerator>)makeWave:(float)frequency {
  return [[ANSineGenerator alloc] initWithSampleCount:framesPerBuffer
                                                 rate:sampleRate
                                            frequency:frequency];
}

- (void)removeWave:(id<ANWaveGenerator>)gen {
  NSTimeInterval now = [[NSDate date] timeIntervalSinceReferenceDate];
  [adder fillForTime:now - lastTime];
  lastTime = now;
  
  [adder removeGenerator:gen];
}

- (void)dealloc {
  for (int i = 0; i < kANSoundWaveEmitterBufferCount; i++) {
    AudioQueueFreeBuffer(audioQueue, buffers[i]);
  }
  AudioQueueDispose(audioQueue, NO);
}

#pragma mark - Private -

- (void)sampleCallback:(AudioQueueBufferRef)buffer {
  lastTime = [[NSDate date] timeIntervalSinceReferenceDate];
  
  // copy out the buffer
  [adder fillForRemainder];
  Float32 * samples = (Float32 *)buffer->mAudioData;
  memcpy(samples, adder.buffer,
         framesPerBuffer * audioFormat.mBytesPerFrame);
  
  [adder resetOffset];
  buffer->mAudioDataByteSize = framesPerBuffer * audioFormat.mBytesPerFrame;
  AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
}

@end

static void _sample_callback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inCompleteAQBuffer) {
  ANSoundWaveEmitter * emitter = (__bridge ANSoundWaveEmitter *)inUserData;
  [emitter sampleCallback:inCompleteAQBuffer];
}
