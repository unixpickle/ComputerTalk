//
//  ANSoundWaveReceiver.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANSoundWaveReceiver.h"

static void _sample_callback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp * inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription * inPacketDescs);

@interface ANSoundWaveReceiver (Private)

- (void)bufferDone:(AudioQueueBufferRef)buffer count:(UInt32)count;

@end

@implementation ANSoundWaveReceiver

- (id)initWithSampleRate:(NSUInteger)rate {
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
    OSStatus status = AudioQueueNewInput(&audioFormat, _sample_callback, (__bridge void *)self,
                                         CFRunLoopGetCurrent(), kCFRunLoopCommonModes,
                                         0, &audioQueue);
    if (status != noErr) {
      return nil;
    }
    
    // figure out how many samples (aka frames) are in a certain quantum
    float windowFrameSize = (float)rate / kANSoundWaveReceiverPerSecond;
    windowLog = (int)log2f(windowFrameSize);
    framesPerWindow = 1 << windowLog;
    framesPerBuffer = framesPerWindow * kANSoundWaveReceiverWindowCount;
    
    // create the audio buffers
    for (int i = 0; i < kANSoundWaveReceiverBufferCount; i++) {
      status = AudioQueueAllocateBuffer(audioQueue, sizeof(Float32) * framesPerBuffer, &buffers[i]);
      if (status != noErr) {
        for (int j = i - 1; j >= 0; j--) {
          AudioQueueFreeBuffer(audioQueue, buffers[j]);
        }
        AudioQueueDispose(audioQueue, NO);
        return nil;
      }
    }
    
    fftSetup = vDSP_create_fftsetup(windowLog, kFFTRadix2);
    NSAssert(fftSetup, @"failed to configure FFT");
    
    input.imagp = (float *)malloc(4 * framesPerWindow);
    input.realp = (float *)malloc(4 * framesPerWindow);
  }
  return self;
}

- (void)start {
  for (int i = 0; i < kANSoundWaveReceiverBufferCount; i++) {
    AudioQueueEnqueueBuffer(audioQueue, buffers[i], 0, NULL);
  }
  AudioQueueStart(audioQueue, NULL);
  AudioQueueSetParameter(audioQueue, kAudioQueueParam_Volume, 1.0);
}

- (void)stop {
  AudioQueueReset(audioQueue);
  AudioQueueStop(audioQueue, YES);
}

- (void)dealloc {
  vDSP_destroy_fftsetup(fftSetup);
  for (int i = 0; i < kANSoundWaveReceiverBufferCount; i++) {
    AudioQueueFreeBuffer(audioQueue, buffers[i]);
  }
  AudioQueueDispose(audioQueue, NO);
  free(input.imagp);
  free(input.realp);
}

#pragma mark - Private -

- (void)bufferDone:(AudioQueueBufferRef)buffer count:(UInt32)count {
  // process the frequencies at each place in the sampling
  Float32 * samples = (Float32 *)buffer->mAudioData;
  
  int remaining = 0;
  for (int i = 0; i < (int)count; i += remaining) {
    remaining = (int)count - i;
    if (remaining > framesPerWindow - buffFilled) {
      remaining = (int)(framesPerWindow - buffFilled);
    }
    bzero(&input.imagp[buffFilled], 4 * remaining);
    memcpy(&input.realp[buffFilled], &samples[i], 4 * remaining);
    
    if (remaining + buffFilled == remaining) {
      // forward frequency table
      vDSP_fft_zip(fftSetup, &input, 1, windowLog, FFT_FORWARD);
      buffFilled = 0;
      ANFrequencyTable * table = [[ANFrequencyTable alloc] initWithFFTResult:input count:framesPerWindow];
      if (self.callback) self.callback(table);
    } else {
      buffFilled += remaining;
    }
  }
  
  AudioQueueEnqueueBuffer(audioQueue, buffer, 0, NULL);
}

@end

static void _sample_callback(void * inUserData, AudioQueueRef inAQ, AudioQueueBufferRef inBuffer, const AudioTimeStamp * inStartTime, UInt32 inNumberPacketDescriptions, const AudioStreamPacketDescription * inPacketDescs) {
  ANSoundWaveReceiver * recv = (__bridge ANSoundWaveReceiver *)inUserData;
  [recv bufferDone:inBuffer count:inNumberPacketDescriptions];
}
