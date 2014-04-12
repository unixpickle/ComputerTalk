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
  gen = [[ANSoundWaveEmitter alloc] initWithSampleRate:44100 bufferTime:0.5];
  [gen start];
  [gen addWave:1000];
  [gen addWave:2000];
}

@end
