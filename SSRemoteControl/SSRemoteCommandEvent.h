//
//  SSRemoteCommandEvent.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSRemoteCommand;

@interface SSRemoteCommandEvent : NSObject {
@private
    SSRemoteCommand *_command;
    NSTimeInterval _timestamp;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
@property (nonatomic, readonly) SSRemoteCommand *command;
@property (nonatomic, readonly) NSTimeInterval timestamp;

@end

NS_ASSUME_NONNULL_END
