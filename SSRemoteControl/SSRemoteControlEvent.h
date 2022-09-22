//
//  SSRemoteControlEvent.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 30/01/17.
//  Copyright © 2017 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlEventIdentifier.h"

@interface SSRemoteControlEvent : NSObject {
@private
    SSRemoteControlEventIdentifier _identifier;
    SSRemoteControlEventIdentifierState _state;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
@property (nonatomic, readonly, assign) SSRemoteControlEventIdentifier identifier;
@property (nonatomic, readonly, assign) SSRemoteControlEventIdentifierState state;

@end
