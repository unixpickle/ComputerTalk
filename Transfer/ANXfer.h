//
//  ANXfer.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANSoundWaveReceiver.h"
#import "ANSoundWaveEmitter.h"

#define kANXferBitDuration 0.1

typedef enum {
  ANXferFreqData,
  ANXferFreqRest,
  ANXferFreqOn,
  ANXferFreqOff
} ANXferFreq;

typedef void (^ ANXferReceiveBlock)(BOOL bit);
typedef void (^ ANXferDrainBlock)();

@interface ANXfer : NSObject {
  NSInteger sampleRate;
  NSInteger windowSize;
  
  NSInteger sendIndex;
  NSInteger recIndex;
  
  ANSoundWaveEmitter * emitter;
  id<ANWaveGenerator> sendOn, sendOff, sendData, sendRest;
  NSMutableArray * bitBuffer;
  NSTimer * sendTimeout;
  
  ANSoundWaveReceiver * receiver;
  BOOL wasStopped, wasOn;
}

@property (nonatomic, copy) ANXferReceiveBlock callback;
@property (nonatomic, copy) ANXferDrainBlock drainCallback;

- (id)initWithSampleRate:(NSInteger)aRate
                sendFreq:(float)sFreq
                 recFreq:(float)rFreq;
- (float)frequencyForSend:(ANXferFreq)type;
- (NSInteger)indexForRec:(ANXferFreq)type;

- (void)start;
- (void)stop;

- (void)sendBit:(BOOL)flag;

@end
