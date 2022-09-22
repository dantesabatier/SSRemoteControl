//
//  SSRemoteControlListener.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 16/03/14.
//  Copyright (c) 2014 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/hid/IOHIDLib.h>
#import "SSRemoteControlErrors.h"
#import "SSRemoteControlEventIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSRemoteControlListenerSessionState) {
    SSRemoteControlListenerSessionStateUnknown,
    SSRemoteControlListenerSessionStateIsUp
} NS_SWIFT_NAME(SSRemoteControlListener.SessionState);

typedef void (^SSRemoteControlListenerCompletionBlock)(NSError * __nullable error);
typedef void (^SSRemoteControlListenerObserverBlock)(SSRemoteControlEventIdentifier identifier, SSRemoteControlEventIdentifierState state);

NS_CLASS_AVAILABLE_MAC(10_6)
@interface SSRemoteControlListener : NSObject {
@package
    CFRunLoopSourceRef _runLoopSource;
    io_object_t _eventSecureInputNotification;
    IONotificationPortRef _notificationPort;
    IOHIDDeviceInterface **_deviceInterface;
    IOHIDQueueInterface **_queueInterface;
    NSMutableDictionary <NSString*, NSNumber*>*_mapping;
    NSArray <NSNumber*>*_cookies;
    NSMutableArray *_observers;
    SSRemoteControlListenerCompletionBlock _completionHandler;
    SSRemoteControlEventIdentifier _supportedEventIdentifierMask;
    SSRemoteControlEventIdentifier _allowedEventIdentifierMask;
    SSRemoteControlListenerSessionState _sessionState;
    BOOL _exclusive;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
@property (class, readonly, assign) BOOL isRemoteControlAvailable;
@property (class, readonly, assign) BOOL sharedRemoteControlListenerExists __attribute__((const));
@property (class, readonly, strong) SSRemoteControlListener *sharedRemoteControlListener __attribute__((const));
@property (assign, readonly) SSRemoteControlEventIdentifier allowedEventIdentifierMask;
@property (assign, readonly) SSRemoteControlEventIdentifier supportedEventIdentifierMask;
@property (assign, readonly) SSRemoteControlListenerSessionState sessionState;
@property (assign, readonly, getter = isListening) BOOL listening;
@property (assign, getter = isExclusive) BOOL exclusive;
#if NS_BLOCKS_AVAILABLE
- (void)startListeningForRemoteControlEventIdentifier:(SSRemoteControlEventIdentifier)identifierMask completionHandler:(SSRemoteControlListenerCompletionBlock)handler;
- (id<NSObject>)addRemoteControlListenerObserverForEventIdentifier:(SSRemoteControlEventIdentifier)identifierMask queue:(nullable NSOperationQueue *)queue usingBlock:(SSRemoteControlListenerObserverBlock)block;
#endif
- (void)removeRemoteControlListenerObserver:(id<NSObject>)observer;
- (void)stopListening;

@end

//notification names
extern NSNotificationName SSRemoteControlListenerDidRecieveEventNotification;

//notification userfInfo keys
extern NSString *const SSRemoteControlEventIdentifierKey;
extern NSString *const SSRemoteControlEventIdentifierStateKey;

NS_ASSUME_NONNULL_END
