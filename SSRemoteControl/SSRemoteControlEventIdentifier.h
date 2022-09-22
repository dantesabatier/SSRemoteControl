//
//  SSRemoteControlEventIdentifier.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 30/01/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, SSRemoteControlEventIdentifier) {
    SSRemoteControlEventIdentifierUp = 1UL << 1,
    SSRemoteControlEventIdentifierDown = 1UL << 2,
    SSRemoteControlEventIdentifierLeft = 1UL << 3,
    SSRemoteControlEventIdentifierRight = 1UL << 4,
    SSRemoteControlEventIdentifierPlay = 1UL << 5,
    SSRemoteControlEventIdentifierMenu = 1UL << 6,
    SSRemoteControlEventIdentifierUpHold = 1UL << 7,
    SSRemoteControlEventIdentifierDownHold = 1UL << 8,
    SSRemoteControlEventIdentifierLeftHold = 1UL << 9,
    SSRemoteControlEventIdentifierRightHold = 1UL << 10,
    SSRemoteControlEventIdentifierPlayHold = 1UL << 11,
    SSRemoteControlEventIdentifierMenuHold = 1UL << 12,
    SSRemoteControlEventIdentifierSwitched = 1UL << 13,
    SSRemoteControlEventIdentifierMaskPlayer = (SSRemoteControlEventIdentifierUp|SSRemoteControlEventIdentifierDown|SSRemoteControlEventIdentifierLeft|SSRemoteControlEventIdentifierRight|SSRemoteControlEventIdentifierPlay),
    SSRemoteControlEventIdentifierMaskCommon = (SSRemoteControlEventIdentifierUp|SSRemoteControlEventIdentifierDown|SSRemoteControlEventIdentifierLeft|SSRemoteControlEventIdentifierRight|SSRemoteControlEventIdentifierPlay|SSRemoteControlEventIdentifierMenu),
    SSRemoteControlEventIdentifierMaskAll = (SSRemoteControlEventIdentifierUp|SSRemoteControlEventIdentifierDown|SSRemoteControlEventIdentifierLeft|SSRemoteControlEventIdentifierRight|SSRemoteControlEventIdentifierPlay|SSRemoteControlEventIdentifierMenu|SSRemoteControlEventIdentifierUpHold|SSRemoteControlEventIdentifierDownHold|SSRemoteControlEventIdentifierLeftHold|SSRemoteControlEventIdentifierRightHold|SSRemoteControlEventIdentifierPlayHold|SSRemoteControlEventIdentifierMenuHold|SSRemoteControlEventIdentifierSwitched)
} NS_SWIFT_NAME(SSRemoteControlEvent.Identifier);

typedef NS_ENUM(NSInteger, SSRemoteControlEventIdentifierState) {
    SSRemoteControlEventIdentifierStatePressed,
    SSRemoteControlEventIdentifierStateReleased
} NS_SWIFT_NAME(SSRemoteControlEvent.IdentifierState);

