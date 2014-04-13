//
//  ANAppDelegate.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  // Insert code here to initialize your application
  gen = [[ANSoundWaveEmitter alloc] initWithSampleRate:44100 bufferTime:0.1];
  [gen start];
  //[gen addWave:500];
  
  rec = [[ANSoundWaveReceiver alloc] initWithSampleRate:44100];
  rec.callback = ^(ANFrequencyTable * table) {
    float scale = 44100.0 / (float)table.valueCount;
    NSLog(@"highest freq divide is %f", scale * (float)[table largestFrequency]);
  };
  [rec start];
}

@end
