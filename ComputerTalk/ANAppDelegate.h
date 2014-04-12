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

@interface ANAppDelegate : NSObject <NSApplicationDelegate> {
  ANSoundWaveEmitter * gen;
}

@property (assign) IBOutlet NSWindow *window;

@end
