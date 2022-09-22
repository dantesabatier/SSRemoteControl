//
//  SSRemoteControlEvent.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 30/01/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlEvent.h"

@implementation SSRemoteControlEvent

- (instancetype)initWithIdentifier:(SSRemoteControlEventIdentifier)identifier state:(SSRemoteControlEventIdentifierState)state {
    self = [super init];
    if (self) {
        _identifier = identifier;
        _state = state;
    }
    return self;
}

- (SSRemoteControlEventIdentifier)identifier {
    return _identifier;
}

- (SSRemoteControlEventIdentifierState)state {
    return _state;
}

@end
