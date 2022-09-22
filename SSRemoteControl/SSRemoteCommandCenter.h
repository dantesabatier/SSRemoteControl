//
//  SSRemoteCommandCenter.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommand.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSRemoteCommandCenter : NSObject {
@private
    SSRemoteCommand *_togglePlayPauseCommand;
    SSRemoteCommand *_nextTrackCommand;
    SSRemoteCommand *_previousTrackCommand;
    SSRemoteCommand *_volumeUpCommand;
    SSRemoteCommand *_volumeDownCommand;
    SSRemoteCommand *_seekBackwardCommand;
    SSRemoteCommand *_seekForwardCommand;
}

- (instancetype)init __attribute__((unavailable));
+ (instancetype)new __attribute__((unavailable));
@property (class, nonatomic, readonly, strong) SSRemoteCommandCenter *sharedCommandCenter __attribute__((const));
@property (nonatomic, readonly) SSRemoteCommand *togglePlayPauseCommand;
@property (nonatomic, readonly) SSRemoteCommand *nextTrackCommand;
@property (nonatomic, readonly) SSRemoteCommand *previousTrackCommand;
@property (nonatomic, readonly) SSRemoteCommand *volumeUpCommand;
@property (nonatomic, readonly) SSRemoteCommand *volumeDownCommand;
@property (nonatomic, readonly) SSRemoteCommand *seekBackwardCommand;
@property (nonatomic, readonly) SSRemoteCommand *seekForwardCommand;

@end

NS_ASSUME_NONNULL_END
