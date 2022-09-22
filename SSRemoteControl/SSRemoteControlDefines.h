/*
 *  SSRemoteControlDefines.h
 *  SSRemoteControl
 *
 *  Created by Dante Sabatier on 16/03/14.
 *  Copyright 2014 Dante Sabatier. All rights reserved.
 *
 */

#import <TargetConditionals.h>
#import <AvailabilityMacros.h>
#import <Availability.h>
#import <Foundation/NSObjCRuntime.h>
#import <objc/runtime.h>

id objc_getProperty(id self, SEL _cmd, ptrdiff_t offset, BOOL atomic);
void objc_setProperty(id self, SEL _cmd, ptrdiff_t offset, id newValue, BOOL atomic, BOOL shouldCopy);

#ifndef ss_weak
#if (__has_feature(objc_arc)) && ((defined __IPHONE_OS_VERSION_MIN_REQUIRED && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0) || (defined __MAC_OS_X_VERSION_MIN_REQUIRED && __MAC_OS_X_VERSION_MIN_REQUIRED > __MAC_10_7))
#define ss_weak weak
#define __ss_weak __weak
#define ss_strong strong
#else
#define ss_weak unsafe_unretained
#define __ss_weak __unsafe_unretained
#define ss_strong retain
#endif
#endif

#ifndef ss_retain
#if __has_feature(objc_arc)
#define ss_retain self
#define ss_dealloc self
#define release self
#define autorelease self
#else
#define ss_retain retain
#define ss_dealloc dealloc
#define __bridge
#endif
#endif

#ifndef SSAutorelease
#if __has_feature(objc_arc)
#define SSAutorelease(x) (__bridge __typeof(x))CFBridgingRelease(x)
#else
#define SSAutorelease(x) (__typeof(x))[NSMakeCollectable(x) autorelease]
#endif
#endif

#ifndef SSNonAtomicRetainedSet
#define SSNonAtomicRetainedSet(a, b) do {if (![a isEqual:b]){ if (a) { [a release]; a = nil;} if (b) a = [b ss_retain]; }} while (0)
#endif

#ifndef SSNonAtomicCopiedSet
#define SSNonAtomicCopiedSet(a, b) do {if (![a isEqual:b]){ if (a) { [a release]; a = nil;} if (b) a = [b copy]; }} while (0)
#endif

#ifndef SSAtomicRetainedSet
#define SSAtomicRetainedSet(dest, source) objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, NO)
#endif

#ifndef SSAtomicCopiedSet
#define SSAtomicCopiedSet(dest, source) objc_setProperty(self, _cmd, (ptrdiff_t)(&dest) - (ptrdiff_t)(self), source, YES, YES)
#endif

#ifndef SSAtomicAutoreleasedGet
#define SSAtomicAutoreleasedGet(source) objc_getProperty(self, _cmd, (ptrdiff_t)(&source) - (ptrdiff_t)(self), YES)
#endif

#ifndef SSLocalizedString
#define SSLocalizedString(key, comment) [[NSBundle bundleForClass:[self class]] localizedStringForKey:(key) value:@"" table:nil]
#endif
