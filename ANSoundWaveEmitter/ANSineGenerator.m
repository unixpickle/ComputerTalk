//
//  ANSineGenerator.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANSineGenerator.h"

@implementation ANSineGenerator

- (id)initWithSampleCount:(NSInteger)count rate:(NSInteger)rate frequency:(float)freq {
  if ((self = [super init])) {
    frequency = freq;
    workspace[0] = malloc(4 * count);
    workspace[1] = malloc(4 * count);
    bufferCount = count;
    
    phase = 0;
    frameTime = 1.0 / (float)rate;
  }
  return self;
}

#pragma mark - Time Management -

- (void)fillCount:(NSInteger)count atOffset:(NSInteger)offset {
  float addition = M_PI * 2.0 * frequency * frameTime;
  for (NSInteger i = 0; i < count; i++) {
    workspace[0][i + offset] = phase;
    phase += addition;
  }
  
  // take the sine of every value
  int arrSize = (int)count;
  vvcosf(&workspace[1][offset], &workspace[0][offset], &arrSize);
  
  phase -= 2 * M_PI * floorf(phase / (M_PI * 2.0f));
}

- (const Float32 *)buffer {
  return workspace[1];
}

#pragma mark - Private -

- (void)dealloc {
  free(workspace[0]);
  free(workspace[1]);
}

@end
