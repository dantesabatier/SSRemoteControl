//
//  SSRemoteControlNotificationCenter.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 05/02/15.
//  Copyright (c) 2015 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlNotificationCenter.h"
#import "SSRemoteControlDefines.h"
#import "SSRemoteControlListener.h"
#import <AppKit/NSApplication.h>

@interface SSRemoteControlEvent(SSRemoteControlNotificationCenterAdditions)

- (instancetype)initWithIdentifier:(SSRemoteControlEventIdentifier)identifier state:(SSRemoteControlEventIdentifierState)state;

@end

@implementation SSRemoteControlNotificationCenter

static BOOL sharedRemoteControlNotificationCenterCanBeDestroyed = NO;
static SSRemoteControlNotificationCenter *sharedRemoteControlNotificationCenter = nil;

+ (instancetype)sharedRemoteControlNotificationCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRemoteControlNotificationCenter = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            sharedRemoteControlNotificationCenterCanBeDestroyed = YES;
            [sharedRemoteControlNotificationCenter release];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
    return sharedRemoteControlNotificationCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _allowedEventIdentifierMask = SSRemoteControlEventIdentifierMaskAll;
    }
    return self;
}

- (void)dealloc {
    if ((self == sharedRemoteControlNotificationCenter) && !sharedRemoteControlNotificationCenterCanBeDestroyed) {
        return;
    }
    
    NSArray <SSRemoteControlNotificationCenterObserver>*observers = [[_private copy] autorelease];
    for (id <SSRemoteControlNotificationCenterObserver> observer in observers) {
        [self removeObserver:observer];
    }
    
    [_private release];
    [_private2 release];
    
    [super ss_dealloc];
}

#pragma mark SSRemoteControlNotificationCenter

- (void)addObserver:(id<SSRemoteControlNotificationCenterObserver>)observer completion:(void (^__nullable)(NSError * __nullable error))completion {
    if (![SSRemoteControlListener isRemoteControlAvailable]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    if ([_private containsObject:observer]) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    if (!_private) {
        _private = [[NSMutableArray alloc] init];
    }
    
    [_private addObject:observer];
    
    SSRemoteControlListener *remoteControlListener = [SSRemoteControlListener sharedRemoteControlListener];
    if (remoteControlListener.isListening) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [remoteControlListener startListeningForRemoteControlEventIdentifier:_allowedEventIdentifierMask completionHandler:^(NSError * _Nullable error) {
        if (completion) {
            completion(error);
        }
        
        if (!error) {
            _private2 = [[remoteControlListener addRemoteControlListenerObserverForEventIdentifier:_allowedEventIdentifierMask queue:nil usingBlock:^(SSRemoteControlEventIdentifier identifier, SSRemoteControlEventIdentifierState state) {
                NSArray <SSRemoteControlNotificationCenterObserver>*observers = [[_private copy] autorelease];
                for (id <SSRemoteControlNotificationCenterObserver> observer in observers) {
                    SSRemoteControlEvent *event = [[SSRemoteControlEvent alloc] initWithIdentifier:identifier state:state];
                    [observer remoteControlNotificationCenter:self didRecieveEvent:event];
                    [event release];
                }
            }] ss_retain];
        }
    }];
}

- (void)removeObserver:(id<SSRemoteControlNotificationCenterObserver>)observer {
    if (![_private containsObject:observer]) {
        return;
    }
    
    [_private removeObject:observer];
    
    if (![_private count] && [SSRemoteControlListener sharedRemoteControlListenerExists]) {
        SSRemoteControlListener *remoteControlListener = [SSRemoteControlListener sharedRemoteControlListener];
        if (remoteControlListener.isListening) {
           [remoteControlListener removeRemoteControlListenerObserver:_private2];
            [remoteControlListener stopListening];
        }
    }
}

#pragma mark getters & setters

- (NSArray <id<SSRemoteControlNotificationCenterObserver>>*)observers {
    return _private;
}

- (SSRemoteControlEventIdentifier)allowedEventIdentifierMask {
    return _allowedEventIdentifierMask;
}

- (void)setAllowedEventIdentifierMask:(SSRemoteControlEventIdentifier)allowedEventIdentifierMask {
    _allowedEventIdentifierMask = allowedEventIdentifierMask;
}

@end
