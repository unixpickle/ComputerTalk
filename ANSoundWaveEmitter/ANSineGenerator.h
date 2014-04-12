//
//  ANSineGenerator.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>
#import "ANWaveGenerator.h"

@interface ANSineGenerator : NSObject <ANWaveGenerator> {
  Float32 * workspace[2];
  NSInteger bufferCount;
  
  float phase;
  float frameTime;
  float frequency;
}

- (id)initWithSampleCount:(NSInteger)count rate:(NSInteger)rate frequency:(float)freq;

- (void)fillCount:(NSInteger)count atOffset:(NSInteger)offset;
- (const Float32 *)buffer;

@end
