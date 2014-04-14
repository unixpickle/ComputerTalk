//
//  ANXfer.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANXfer.h"
#import "ANSoundWaveReceiver.h"

@interface ANXfer (Private)

- (void)_handleFrameTable:(ANFrequencyTable *)table;
- (void)_applyRest;
- (void)_sendNextBit;

@end

@implementation ANXfer

- (id)initWithSampleRate:(NSInteger)aRate
                sendFreq:(float)sFreq
                 recFreq:(float)rFreq {
  if ((self = [super init])) {
    sampleRate = aRate;
    cbPerSecond = MIN(MIN(60, (int)(sFreq / 15.0)), (int)(rFreq / 15.0));
    bitDuration = 3.0f / (float)cbPerSecond;
    
    float windowFrameSize = (float)aRate / (float)cbPerSecond;
    int windowLog = (int)log2f(windowFrameSize);
    windowSize = 1 << windowLog;
    
    // frequency = scale * index => index = frequency / scale
    float scale = (float)aRate / windowSize;
    sendIndex = (NSInteger)round(sFreq / scale);
    recIndex = (NSInteger)round(rFreq / scale);
    
    if ([self indexForRec:ANXferFreqOff] > windowSize) return nil;
  }
  return self;
}

- (float)frequencyForSend:(ANXferFreq)type {
  // frequency = scale * index
  float scale = (float)sampleRate / windowSize;
  return scale * (float)(sendIndex + (type * 2));
}

- (NSInteger)indexForRec:(ANXferFreq)type {
  return recIndex + (type * 2);
}

#pragma mark - Transfer -

- (void)start {
  bitBuffer = [[NSMutableArray alloc] init];
  wasStopped = YES;
  
  emitter = [[ANSoundWaveEmitter alloc] initWithSampleRate:sampleRate
                                                bufferTime:0.1];
  [emitter start];
  sendOn = [emitter makeWave:[self frequencyForSend:ANXferFreqOn]];
  sendOff = [emitter makeWave:[self frequencyForSend:ANXferFreqOff]];
  sendData = [emitter makeWave:[self frequencyForSend:ANXferFreqData]];
  sendRest = [emitter makeWave:[self frequencyForSend:ANXferFreqRest]];
  [emitter addWave:sendRest];
  
  receiver = [[ANSoundWaveReceiver alloc] initWithSampleRate:sampleRate
                                                      cbRate:cbPerSecond];
  
  __weak id weakSelf = self;
  receiver.callback = ^(ANFrequencyTable * table) {
    [weakSelf _handleFrameTable:table];
  };
  [receiver start];
}

- (void)stop {
  [emitter stop];
  [receiver stop];
  emitter = nil;
  receiver = nil;
  [sendTimeout invalidate];
  sendTimeout = nil;
}

- (void)sendBit:(BOOL)flag {
  if (!sendTimeout) {
    [emitter removeWave:sendRest];
    [emitter addWave:sendData];
    [emitter addWave:flag ? sendOn : sendOff];
    sendTimeout = [NSTimer scheduledTimerWithTimeInterval:bitDuration
                                                   target:self
                                                 selector:@selector(_applyRest)
                                                 userInfo:nil repeats:NO];
  } else {
    [bitBuffer addObject:@(flag)];
  }
}

#pragma mark - Private -

- (void)_handleFrameTable:(ANFrequencyTable *)table {
  NSInteger dataIdx = [self indexForRec:ANXferFreqData];
  NSInteger restIdx = [self indexForRec:ANXferFreqRest];
  NSInteger onIdx = [self indexForRec:ANXferFreqOn];
  NSInteger offIdx = [self indexForRec:ANXferFreqOff];
  float dataAmp = [table amplitudeAtIndex:dataIdx];
  float restAmp = [table amplitudeAtIndex:restIdx];
  BOOL isStopped = restAmp * 3.0 >= dataAmp;
  
  if (!wasStopped && isStopped) {
    wasStopped = YES;
    if (self.callback) self.callback(wasOn);
  } else if (!isStopped) {
    float onAmp = [table amplitudeAtIndex:onIdx];
    float offAmp = [table amplitudeAtIndex:offIdx];
    wasOn = onAmp > offAmp;
    wasStopped = NO;
  }
}

- (void)_applyRest {
  [emitter removeWave:sendOff];
  [emitter removeWave:sendOn];
  [emitter removeWave:sendData];
  [emitter addWave:sendRest];
  sendTimeout = [NSTimer scheduledTimerWithTimeInterval:bitDuration
                                                 target:self
                                               selector:@selector(_sendNextBit)
                                               userInfo:nil repeats:NO];
}

- (void)_sendNextBit {
  sendTimeout = nil;
  if (![bitBuffer count]) {
    if (self.drainCallback) self.drainCallback();
    return;
  }
  NSNumber * val = [bitBuffer objectAtIndex:0];
  [bitBuffer removeObjectAtIndex:0];
    
  [emitter removeWave:sendRest];
  [emitter addWave:sendData];
  [emitter addWave:val.boolValue ? sendOn : sendOff];
  sendTimeout = [NSTimer scheduledTimerWithTimeInterval:bitDuration
                                                 target:self
                                               selector:@selector(_applyRest)
                                               userInfo:nil repeats:NO];
}

@end
