//
//  ANSendWindow.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANXfer.h"

@interface ANXferWindow : NSWindowController <NSWindowDelegate> {
  IBOutlet NSTextField * fieldSendFreq;
  IBOutlet NSTextField * fieldRecFreq;
  IBOutlet NSTextField * fieldSendData;
  IBOutlet NSTextField * fieldRecData;
  
  IBOutlet NSButton * buttonStartStop;
  
  UInt8 recByte;
  UInt8 recCount;
  
  ANXfer * xfer;
}

- (IBAction)startStopPressed:(id)sender;
- (IBAction)sendPressed:(id)sender;
- (IBAction)resetReceivePressed:(id)sender;

@end
