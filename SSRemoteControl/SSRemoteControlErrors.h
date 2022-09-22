//
//  SSRemoteControlErrors.h
//  SSRemoteControl
//
//  Created by Dante Sabatier on 07/01/19.
//  Copyright © 2019 Dante Sabatier. All rights reserved.
//

#import <Foundation/NSObject.h>
#import <Foundation/NSError.h>

/*!
 @const SSRemoteControlErrorDomain
 @discussion NSError domain for the framework.
 */

extern NSErrorDomain SSRemoteControlErrorDomain;

/*!
 @typedef SSRemoteControlErrorCode
 @discussion NSError codes in <code>SSRemoteControlErrorDomain</code>.
 @field SSRemoteControlErrorCodeFailedToGetClassName Failed to get class name.
 @field SSRemoteControlErrorCodeCouldNotCreateClassDevideInterface Couldn't create HID class device interface.
 @field SSRemoteControlErrorCodeCreatingQueue Error when creating queue.
 @field SSRemoteControlErrorCodeCreatingAsyncEventSource Error when creating async event source.
 @field SSRemoteControlErrorCodeSettingEventCallback Error when setting event callback.
 @field SSRemoteControlErrorCodeDeviceIsBeingUsedInExclusiveModeByAnotherApplication The device is being used in exclusive mode by another application
 */

typedef NS_ERROR_ENUM(SSRemoteControlErrorDomain, SSRemoteControlErrorCode) {
    SSRemoteControlErrorCodeFailedToGetClassName = 5463,
    SSRemoteControlErrorCodeCouldNotCreateClassDevideInterface = 5464,
    SSRemoteControlErrorCodeCreatingQueue = 5465,
    SSRemoteControlErrorCodeCreatingAsyncEventSource = 5466,
    SSRemoteControlErrorCodeSettingEventCallback = 5467,
    SSRemoteControlErrorCodeDeviceIsBeingUsedInExclusiveModeByAnotherApplication = 5468
};
