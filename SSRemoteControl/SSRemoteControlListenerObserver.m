//
//  SSRemoteControlListenerObserver.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 31/12/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlListenerObserver.h"

@implementation SSRemoteControlListenerObserver

- (instancetype)initWithIdentifierMask:(SSRemoteControlEventIdentifier)identifierMask queue:(nullable NSOperationQueue *)queue block:(SSRemoteControlListenerObserverBlock)block {
    self = [super init];
    if (self) {
        self.identifierMask = identifierMask;
        self.queue = queue;
        self.block = block;
    }
    return self;
}

- (void)dealloc {
    [_queue release];
    [_block release];
    
    [super ss_dealloc];
}

- (NSOperationQueue *)queue {
    if (!_queue) {
        return [NSOperationQueue mainQueue];
    }
    return SSAtomicAutoreleasedGet(_queue);
}

- (void)setQueue:(NSOperationQueue *)queue {
    SSAtomicRetainedSet(_queue, queue);
}

- (SSRemoteControlListenerObserverBlock)block {
    return SSAtomicAutoreleasedGet(_block);
}

- (void)setBlock:(SSRemoteControlListenerObserverBlock)block {
    SSAtomicCopiedSet(_block, block);
}

- (SSRemoteControlEventIdentifier)identifierMask {
    return _identifierMask;
}

- (void)setIdentifierMask:(SSRemoteControlEventIdentifier)identifierMask {
    _identifierMask = identifierMask;
}

@end
