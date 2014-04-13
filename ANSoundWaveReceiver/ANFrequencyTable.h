//
//  ANFrequencyTable.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Accelerate/Accelerate.h>

@interface ANFrequencyTable : NSObject {
  float * freqTable;
  NSInteger valueCount;
}

- (id)initWithFFTResult:(DSPSplitComplex)res count:(NSInteger)count;

- (NSInteger)valueCount;
- (float)amplitudeAtIndex:(NSInteger)index;
- (NSInteger)largestFrequency;

@end
