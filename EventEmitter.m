//
//  EventEmitter.m
//  NinetyNineCardGame
//
//  Created by Switt Kongdachalert on 12/12/17.
//  Copyright © 2017 Switt's Software. All rights reserved.
//

#import "EventEmitter.h"

@implementation EventEmitter {
    BOOL inEmitLoop;
    
    NSMutableDictionary
    <NSString *,
    NSMutableIndexSet *>*loopRemover;
}
-(id)init {
    eventsDict = [NSMutableDictionary new];
    loopRemover = [NSMutableDictionary new];
    
    return self;
}

-(id)addListener:(NSString *)eventName listener:(EventEmitterListener)listener {
    return [self on:eventName listener:listener];
}
-(id)on:(NSString *)eventName listener:(EventEmitterListener)listener {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    if(!arr) {
        arr = [NSMutableArray new];
        [eventsDict setObject:arr forKey:eventName];
    }
    EventEmitterListenerObject *l = [EventEmitterListenerObject listener:listener once:NO];
    [self emit:@"newListener" arguments:@[listener]];
    [arr addObject:l];
    return self;
}
-(id)once:(NSString *)eventName listener:(EventEmitterListener)listener {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    if(!arr) {
        arr = [NSMutableArray new];
        [eventsDict setObject:arr forKey:eventName];
    }
    EventEmitterListenerObject *l = [EventEmitterListenerObject listener:listener once:YES];
    [self emit:@"newListener" arguments:@[listener]];
    [arr addObject:l];
    return self;
}
-(id)prependListener:(NSString *)eventName listener:(EventEmitterListener)listener {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    if(!arr) {
        arr = [NSMutableArray new];
        [eventsDict setObject:arr forKey:eventName];
    }
    EventEmitterListenerObject *l = [EventEmitterListenerObject listener:listener once:NO];
    [self emit:@"newListener" arguments:@[listener]];
    [arr insertObject:l atIndex:0];
    return self;
}
-(id)prependOnceListener:(NSString *)eventName listener:(EventEmitterListener)listener {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    if(!arr) {
        arr = [NSMutableArray new];
        [eventsDict setObject:arr forKey:eventName];
    }
    EventEmitterListenerObject *l = [EventEmitterListenerObject listener:listener once:YES];
    [self emit:@"newListener" arguments:@[listener]];
    [arr insertObject:l atIndex:0];
    return self;
}

-(id)removeAllListeners:(NSString *)eventName {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    
    if(!arr) return self;
    
    [eventsDict removeObjectForKey:eventName];
    
    for(EventEmitterListenerObject *listener in arr) {
        [self emit:@"removeListener" arguments:@[listener]];
    }
    return self;
}
-(id)removeListener:(NSString *)eventName listener:(EventEmitterListener)listener {
    NSMutableArray <EventEmitterListenerObject *>*arr = eventsDict[eventName];
    
    NSInteger index = 0; BOOL found = NO;
    for(EventEmitterListenerObject *obj in arr) {
        if(obj.listener == listener) {
            found = YES;
            break;
        }
        index++;
    }
    if(found) {
        if(inEmitLoop) {
            [self addToLoopRemoverForEvent:eventName index:index];
            return self;
        }
        
        [arr removeObjectAtIndex:index];
    }
    
    if(![arr count]) {
        [eventsDict removeObjectForKey:eventName];
        NSLog(@"no more listeners for %@", eventName);
    }
    
    [self emit:@"removeListener" arguments:@[listener]];
    return self;
}

-(NSArray <NSString *>*)eventNames {
    return [eventsDict allKeys];
}
-(NSInteger)listenerCount:(NSString *)eventName {
    return [eventsDict[eventName] count];
}
-(NSArray <EventEmitterListener>*)listeners:(NSString *)eventName {
    return [eventsDict[eventName] copy];
}

-(BOOL)emit:(NSString *)eventName arguments:(NSArray *)arguments {
    NSArray <EventEmitterListenerObject *>*listeners = eventsDict[eventName];
    
    if(!listeners) return NO;
    
    inEmitLoop = YES;
    
    NSUInteger index = 0;
    for(EventEmitterListenerObject *listenerObj in listeners) {
        listenerObj.listener(arguments);
        
        if(listenerObj.once) {
            [self addToLoopRemoverForEvent:eventName index:index];
        }
        index++;
    }
    inEmitLoop = NO;
    [self flushLoopRemover];
    
    return YES;
}

-(void)addToLoopRemoverForEvent:(NSString *)event index:(NSUInteger)index
{
    NSMutableIndexSet *set = loopRemover[event];
    if(!set) {
        set = [NSMutableIndexSet new];
        loopRemover[event] = set;
    }
    [set addIndex:index];
}
-(void)flushLoopRemover {
    for(NSString *eventName in [loopRemover allKeys]) {
        NSMutableIndexSet *set = loopRemover[eventName];
        [self removeListeners:eventName indexes:set];
    }
    
    loopRemover = [NSMutableDictionary new];
}

-(void)removeListeners:(NSString *)eventName
               indexes:(NSIndexSet *)indexes
{
    NSMutableArray <EventEmitterListenerObject *>*toNotify = [NSMutableArray new];
    
    NSMutableArray <EventEmitterListenerObject *>*listeners = eventsDict[eventName];
    
    [toNotify addObjectsFromArray:[listeners objectsAtIndexes:indexes]];
    [listeners removeObjectsAtIndexes:indexes];
    if(![listeners count]) {
        [eventsDict removeObjectForKey:eventName];
        NSLog(@"no more listeners for %@", eventName);
    }
    
    for(EventEmitterListenerObject *obj in toNotify) {
        EventEmitterListener listener = obj.listener;
        [self emit:@"removeListener" arguments:@[listener]];
    }
}

@end


@implementation EventEmitterListenerObject
+(EventEmitterListenerObject *)listener:(EventEmitterListener)listener once:(BOOL)once {
    EventEmitterListenerObject *obj = [EventEmitterListenerObject new];
    obj.listener = listener;
    obj.once = once;
    return obj;
}
@end