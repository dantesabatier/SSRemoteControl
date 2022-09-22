//
//  SSRemoteCommand.m
//  SSRemoteControl
//
//  Created by Dante Sabatier on 29/03/18.
//  Copyright © 2018 Dante Sabatier. All rights reserved.
//

#import "SSRemoteCommand.h"
#import "SSRemoteCommandTarget.h"

@implementation SSRemoteCommand

- (instancetype)init {
    self = [super init];
    if (self) {
        _reserved = [[NSMutableArray alloc] init];
        _enabled = YES;
    }
    return self;
}

- (void)dealloc {
    [_reserved removeAllObjects];
    [_reserved release];
    [super ss_dealloc];
}

- (void)addTarget:(id)target action:(SEL)action {
    [(NSMutableArray <SSRemoteCommandTarget*>*)_reserved addObject:[[[SSRemoteCommandTarget alloc] initWithTarget:target action:action] autorelease]];
}

- (void)removeTarget:(id)target action:(SEL)action {
    [(NSMutableArray <SSRemoteCommandTarget*>*)_reserved removeObject:[((NSArray <SSRemoteCommandTarget*>*)_reserved) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SSRemoteCommandTarget *_Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.target == target && evaluatedObject.action == action;
    }]].firstObject];
}

- (void)removeTarget:(id)target {
    [(NSMutableArray <SSRemoteCommandTarget*>*)_reserved removeObjectsInArray:[((NSArray <SSRemoteCommandTarget*>*)_reserved) filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SSRemoteCommandTarget *_Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return evaluatedObject.target == target;
    }]]];
}

- (id<NSObject>)addTargetWithHandler:(SSRemoteCommandHandler)handler {
    SSRemoteCommandTarget *commandTarget = [[SSRemoteCommandTarget alloc] initWithHandler:handler];
    [(NSMutableArray <SSRemoteCommandTarget*>*)_reserved addObject:commandTarget];
    [commandTarget release];
    return ((NSArray <SSRemoteCommandTarget*>*)_reserved).lastObject;
}

- (BOOL)isEnabled {
    return _enabled;
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
}

- (NSArray <SSRemoteCommandTarget*>*)targets {
    return ((NSArray <SSRemoteCommandTarget*>*)_reserved);
}

@end
