//
//  SSRemoteCommand.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommandEvent.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSRemoteCommandHandlerStatus) {
    SSRemoteCommandHandlerStatusSuccess = 0,
    SSRemoteCommandHandlerStatusCommandFailed = 200
};

typedef SSRemoteCommandHandlerStatus(^SSRemoteCommandHandler)(SSRemoteCommandEvent *event);

@interface SSRemoteCommand : NSObject {
@private
    id _reserved;
    BOOL _enabled;
}

@property (nonatomic, assign, getter = isEnabled) BOOL enabled;
- (void)addTarget:(id)target action:(SEL)action;
- (void)removeTarget:(id)target action:(nullable SEL)action;
- (void)removeTarget:(nullable id)target;
- (id<NSObject>)addTargetWithHandler:(SSRemoteCommandHandler)handler;

@end

NS_ASSUME_NONNULL_END
