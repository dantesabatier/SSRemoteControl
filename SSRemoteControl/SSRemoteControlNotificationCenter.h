//
//  SSRemoteControlNotificationCenter.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 05/02/15.
//  Copyright (c) 2015 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlEvent.h"

NS_ASSUME_NONNULL_BEGIN

@class SSRemoteControlNotificationCenter;

@protocol SSRemoteControlNotificationCenterObserver <NSObject>

- (void)remoteControlNotificationCenter:(SSRemoteControlNotificationCenter *)remoteControlNotificationCenter didRecieveEvent:(SSRemoteControlEvent *)event;

@end

@interface SSRemoteControlNotificationCenter : NSObject {
@private
    id _private;
    id _private2;
    SSRemoteControlEventIdentifier _allowedEventIdentifierMask;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
@property (class, nonatomic, readonly, strong) SSRemoteControlNotificationCenter *sharedRemoteControlNotificationCenter __attribute__((const));
@property (nonatomic, assign) SSRemoteControlEventIdentifier allowedEventIdentifierMask;
@property (nullable, nonatomic, readonly, strong) NSArray <id<SSRemoteControlNotificationCenterObserver>>*observers;
- (void)addObserver:(id<SSRemoteControlNotificationCenterObserver>)observer completion:(void (^__nullable)(NSError * __nullable error))completion NS_SWIFT_NAME(add(_:completion:));
- (void)removeObserver:(id<SSRemoteControlNotificationCenterObserver>)observer NS_SWIFT_NAME(remove(_:));

@end

NS_ASSUME_NONNULL_END
