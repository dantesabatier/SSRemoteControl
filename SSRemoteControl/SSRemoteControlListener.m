//
//  SSRemoteControlListener.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 16/03/14.
//  Copyright (c) 2014 Dante Sabatier. All rights reserved.
//

#import "SSRemoteControlListener.h"
#import "SSRemoteControlListenerObserver.h"
#import <AppKit/NSApplication.h>
#import <Carbon/Carbon.h>
#import <ServiceManagement/ServiceManagement.h>
#import <CoreServices/CoreServices.h>

NSNotificationName SSRemoteControlListenerDidRecieveEventNotification = @"SSRemoteControlListenerDidRecieveEventNotification";

NSString *const SSRemoteControlEventIdentifierKey = @"SSRemoteControlEventIdentifier";
NSString *const SSRemoteControlEventIdentifierStateKey = @"SSRemoteControlEventIdentifierState";

static NSString *const SSRemoteControlMainBundleIdentifierKey = @"SSRemoteControlMainBundleIdentifier";

static NSString *const SSRequestForRemoteControlNotification = @"mac.remotecontrols.RequestForRemoteControl";
static NSString *const SSFinishedUsingRemoteControlNotification = @"mac.remotecontrols.FinishedUsingRemoteControl";

static void SSRemoteControlListenerIOREInterestCallback(void *refcon, io_service_t	service, uint32_t messageType, void *messageArgument);
static void SSRemoteControlListenerQueueCallbackFunction(void* target,  IOReturn result, void* refcon, void* sender);

@interface SSRemoteControlListener ()

@property (copy) NSArray <NSNumber *> *cookies;
@property (copy) void (^completionHandler)(NSError * __nullable error);

@end

@implementation SSRemoteControlListener

static SSRemoteControlListenerSessionState SSRemoteControlListenerGetSessionState() {
    SSRemoteControlListenerSessionState state = SSRemoteControlListenerSessionStateUnknown;
    io_registry_entry_t root = IORegistryGetRootEntry(kIOMasterPortDefault);
    if (root != MACH_PORT_NULL) {
        NSArray *users = (__bridge NSArray <NSDictionary<NSString*, id>*>*)SSAutorelease(IORegistryEntrySearchCFProperty(root, kIOServicePlane, CFSTR("IOConsoleUsers"), NULL, kIORegistryIterateRecursively));
        for (NSDictionary <NSString*, id>*user in users) {
            if ([user[@"kCGSSessionUserNameKey"] isEqualToString:NSUserName()]) {
                state = (user[@"kCGSSessionSecureInputPID"] != nil) ? SSRemoteControlListenerSessionStateIsUp : SSRemoteControlListenerSessionStateUnknown;
                break;
            }
        }
        IOObjectRelease(root);
    }
    return state;
}

static io_object_t SSRemoteControlListenerCreateDevice() {
    io_object_t	device = 0;
	io_iterator_t hidObjectIterator = 0;
    NSString *deviceName = @"AppleIRController";
	CFMutableDictionaryRef hidMatchDictionary = IOServiceMatching(deviceName.UTF8String);
	IOReturn ioReturnValue = IOServiceGetMatchingServices(kIOMasterPortDefault, hidMatchDictionary, &hidObjectIterator);
	if ((ioReturnValue == kIOReturnSuccess) && (hidObjectIterator != 0)) {
		io_object_t matchingService = 0, foundService = 0;
		BOOL finalMatch = NO;
		while ((matchingService = IOIteratorNext(hidObjectIterator))) {
			if (!finalMatch) {
				if (!foundService && (IOObjectRetain(matchingService) == kIOReturnSuccess)) {
                    foundService = matchingService;
				}
				NSString *className = (__bridge NSString *)SSAutorelease(IORegistryEntryCreateCFProperty((io_registry_entry_t)matchingService, CFSTR("IOClass"), kCFAllocatorDefault, 0));
				if ([className isEqualToString:deviceName]) {
                    if (foundService) {
                        IOObjectRelease(foundService);
                        foundService = 0;
                    }
                    if (IOObjectRetain(matchingService) == kIOReturnSuccess) {
                        foundService = matchingService;
                        finalMatch = YES;
                    }
                }
			}
			IOObjectRelease(matchingService);
		}
		device = foundService;
		IOObjectRelease(hidObjectIterator);
	}
	return device;
}

static BOOL sharedRemoteControlListenerCanBeDestroyed = NO;
static SSRemoteControlListener *sharedRemoteControlListener = nil;

+ (instancetype)sharedRemoteControlListener {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedRemoteControlListener = [[self alloc] init];
        __block __unsafe_unretained id observer = [[NSNotificationCenter defaultCenter] addObserverForName:NSApplicationWillTerminateNotification object:NSApp queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
            sharedRemoteControlListenerCanBeDestroyed = YES;
            [sharedRemoteControlListener release];
            [[NSNotificationCenter defaultCenter] removeObserver:observer];
        }];
    });
    
    return sharedRemoteControlListener;
}

+ (BOOL)sharedRemoteControlListenerExists {
    return sharedRemoteControlListener != nil;
}

+ (BOOL)isRemoteControlAvailable {
    io_object_t	device = SSRemoteControlListenerCreateDevice();
    if (device != 0) {
        IOObjectRelease(device);
        return YES;
    }
    return NO;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _mapping = [[NSMutableDictionary alloc] init];
        if (floor(NSAppKitVersionNumber) >= NSAppKitVersionNumber10_2_3) {
            _mapping[@"33_21_20_15_12_2_"] = @(SSRemoteControlEventIdentifierUp);
            _mapping[@"33_31_30_21_20_2_33_31_30_21_20_15_12_2_"] = @(SSRemoteControlEventIdentifierUp);
            _mapping[@"33_21_20_15_12_2_33_21_20_2_"] = @(SSRemoteControlEventIdentifierUp);
            _mapping[@"33_21_20_16_12_2_"] = @(SSRemoteControlEventIdentifierDown);
            _mapping[@"33_32_30_21_20_2_33_32_30_21_20_16_12_2_"] = @(SSRemoteControlEventIdentifierDown);
            _mapping[@"33_21_20_16_12_2_33_21_20_2_"] = @(SSRemoteControlEventIdentifierDown);
        } else {
            _mapping[@"33_31_30_21_20_2_"] = @(SSRemoteControlEventIdentifierUp);
            _mapping[@"33_32_30_21_20_2_"] = @(SSRemoteControlEventIdentifierDown);
        }
        _mapping[@"33_25_21_20_2_33_25_21_20_2_"] = @(SSRemoteControlEventIdentifierLeft);
        _mapping[@"33_24_21_20_2_33_24_21_20_2_"] = @(SSRemoteControlEventIdentifierRight);
        _mapping[@"33_23_21_20_2_33_23_21_20_2_"] = @(SSRemoteControlEventIdentifierPlay);
        _mapping[@"33_21_20_8_2_33_21_20_8_2_"] = @(SSRemoteControlEventIdentifierPlay);
        _mapping[@"33_21_20_3_2_33_21_20_3_2_"] = @(SSRemoteControlEventIdentifierPlay);
		_mapping[@"33_22_21_20_2_33_22_21_20_2_"] = @(SSRemoteControlEventIdentifierMenu);
        _mapping[@"33_21_20_13_12_2_"] = @(SSRemoteControlEventIdentifierLeftHold);
		_mapping[@"33_21_20_14_12_2_"] = @(SSRemoteControlEventIdentifierRightHold);
        _mapping[@"37_33_21_20_2_37_33_21_20_2_"] = @(SSRemoteControlEventIdentifierPlayHold);
        _mapping[@"33_21_20_11_2_33_21_20_11_2_"] = @(SSRemoteControlEventIdentifierPlayHold);
		_mapping[@"33_21_20_2_33_21_20_2_"] = @(SSRemoteControlEventIdentifierMenuHold);
		_mapping[@"19_"] = @(SSRemoteControlEventIdentifierSwitched);
        
        _supportedEventIdentifierMask = 0;
        
        for (NSNumber *number in _mapping.allValues) {
            _supportedEventIdentifierMask |= number.unsignedIntegerValue;
        }
        
        _allowedEventIdentifierMask = _supportedEventIdentifierMask;
        
        io_registry_entry_t root = IORegistryGetRootEntry(kIOMasterPortDefault);
		if (root != MACH_PORT_NULL) {
			_notificationPort = IONotificationPortCreate(kIOMasterPortDefault);
			if (_notificationPort) {
				CFRunLoopSourceRef runLoopSource = IONotificationPortGetRunLoopSource(_notificationPort);
				CFRunLoopRef gRunLoop = CFRunLoopGetCurrent();
				CFRunLoopAddSource(gRunLoop, runLoopSource, kCFRunLoopDefaultMode);
				io_registry_entry_t entry = IORegistryEntryFromPath(kIOMasterPortDefault, kIOServicePlane ":/");
				if (entry != MACH_PORT_NULL) {
					if (IOServiceAddInterestNotification(_notificationPort, entry, kIOBusyInterest, &SSRemoteControlListenerIOREInterestCallback, self, &_eventSecureInputNotification) != KERN_SUCCESS) {
						NSLog(@"%@ %@, error IOServiceAddInterestNotification", self.class, NSStringFromSelector(_cmd));
						IONotificationPortDestroy(_notificationPort);
						_notificationPort = NULL;
					}
					IOObjectRelease(entry);
				}
			}
			IOObjectRelease(root);
		}
        _sessionState = SSRemoteControlListenerGetSessionState();
        _exclusive = YES;
    }
    return self;
}

- (void)dealloc {
    if (self == sharedRemoteControlListener && !sharedRemoteControlListenerCanBeDestroyed) {
        return;
    }
    
    IONotificationPortDestroy(_notificationPort);
	_notificationPort = NULL;
    
	IOObjectRelease(_eventSecureInputNotification);
	_eventSecureInputNotification = MACH_PORT_NULL;
    
    [[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:SSFinishedUsingRemoteControlNotification object:nil];
    
    [self stopListening];
    
    [_completionHandler release];
    [_observers release];
    [_mapping release];
    [_cookies release];
    
    [super ss_dealloc];
}

- (void)startListeningForRemoteControlEventIdentifier:(SSRemoteControlEventIdentifier)identifierMask completionHandler:(SSRemoteControlListenerCompletionBlock)handler {
    if (self.isListening) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    
    io_object_t	device = SSRemoteControlListenerCreateDevice();
    if (device == 0) {
        if (handler) {
            handler(nil);
        }
        return;
    }
    
    io_name_t className;
	if (IOObjectGetClass(device, className) != kIOReturnSuccess) {
        if (handler) {
            handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeFailedToGetClassName userInfo:@{NSLocalizedFailureReasonErrorKey: @"Failed to get class name"}]);
        }
        IOObjectRelease(device);
		return;
	}
	
	SInt32 score = 0;
	IOCFPlugInInterface **plugInInterface = NULL;
	if (IOCreatePlugInInterfaceForService(device, kIOHIDDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &plugInInterface, &score) == kIOReturnSuccess) {
		if ((*plugInInterface)->QueryInterface(plugInInterface, CFUUIDGetUUIDBytes(kIOHIDDeviceInterfaceID), (LPVOID) &_deviceInterface) != S_OK) {
            if (handler) {
                handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeCouldNotCreateClassDevideInterface userInfo:@{NSLocalizedFailureReasonErrorKey: @"Couldn't create HID class device interface"}]);
            }
            if (plugInInterface) {
                (*plugInInterface)->Release(plugInInterface);
            }
            IOObjectRelease(device);
            return;
		}
        if (plugInInterface) {
            (*plugInInterface)->Release(plugInInterface);
        }
	}
    
    IOHIDDeviceInterface122 **handle = (IOHIDDeviceInterface122**)_deviceInterface;
	if (!handle || !(*handle)) {
        if (handler) {
            handler(nil);
        }
        return;
    }
	
	CFArrayRef matchingElements = nil;
	(*handle)->copyMatchingElements(handle, NULL, &matchingElements);
    if (!matchingElements) {
        if (handler) {
            handler(nil);
        }
        IOObjectRelease(device);
        return;
    }
    
    NSArray <NSDictionary<NSString*, id>*>*elements = (__bridge NSArray <NSDictionary<NSString*, id>*>*)SSAutorelease(matchingElements);
	NSMutableArray <NSNumber*>*cookies = [NSMutableArray arrayWithCapacity:elements.count];
    for (NSDictionary<NSString*, id>*element in elements) {
        if (![element[@kIOHIDElementCookieKey] isKindOfClass:[NSNumber class]] || ![element[@kIOHIDElementUsageKey] isKindOfClass:[NSNumber class]] || ![element[@kIOHIDElementUsagePageKey] isKindOfClass:[NSNumber class]]) {
            continue;
        }
        [cookies addObject:@((IOHIDElementCookie)[element[@kIOHIDElementCookieKey] unsignedIntValue])];
    }
    
    self.cookies = cookies;
    self.completionHandler = handler;
    
    _allowedEventIdentifierMask = identifierMask ? identifierMask : SSRemoteControlEventIdentifierMaskAll;
    
    IOReturn ioReturnValue = (*_deviceInterface)->open(_deviceInterface, _exclusive ? kIOHIDOptionsTypeSeizeDevice : kIOHIDOptionsTypeNone);
    if (ioReturnValue != KERN_SUCCESS) {
		if (ioReturnValue == kIOReturnExclusiveAccess) {
            if (handler) {
                handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeDeviceIsBeingUsedInExclusiveModeByAnotherApplication userInfo:@{NSLocalizedFailureReasonErrorKey: SSLocalizedString(@"The device is being used in exclusive mode by another application", @"error reason")}]);
            }
            
            [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedUsingRemoteControl:) name:SSFinishedUsingRemoteControlNotification object:nil];
            [[NSDistributedNotificationCenter defaultCenter] postNotificationName:SSRequestForRemoteControlNotification object:nil userInfo:@{SSRemoteControlMainBundleIdentifierKey : [[NSBundle mainBundle] bundleIdentifier]} deliverImmediately:YES];
        }
        IOObjectRelease(device);
        return;
	}
    
    _queueInterface = (*_deviceInterface)->allocQueue(_deviceInterface);
    
    if (!_queueInterface || (_queueInterface && (*_queueInterface)->create(_queueInterface, 0, 12) != kIOReturnSuccess)) {
        if (handler) {
            handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeCreatingQueue userInfo:@{NSLocalizedFailureReasonErrorKey: @"Error when creating queue"}]);
        }
        IOObjectRelease(device);
        return;
    }
    
    for (NSNumber *cookie in cookies) {
        (*_queueInterface)->addElement(_queueInterface, (IOHIDElementCookie)cookie.unsignedIntValue, 0);
    }
    
    if ((*_queueInterface)->createAsyncEventSource(_queueInterface, &_runLoopSource) != KERN_SUCCESS) {
        if (handler) {
            handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeCreatingAsyncEventSource userInfo:@{NSLocalizedDescriptionKey: @"Error when creating async event source"}]);
        }
        IOObjectRelease(device);
        return;
    }
    
    if ((*_queueInterface)->setEventCallout(_queueInterface, SSRemoteControlListenerQueueCallbackFunction, self, NULL) != KERN_SUCCESS) {
        if (handler) {
            handler([NSError errorWithDomain:SSRemoteControlErrorDomain code:SSRemoteControlErrorCodeSettingEventCallback userInfo:@{NSLocalizedDescriptionKey: @"Error when setting event callback"}]);
        }
        IOObjectRelease(device);
        return;
    }
    
    CFRunLoopAddSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopDefaultMode);
    
    (*_queueInterface)->start(_queueInterface);
    
    IOObjectRelease(device);
    
    if (handler) {
        handler(nil);
    }
}

- (id<NSObject>)addRemoteControlListenerObserverForEventIdentifier:(SSRemoteControlEventIdentifier)identifierMask queue:(nullable NSOperationQueue *)queue usingBlock:(void (^)(SSRemoteControlEventIdentifier identifier, SSRemoteControlEventIdentifierState state))block {
    SSRemoteControlListenerObserver *observer = [[SSRemoteControlListenerObserver alloc] initWithIdentifierMask:identifierMask ? identifierMask : SSRemoteControlEventIdentifierMaskAll queue:queue block:block];
    if (!_observers) {
        _observers = [[NSMutableArray alloc] init];
    }
    [_observers addObject:observer];
    [observer release];
    return _observers.lastObject;
}

- (void)removeRemoteControlListenerObserver:(id<NSObject>)observer {
    [_observers removeObject:observer];
}

- (void)stopListening {
    if (!self.isListening) {
        return;
    }
    
    BOOL sendNotification = NO;
	if (_runLoopSource != NULL) {
		CFRunLoopRemoveSource(CFRunLoopGetCurrent(), _runLoopSource, kCFRunLoopDefaultMode);
		CFRelease(_runLoopSource);
		_runLoopSource = NULL;
	}
    
	if (_queueInterface != NULL) {
		(*_queueInterface)->stop(_queueInterface);
		(*_queueInterface)->dispose(_queueInterface);
		(*_queueInterface)->Release(_queueInterface);
		_queueInterface = NULL;
        sendNotification = YES;
	}
    
    self.cookies = nil;
	
	if (_deviceInterface != NULL) {
		(*_deviceInterface)->close(_deviceInterface);
		(*_deviceInterface)->Release(_deviceInterface);
		_deviceInterface = NULL;
	}
    
    if (_exclusive && sendNotification) {
        [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(finishedUsingRemoteControl:) name:SSFinishedUsingRemoteControlNotification object:nil];
    }
    
    [_observers removeAllObjects];
}

#pragma mark device notifications

- (void)finishedUsingRemoteControl:(NSNotification *)notification {
	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:SSFinishedUsingRemoteControlNotification object:nil];
    
    if (_completionHandler) {
        [self startListeningForRemoteControlEventIdentifier:0 completionHandler:_completionHandler];
    }
}

#pragma mark getters & setters

- (NSArray *)cookies {
    return SSAtomicAutoreleasedGet(_cookies);
}

- (void)setCookies:(NSArray *)cookies {
    SSAtomicCopiedSet(_cookies, cookies);
}

- (SSRemoteControlListenerCompletionBlock)completionHandler {
    return SSAtomicAutoreleasedGet(_completionHandler);
}

- (void)setCompletionHandler:(SSRemoteControlListenerCompletionBlock)completionHandler {
    SSAtomicCopiedSet(_completionHandler, completionHandler);
}

- (BOOL)isExclusive {
    return _exclusive;
}

- (void)setExclusive:(BOOL)exclusive {
    _exclusive = exclusive;
}

- (SSRemoteControlEventIdentifier)supportedEventIdentifierMask {
    return _supportedEventIdentifierMask;
}

- (SSRemoteControlEventIdentifier)allowedEventIdentifierMask {
    return _allowedEventIdentifierMask;
}

- (SSRemoteControlListenerSessionState)sessionState {
    return _sessionState;
}

- (BOOL)isListening {
    return ((_deviceInterface != NULL) && (_cookies != nil) && (_queueInterface != NULL));
}

@end

static void SSRemoteControlListenerIOREInterestCallback(void *refcon, io_service_t	service, uint32_t messageType, void *messageArgument) {
    SSRemoteControlListener *remoteControl = (__bridge SSRemoteControlListener *)refcon;
    if (remoteControl.isListening) {
        NSInteger state = SSRemoteControlListenerGetSessionState();
        if (remoteControl->_sessionState != state) {
            remoteControl->_sessionState = state;
        }
    }
}

static void SSRemoteControlListenerQueueCallbackFunction(void* target,  IOReturn result, void* refcon, void* sender) {
    if (target == NULL) {
		NSLog(@"SSRemoteControlListenerQueueCallbackFunction() Warning!, called with invalid target…");
		return;
	}
    
    @autoreleasepool {
        SSRemoteControlListener *remoteControl = (__bridge SSRemoteControlListener *)target;
        IOHIDQueueInterface **queueInterface = remoteControl->_queueInterface;
        IOHIDEventStruct event;
        AbsoluteTime zeroTime = {0,0};
        NSMutableString *cookie = [NSMutableString string];
        SInt32 sumOfValues = 0;
        while (result == kIOReturnSuccess) {
            result = (*queueInterface)->getNextEvent(queueInterface, &event, zeroTime, 0);
            if ((result == kIOReturnSuccess) && (((int)event.elementCookie) != 5)) {
                sumOfValues += event.value;
                [cookie appendString:[NSString stringWithFormat:@"%u_", event.elementCookie]];
            }
        }
        NSDictionary *mapping = [[remoteControl->_mapping copy] autorelease];
        NSNumber *buttonID = mapping[cookie];
        if (!buttonID) {
            for (NSString *key in mapping.allKeys) {
                NSRange range = [cookie rangeOfString:key];
                if ((range.location != NSNotFound) && (range.location > 0)) {
                    buttonID = mapping[key];
                    break;
                }
            }
        }
        
        if (buttonID) {
            SSRemoteControlEventIdentifier remoteControlEventIdentifier = buttonID.unsignedIntegerValue;
            if ((remoteControl.allowedEventIdentifierMask & remoteControlEventIdentifier) != 0) {
                SSRemoteControlListenerObserverBlock notifyRemoteControlObservers = ^(SSRemoteControlEventIdentifier identifier, SSRemoteControlEventIdentifierState state) {
                    NSArray *observers = [[remoteControl->_observers copy] autorelease];
                    for (SSRemoteControlListenerObserver *observer in observers) {
                        if ((observer.identifierMask & identifier) != 0) {
                            [observer.queue addOperationWithBlock:^{
                                observer.block(identifier, state);
                            }];
                        }
                    }
                    [[NSNotificationCenter defaultCenter] postNotificationName:SSRemoteControlListenerDidRecieveEventNotification object:remoteControl userInfo:@{SSRemoteControlEventIdentifierKey: @(identifier), SSRemoteControlEventIdentifierStateKey : @(state)}];
                };
                
                SSRemoteControlEventIdentifierState remoteControlEventIdentifierState = (sumOfValues > 0) ? SSRemoteControlEventIdentifierStatePressed : SSRemoteControlEventIdentifierStateReleased;
                switch (remoteControlEventIdentifierState) {
                    case SSRemoteControlEventIdentifierStateReleased:
                        switch (remoteControlEventIdentifier) {
                            case SSRemoteControlEventIdentifierMenuHold:
                                notifyRemoteControlObservers(remoteControlEventIdentifier, SSRemoteControlEventIdentifierStatePressed);
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
                
                notifyRemoteControlObservers(remoteControlEventIdentifier, remoteControlEventIdentifierState);
                
                switch (remoteControlEventIdentifierState) {
                    case SSRemoteControlEventIdentifierStatePressed:
                        switch (remoteControlEventIdentifier) {
                            case SSRemoteControlEventIdentifierRight:
                            case SSRemoteControlEventIdentifierLeft:
                            case SSRemoteControlEventIdentifierPlay:
                            case SSRemoteControlEventIdentifierMenu:
                            case SSRemoteControlEventIdentifierPlayHold:
                                notifyRemoteControlObservers(remoteControlEventIdentifier, SSRemoteControlEventIdentifierStateReleased);
                                break;
                            default:
                                break;
                        }
                        break;
                    default:
                        break;
                }
            }
        } else {
            NSLog(@"SSRemoteControlListener, warning! Unable to map cookie %@", cookie);
        }
    }
}
