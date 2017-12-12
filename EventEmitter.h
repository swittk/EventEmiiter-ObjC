//
//  EventEmitter.h
//  NinetyNineCardGame
//
//  Created by Switt Kongdachalert on 12/12/17.
//  Copyright © 2017 Switt's Software. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 * Event: 'newListener'
 *  - emitted before a listener is added to its internal array of listeners
 * Event: 'removeListener'
 *  - emitted after the listener is removed
 */

typedef void (^EventEmitterListener)(NSArray* arguments);
@interface EventEmitterListenerObject : NSObject
@property (copy) EventEmitterListener listener;
@property (assign) BOOL once;
+(EventEmitterListenerObject *)listener:(EventEmitterListener)listener once:(BOOL)once;
@end


@interface EventEmitter : NSObject {
    NSMutableDictionary
    <NSString *, NSMutableArray <EventEmitterListenerObject *>*>*eventsDict;
}
//@property (readonly) NSInteger defaultMaxListeners;
//@property (assign, nonnull) NSInteger maxListeners;

/**
 * Alias for emitter.on(eventName, listener)
 * Returns a reference to the EventEmitter, so that calls can be chained.
 */
-(id)addListener:(NSString *)eventName listener:(EventEmitterListener)listener;
-(BOOL)emit:(NSString *)eventName arguments:(NSArray *)arguments;

///Returns a reference to the EventEmitter, so that calls can be chained.
-(id)on:(NSString *)eventName listener:(EventEmitterListener)listener;

///Returns a reference to the EventEmitter, so that calls can be chained.
-(id)once:(NSString *)eventName listener:(EventEmitterListener)listener;


/**
 * Adds the listener function to the beginning of the listeners array for the event named
 * eventName
 * Returns a reference to the EventEmitter, so that calls can be chained
 */
-(id)prependListener:(NSString *)eventName listener:(EventEmitterListener)listener;

-(id)prependOnceListener:(NSString *)eventName listener:(EventEmitterListener)listener;

-(id)removeAllListeners:(NSString *)eventName;

/**
 * Removes the specified listener from the listener array for the event named eventName
 */
-(id)removeListener:(NSString *)eventName listener:(EventEmitterListener)listener;


///Returns an array listing the events for which the emitter has registered listeners. The values in the array will be strings
-(NSArray <NSString *>*)eventNames;

///Returns the number of listeners listening to the event named eventName
-(NSInteger)listenerCount:(NSString *)eventName;

///Returns a copy of the array of listeners for the event named eventName
-(NSArray <EventEmitterListener>*)listeners:(NSString *)eventName;
@end
