//
//  ANAppDelegate.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANAppDelegate.h"
#import "ANXferWindow.h"

@implementation ANAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  [self newXfer:nil];
}

- (IBAction)newXfer:(id)sender {
  ANXferWindow * wind = [[ANXferWindow alloc] initWithWindowNibName:@"ANXferWindow"];
  [wind.window makeKeyAndOrderFront:nil];
}

@end
