//
//  ANAppDelegate.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANSoundWaveEmitter.h"
#import "ANSineGenerator.h"
#import "ANSoundWaveReceiver.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate> {
  ANSoundWaveEmitter * gen;
  ANSoundWaveReceiver * rec;
}

@property (assign) IBOutlet NSWindow * window;

@end
