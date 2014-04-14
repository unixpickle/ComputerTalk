//
//  ANViewController.h
//  iComputerTalk
//
//  Created by Alex Nichol on 4/13/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ANXfer.h"

@interface ANViewController : UIViewController {
  IBOutlet UITextField * fieldSendData;
  IBOutlet UITextField * fieldSendFreq;
  IBOutlet UITextField * fieldRecData;
  IBOutlet UITextField * fieldRecFreq;
  IBOutlet UIButton * buttonStartStop;
  
  UInt8 recByte;
  UInt8 recCount;
  
  ANXfer * xfer;
}

- (IBAction)startStopPressed:(id)sender;
- (IBAction)sendPressed:(id)sender;
- (IBAction)clearPressed:(id)sender;

@end
