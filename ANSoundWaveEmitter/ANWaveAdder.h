//
//  ANWaveAdder.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "ANWaveGenerator.h"

@interface ANWaveAdder : NSObject {
  Float32 * output;
  NSInteger outputCount;
  
  NSInteger offset;
  float frameTime;
  
  NSMutableArray * waves;
}

- (id)initWithSampleCount:(NSInteger)count rate:(NSInteger)rate;

- (void)fillForTime:(NSTimeInterval)time;
- (void)fillForRemainder;
- (void)resetOffset;

- (void)addGenerator:(id<ANWaveGenerator>)gen;
- (void)removeGenerator:(id<ANWaveGenerator>)gen;

- (const Float32 *)buffer;

@end
