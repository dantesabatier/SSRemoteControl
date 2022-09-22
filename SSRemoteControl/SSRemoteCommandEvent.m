//
//  SSRemoteCommandEvent.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommandEvent.h"
#import "SSRemoteControlDefines.h"

@implementation SSRemoteCommandEvent

- (instancetype)initWithCommand:(SSRemoteCommand *)command {
    self = [super init];
    if (self) {
        _timestamp = (NSTimeInterval)CFAbsoluteTimeGetCurrent();
        self.command = command;
    }
    return self;
}

- (void)dealloc {
    [_command release];
    [super ss_dealloc];
}

- (SSRemoteCommand *)command {
    return _command;
}

- (void)setCommand:(SSRemoteCommand * _Nonnull)command {
    SSNonAtomicRetainedSet(_command, command);
}

@end
