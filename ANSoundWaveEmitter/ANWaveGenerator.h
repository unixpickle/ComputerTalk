//
//  ANWaveGenerator.h
//  ComputerTalk
//
//  Created by Alex Nichol on 4/12/14.
//  Copyright (c) 2014 Alex Nichol. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ANWaveGenerator <NSObject>

- (void)fillCount:(NSInteger)count atOffset:(NSInteger)offset;
- (const Float32 *)buffer;

@end
