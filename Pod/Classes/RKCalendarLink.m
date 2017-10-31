//
// Created by Roman Kříž on 30.04.14.
// Copyright (c) 2014 Touch Art, s.r.o. All rights reserved.
//

#import "RKCalendarLink.h"

@interface RKWeakTimerTarget: NSObject
@end

@implementation RKWeakTimerTarget

{
    __weak id _target;
    SEL _selector;
}

- (instancetype) initWithTarget:(id)target selector:(SEL)selector
{
    self = [super init];
    if ( self )
    {
        _target = target;
        _selector = selector;
    }
    return self;
}

- (void) timerDidFire:(NSTimer *)timer
{
    if ( _target )
    {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [_target performSelector:_selector withObject:timer];
#pragma clang diagnostic pop
    }
    else
    {
        [timer invalidate];
    }
}

@end


@interface RKCalendarLink ()

@property (nonatomic, nullable) NSTimer *timer;
@property (nonatomic, nullable) RKWeakTimerTarget *timerTarget;
@property (nonatomic) BOOL invalidated;
@property (nonatomic, nonnull, copy) void (^ updateBlock)();

@end


@implementation RKCalendarLink

- (instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit updateBlock:(void (^)())updateBlock
{
    return [self initWithCalendarUnit:calendarUnit start:YES updateBlock:updateBlock];
}

- (instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit start:(BOOL)start updateBlock:(void (^)())updateBlock
{
	// updateBlock is required, otherwise it doesn't make sense
	NSParameterAssert(updateBlock);

	if ( ![self.class __isValidCalendarUnit:calendarUnit] )
	{
		NSLog(@"RKCalendarLink: WARN: not valid calendar unit %u, see RKCalendarUnit.h", (unsigned)calendarUnit);
		return nil;
	}

	self = [super init];
	if ( self )
	{
		_calendarUnit = calendarUnit;
		_unitInterval = 1;
        _invalidated = NO;
		_updateBlock = updateBlock;

        if (start)
        {
            [self __scheduleNext];
        }
	}

	return self;
}

- (void) dealloc
{
	[self invalidate];
}

- (void) setUnitInterval:(NSUInteger)unitInterval
{
    if (self.invalidated)
    {
        NSLog(@"RKCalendarLink: WARN: link was already invalidated, do not call %@ and create new instance instead.", NSStringFromSelector(_cmd));
        return;
    }
    
	_unitInterval = unitInterval;

	[self __invalidateTimer];
	[self __scheduleNext];
}

- (void) setCalendarUnit:(NSCalendarUnit)calendarUnit
{
    if (self.invalidated)
    {
        NSLog(@"RKCalendarLink: WARN: link was already invalidated, do not call %@ and create new instance instead.", NSStringFromSelector(_cmd));
        return;
    }

	if ( ![self.class __isValidCalendarUnit:calendarUnit] )
	{
		NSLog(@"RKCalendarLink: WARN: not valid calendar unit %u", (unsigned)calendarUnit);

		[self __invalidateTimer];
		return;
	}

	_calendarUnit = calendarUnit;

	[self __invalidateTimer];
	[self __scheduleNext];
}

- (void) start
{
    if (self.invalidated)
    {
        NSLog(@"RKCalendarLink: WARN: link was already invalidated, do not call %@ and create new instance instead.", NSStringFromSelector(_cmd));
        return;
    }

    [self __scheduleNext];
}

- (void) stop
{
    if (self.invalidated)
    {
        NSLog(@"RKCalendarLink: WARN: link was already invalidated, do not call %@ and create new instance instead.", NSStringFromSelector(_cmd));
        return;
    }

    [self __invalidateTimer];
}

- (void) invalidate
{
    self.invalidated = YES;
    [self __invalidateTimer];
}

- (BOOL) isActive
{
    return self.timer != nil;
}

- (BOOL) isValid
{
    return !self.invalidated;
}

#pragma mark Private

- (void) __invalidateTimer
{
    self.timerTarget = nil;

	[self.timer invalidate];
	self.timer = nil;
}

- (void) __scheduleNext
{
	// calculate next fire date
	NSDate * nextFireDate = [self.class __dateOfNextUnitChange:self.calendarUnit
												  unitInterval:self.unitInterval
													  fromDate:[NSDate date]
													inCalendar:[NSCalendar currentCalendar]];

	// create new timer with fire date
    self.timerTarget = [[RKWeakTimerTarget alloc] initWithTarget:self selector:@selector(__timerFired)];
	self.timer = [[NSTimer alloc] initWithFireDate:nextFireDate interval:0 target:self.timerTarget
                                          selector:@selector(timerDidFire:) userInfo:nil repeats:NO];

	// schedule timer
	[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) __timerFired
{
    if (self.invalidated)
    {
        return;
    }

	self.updateBlock();

	[self __scheduleNext];
}



+ (NSDate *) __dateOfNextUnitChange:(NSCalendarUnit)calendarUnit
					   unitInterval:(NSUInteger)unitInterval
						   fromDate:(NSDate *)date
						 inCalendar:(NSCalendar *)calendar
{
	// create mask to leave all lower parts than input
	NSCalendarUnit componentFlags = calendarUnit * 2 - 2;

	// calculate cropped date
	NSDateComponents * cropped = [calendar components:componentFlags fromDate:date];
	NSDate * croppedDate = [calendar dateFromComponents:cropped];

	// create components by setting value
	NSDateComponents * compsPlus = [[NSDateComponents alloc] init];
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
    [self.class __setComponent:unitInterval forCalendarUnit:calendarUnit inComponents:compsPlus];
#elif TARGET_OS_MAC
	[compsPlus setValue:unitInterval forComponent:calendarUnit];
#endif

	// create final date
	NSDate * dateBySetting = [calendar dateByAddingComponents:compsPlus toDate:croppedDate options:0];

	// FIXME: remove this hack
	// add some milliseconds to fix rounding
	dateBySetting = [dateBySetting dateByAddingTimeInterval:0.001];

	return dateBySetting;
}

+ (BOOL) __isValidCalendarUnit:(NSCalendarUnit)calendarUnit
{
	CFCalendarUnit cfCalendarUnit = (CFCalendarUnit) calendarUnit;
	switch ( cfCalendarUnit )
	{
		case kCFCalendarUnitYear:
		case kCFCalendarUnitMonth:
		case kCFCalendarUnitDay:
		case kCFCalendarUnitHour:
		case kCFCalendarUnitMinute:
		case kCFCalendarUnitSecond:
			return YES;

		default:
			return NO;
	}
}





/*
 Taken from https://github.com/erichoracek/NSDateComponents-CalendarUnits to remove any dependecies and future problems with integration
 */
+ (NSInteger) __componentForCalendarUnit:(NSCalendarUnit)calendarUnit inComponents:(NSDateComponents *)components
{
    return [[components valueForKey:[self __keyForCalendarUnit:calendarUnit]] integerValue];
}

+ (void) __setComponent:(NSInteger)component forCalendarUnit:(NSCalendarUnit)calendarUnit inComponents:(NSDateComponents *)components
{
    [components setValue:@(component) forKeyPath:[self __keyForCalendarUnit:calendarUnit]];
}

+ (NSString *) __keyForCalendarUnit:(NSCalendarUnit)calendarUnit
{
    NSAssert1(((calendarUnit & (calendarUnit - 1)) == 0), @"calendarUnit (%@) must not be a masked value", @(calendarUnit));
    switch (calendarUnit) {
        case NSCalendarUnitEra:
            return NSStringFromSelector(@selector(era));
        case NSCalendarUnitYear:
            return NSStringFromSelector(@selector(year));
        case NSCalendarUnitMonth:
            return NSStringFromSelector(@selector(month));
        case NSCalendarUnitDay:
            return NSStringFromSelector(@selector(day));
        case NSCalendarUnitHour:
            return NSStringFromSelector(@selector(hour));
        case NSCalendarUnitMinute:
            return NSStringFromSelector(@selector(minute));
        case NSCalendarUnitSecond:
            return NSStringFromSelector(@selector(second));
        case NSCalendarUnitWeekday:
            return NSStringFromSelector(@selector(weekday));
        case NSCalendarUnitWeekdayOrdinal:
            return NSStringFromSelector(@selector(weekdayOrdinal));
        case NSCalendarUnitQuarter:
            return NSStringFromSelector(@selector(quarter));
        case NSCalendarUnitWeekOfMonth:
            return NSStringFromSelector(@selector(weekOfMonth));
        case NSCalendarUnitWeekOfYear:
            return NSStringFromSelector(@selector(weekOfYear));
        case NSCalendarUnitYearForWeekOfYear:
            return NSStringFromSelector(@selector(yearForWeekOfYear));
#if __MAC_OS_X_VERSION_MAX_ALLOWED >= 1070 || __NSCALENDAR_COND_IOS_5_0
        case NSCalendarUnitNanosecond:
            return NSStringFromSelector(@selector(nanosecond));
#endif
        case NSCalendarUnitCalendar:
            return NSStringFromSelector(@selector(calendar));
        case NSCalendarUnitTimeZone:
            return NSStringFromSelector(@selector(timeZone));
        default:
            NSAssert1(NO, @"Invalid Calendar Unit: %@", @(calendarUnit));
            return nil;
    }
}

@end
