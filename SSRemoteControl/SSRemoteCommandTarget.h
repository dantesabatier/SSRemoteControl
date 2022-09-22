//
//  SSRemoteCommandTarget.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SSRemoteCommand.h"
#import "SSRemoteControlDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSRemoteCommandTarget : NSObject {
@private
    __ss_weak id _target;
    SEL _action;
    SSRemoteCommandHandler _handler;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
- (instancetype)initWithTarget:(id)target action:(SEL)action;
- (instancetype)initWithHandler:(SSRemoteCommandHandler)handler;
@property (nullable, nonatomic, readonly, ss_weak) id target;
@property (nullable, nonatomic, readonly) SEL action;
@property (nullable, nonatomic, readonly, copy) SSRemoteCommandHandler handler;

@end

NS_ASSUME_NONNULL_END
