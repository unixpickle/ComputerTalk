//
//  ANWaveAdder.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANWaveAdder.h"

@interface ANWaveAdder (Private)

- (void)_fillForCount:(NSInteger)count;

@end

@implementation ANWaveAdder

- (id)initWithSampleCount:(NSInteger)count rate:(NSInteger)rate {
  if ((self = [super init])) {
    output = (Float32 *)malloc(4 * count);
    outputCount = count;
    waves = [[NSMutableArray alloc] init];
    
    frameTime = 1.0f / (float)rate;
  }
  return self;
}

- (void)fillForTime:(NSTimeInterval)time {
  NSInteger count = (NSInteger)round(time / frameTime);
  if (count + offset > outputCount) {
    count = outputCount - offset;
  }
  [self _fillForCount:count];
}

- (void)fillForRemainder {
  [self _fillForCount:outputCount - offset];
}

- (void)resetOffset {
  offset = 0;
  bzero(output, 4 * outputCount);
}

- (void)addGenerator:(id<ANWaveGenerator>)gen {
  [waves addObject:gen];
}

- (void)removeGenerator:(id<ANWaveGenerator>)gen {
  [waves removeObject:gen];
}

- (const Float32 *)buffer {
  return output;
}

#pragma mark - Private -

- (void)_fillForCount:(NSInteger)count {
  for (id<ANWaveGenerator> gen in waves) {
    [gen fillCount:count atOffset:offset];
    vDSP_vadd(&[gen buffer][offset], 1,
              &output[offset], 1,
              &output[offset], 1,
              count);
  }
  
  offset += count;
}

- (void)dealloc {
  free(output);
}

@end
