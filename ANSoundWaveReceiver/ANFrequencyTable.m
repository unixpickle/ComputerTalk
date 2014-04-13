//
//  ANFrequencyTable.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANFrequencyTable.h"

@implementation ANFrequencyTable

- (id)initWithFFTResult:(DSPSplitComplex)res count:(NSInteger)count {
  if ((self = [super init])) {
    freqTable = (float *)malloc(4 * count);
    valueCount = count;
    
    vDSP_zvmags(&res, 1, freqTable, 1, count);
    
    //int countInt = (int)count;
    //vvsqrtf(freqTable, freqTable, &countInt);
  }
  return self;
}

- (NSInteger)valueCount {
  return valueCount;
}

- (float)amplitudeAtIndex:(NSInteger)index {
  return freqTable[index];
}

- (NSInteger)largestFrequency {
  // TODO: find an accelerated function for this
  float largest = 0;
  NSInteger idx = 0;
  for (NSInteger i = 0; i < valueCount; i++) {
    if (freqTable[i] > largest) {
      largest = freqTable[i];
      idx = i;
    }
  }
  return idx;
}

- (void)dealloc {
  free(freqTable);
}

@end
