//
// Created by Roman Kříž on 30.04.14.
// Copyright (c) 2014 Touch Art, s.r.o. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface RKCalendarLink : NSObject

/**
 Defines which calendar unit link should track.

 Valid units are only:

	NSCalendarUnitYear,
	NSCalendarUnitMonth,
	NSCalendarUnitDay,
	NSCalendarUnitHour,
	NSCalendarUnitMinute,
	NSCalendarUnitSecond

 For example if you set to NSCalendarUnitMinute, that means every calendar link will fire every minute after change of minute.
 */
@property (nonatomic) NSCalendarUnit calendarUnit;

/**
 Defines how many calendar unit changes must pass between each time the calendar link fires.

 Default value is one, which means the calendar link will fire for every calendar unit change. Setting the interval to
 two will cause the calendar link to fire every other unit change and so on. The behavior when using values less than
 one is undefined.
 */
@property (nonatomic) NSUInteger unitInterval;

@property (nonatomic, readonly, getter=isActive) BOOL active;

@property (nonatomic, readonly, getter=isValid) BOOL valid;

/**
 Creates and schedule calendar link in current NSRunLoop for NSRunLoopCommonModes.
 Same as calling `-initWithCalendarUnit:start:updateBlock:` where start is YES.

 @see property calendarUnit

 @param calendarUnit  tracked calendar unit
 @param updateBlock   block, that will be fired after every specified calendar unit changes
 */
- (nullable instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit updateBlock:(nonnull void (^)())updateBlock;

/**
 Creates calendar link. And schedules in current NSRunLoop if the parameter `start` is set to YES.

 @see property calendarUnit

 @param calendarUnit  tracked calendar unit
 @param start         will start the link right after initialization
 @param updateBlock   block, that will be fired after every specified calendar unit changes
 */
- (nullable instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit start:(BOOL)start updateBlock:(nonnull void (^)())updateBlock;

/**
 When it is more appropriate to start the link later, call this method.
 */
- (void) start;

/**
 Stops the link, it will not fire the `updateBlock` from now. Call -start method for restarting.
 */
- (void) stop;

/**
 Removes the object from all runloop modes and set the reciever to invalidated mode, so you can not use it anymore.
 */
- (void) invalidate;

@end
