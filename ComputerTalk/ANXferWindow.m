//
//  ANSendWindow.m
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANXferWindow.h"

@interface ANXferWindow (Private)

- (void)_handleBit:(BOOL)flag;

@end

static NSMutableArray * xferWindows = nil;

@implementation ANXferWindow

- (void)loadWindow {
  if (!xferWindows) {
    xferWindows = [[NSMutableArray alloc] init];
  }
  [xferWindows addObject:self];
  [super loadWindow];
  self.window.delegate = self;
}

- (void)windowWillClose:(NSNotification *)note {
  [xferWindows removeObject:self];
}

- (IBAction)startStopPressed:(id)sender {
  if (!xfer) {
    buttonStartStop.title = @"Stop";
    xfer = [[ANXfer alloc] initWithSampleRate:0x10000
                                     sendFreq:fieldSendFreq.floatValue
                                      recFreq:fieldRecFreq.floatValue];
    [xfer start];
    __weak id weakSelf = self;
    xfer.callback = ^(BOOL bit) {
      [weakSelf _handleBit:bit];
    };
  } else {
    buttonStartStop.title = @"Start";
    [xfer stop];
    xfer = nil;
  }
}

- (IBAction)sendPressed:(id)sender {
  // send the data bit by bit
  NSString * buf = fieldSendData.stringValue;
  for (int i = 0; i < buf.length; i++) {
    char ch = (char)[buf characterAtIndex:i];
    for (int j = 0; j < 8; j++) {
      [xfer sendBit:(ch & (1 << j)) ? YES : NO];
    }
  }
}

- (IBAction)resetReceivePressed:(id)sender {
  recCount = 0;
  recByte = 0;
  fieldRecData.stringValue = @"";
}

#pragma mark - Private -

- (void)_handleBit:(BOOL)flag {
  recByte |= (flag << recCount);
  recCount++;
  if (recCount == 8) {
    fieldRecData.stringValue = [(fieldRecData.stringValue ?: @"") stringByAppendingFormat:@"%c", (char)recByte];
    recCount = 0;
    recByte = 0;
  }
}

@end
