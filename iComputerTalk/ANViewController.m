//
//  ANViewController.m
//  iComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import "ANViewController.h"

@interface ANViewController (Private)

- (void)_handleBit:(BOOL)flag;

@end

@implementation ANViewController

- (IBAction)startStopPressed:(id)sender {
  if (!xfer) {
    [buttonStartStop setTitle:@"Stop" forState:UIControlStateNormal];
    xfer = [[ANXfer alloc] initWithSampleRate:0x10000
                                     sendFreq:fieldSendFreq.text.floatValue
                                      recFreq:fieldRecFreq.text.floatValue];
    if (!xfer) {
      UIAlertView * av = [[UIAlertView alloc] initWithTitle:@"Invalid settings"
                                                    message:@"Failed to initiate xfer"
                                                   delegate:nil
                                          cancelButtonTitle:nil
                                          otherButtonTitles:@"OK", nil];
      [av show];
      return;
    }
    [xfer start];
    __weak id weakSelf = self;
    xfer.callback = ^(BOOL bit) {
      [weakSelf _handleBit:bit];
    };
  } else {
    [buttonStartStop setTitle:@"Start" forState:UIControlStateNormal];
    [xfer stop];
    xfer = nil;
  }
}

- (IBAction)sendPressed:(id)sender {
  // send the data bit by bit
  NSString * buf = fieldSendData.text;
  for (int i = 0; i < buf.length; i++) {
    char ch = (char)[buf characterAtIndex:i];
    for (int j = 0; j < 8; j++) {
      [xfer sendBit:(ch & (1 << j)) ? YES : NO];
    }
  }
}

- (IBAction)clearPressed:(id)sender {
  recCount = 0;
  recByte = 0;
  fieldRecData.text = @"";
}

#pragma mark - Private -

- (void)_handleBit:(BOOL)flag {
  recByte |= (flag << recCount);
  recCount++;
  if (recCount == 8) {
    fieldRecData.text = [(fieldRecData.text ?: @"") stringByAppendingFormat:@"%c", (char)recByte];
    recCount = 0;
    recByte = 0;
  }
}

@end
