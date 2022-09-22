//
//  SSRemoteCommandTarget.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommandTarget.h"

@interface SSRemoteCommandTarget()

@property (nullable, nonatomic, readwrite, copy) SSRemoteCommandHandler handler;

@end

@implementation SSRemoteCommandTarget

- (instancetype)initWithTarget:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        _target = target;
        _action = action;
    }
    return self;
}

- (instancetype)initWithHandler:(SSRemoteCommandHandler)handler {
    self = [super init];
    if (self) {
        self.handler = handler;
    }
    return self;
}

- (void)dealloc {
    _target = nil;
    _action = NULL;
    [_handler release];
    [super ss_dealloc];
}

- (id)target {
    return _target;
}

- (SEL)action {
    return _action;
}

- (SSRemoteCommandHandler)handler {
    return _handler;
}

- (void)setHandler:(SSRemoteCommandHandler)handler {
    SSNonAtomicCopiedSet(_handler, handler);
}

@end
