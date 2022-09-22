//
//  SSRemoteControlListenerObserver.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 31/12/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlListener.h"
#import "SSRemoteControlDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSRemoteControlListenerObserver : NSObject {
@private
    SSRemoteControlEventIdentifier _identifierMask;
    NSOperationQueue *_queue;
    SSRemoteControlListenerObserverBlock _block;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithIdentifierMask:(SSRemoteControlEventIdentifier)identifierMask queue:(nullable NSOperationQueue *)queue block:(SSRemoteControlListenerObserverBlock)block;
@property (readonly) SSRemoteControlEventIdentifier identifierMask;
@property (readonly, ss_strong) NSOperationQueue *queue;
@property (readonly, copy) SSRemoteControlListenerObserverBlock block;

@end

NS_ASSUME_NONNULL_END
