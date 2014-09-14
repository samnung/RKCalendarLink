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

/**
 Creates and schedule calendar link in current NSRunLoop for NSRunLoopCommonModes.

 @see property calendarUnit

 @param calendarUnit  tracked calendar unit
 @param updateBlock  block, that will be fired after every specified calendar unit changes
 */
- (instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit updateBlock:(void (^)())updateBlock;

@end
