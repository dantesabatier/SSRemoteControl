//
//  SSRemoteCommandCenter.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommandCenter.h"
#import "SSRemoteControlDefines.h"
#import "SSRemoteControlNotificationCenter.h"
#import "SSRemoteCommandTarget.h"
#import "SSRemoteCommandEvent.h"
#import <AppKit/NSApplication.h>

@interface SSRemoteCommand(SSRemoteCommandCenterAdditions)

@property (nonatomic, readonly) NSArray <SSRemoteCommandTarget*>*targets;

@end

@interface SSRemoteCommandEvent(SSRemoteCommandCenterAdditions)

- (instancetype)initWithCommand:(SSRemoteCommand *)command;

@end

@interface SSRemoteCommandCenter () <SSRemoteControlNotificationCenterObserver>

@end

@implementation SSRemoteCommandCenter

static BOOL sharedRemoteCommandCenterCanBeDestroyed = NO;
static SSRemoteCommandCenter *sharedCommandCenter = nil;

+ (instancetype)sharedCommandCenter {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedCommandCenter = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            sharedRemoteCommandCenterCanBeDestroyed = YES;
            [sharedCommandCenter release];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
    return sharedCommandCenter;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _togglePlayPauseCommand = [[SSRemoteCommand alloc] init];
        _nextTrackCommand = [[SSRemoteCommand alloc] init];
        _previousTrackCommand = [[SSRemoteCommand alloc] init];
        _volumeUpCommand = [[SSRemoteCommand alloc] init];
        _volumeDownCommand = [[SSRemoteCommand alloc] init];
        _seekBackwardCommand = [[SSRemoteCommand alloc] init];
        _seekForwardCommand = [[SSRemoteCommand alloc] init];
        
        SSRemoteControlNotificationCenter.sharedRemoteControlNotificationCenter.allowedEventIdentifierMask = SSRemoteControlEventIdentifierMaskPlayer;
        [SSRemoteControlNotificationCenter.sharedRemoteControlNotificationCenter addObserver:self completion:nil];
    }
    return self;
}

- (void)dealloc {
    if ((self == sharedCommandCenter) && !sharedRemoteCommandCenterCanBeDestroyed) {
        return;
    }
    
    [SSRemoteControlNotificationCenter.sharedRemoteControlNotificationCenter removeObserver:self];
    
    [_togglePlayPauseCommand release];
    [_nextTrackCommand release];
    [_previousTrackCommand release];
    [_volumeUpCommand release];
    [_volumeDownCommand release];
    [_seekBackwardCommand release];
    [_seekForwardCommand release];
    [super ss_dealloc];
}

- (void)remoteControlNotificationCenter:(nonnull SSRemoteControlNotificationCenter *)remoteControlNotificationCenter didRecieveEvent:(nonnull SSRemoteControlEvent *)event {
    switch (event.state) {
        case SSRemoteControlEventIdentifierStatePressed: {
            SSRemoteCommand *command = nil;
            switch (event.identifier) {
                case SSRemoteControlEventIdentifierUp:
                    command = _volumeUpCommand;
                    break;
                case SSRemoteControlEventIdentifierDown:
                    command = _volumeDownCommand;
                    break;
                case SSRemoteControlEventIdentifierPlay:
                    command = _togglePlayPauseCommand;
                    break;
                case SSRemoteControlEventIdentifierRight:
                    command = _nextTrackCommand;
                    break;
                case SSRemoteControlEventIdentifierLeft:
                    command = _previousTrackCommand;
                    break;
                case SSRemoteControlEventIdentifierRightHold:
                    command = _seekForwardCommand;
                    break;
                case SSRemoteControlEventIdentifierLeftHold:
                    command = _seekBackwardCommand;
                    break;
                default:
                    break;
            }
            
            if (!command.isEnabled) {
                return;
            }
            
            for (SSRemoteCommandTarget *target in command.targets) {
                SSRemoteCommandHandlerStatus status = SSRemoteCommandHandlerStatusSuccess;
                SSRemoteCommandEvent *event = [[SSRemoteCommandEvent alloc] initWithCommand:command];
                if (target.handler) {
                    status = target.handler(event);
                } else if (target.target && target.action) {
                    status = (SSRemoteCommandHandlerStatus)[target.target performSelector:target.action withObject:event];
                }
                //TODO: Do something with the status
                switch (status) {
                    case SSRemoteCommandHandlerStatusSuccess:
                        break;
                    case SSRemoteCommandHandlerStatusCommandFailed:
                        break;
                    default:
                        break;
                }
                [event autorelease];
            }
        }
            break;
        default:
            break;
    }
}

- (SSRemoteCommand *)togglePlayPauseCommand {
    return _togglePlayPauseCommand;
}

- (SSRemoteCommand *)nextTrackCommand {
    return _nextTrackCommand;
}

- (SSRemoteCommand *)previousTrackCommand {
    return _previousTrackCommand;
}

- (SSRemoteCommand *)volumeUpCommand {
    return _volumeUpCommand;
}

- (SSRemoteCommand *)volumeDownCommand {
    return _volumeDownCommand;
}

- (SSRemoteCommand *)seekBackwardCommand {
    return _seekBackwardCommand;
}

- (SSRemoteCommand *)seekForwardCommand {
    return _seekForwardCommand;
}

@end
