//
// Created by Roman Kříž on 30.04.14.
// Copyright (c) 2014 Touch Art, s.r.o. All rights reserved.
//

#import "RKCalendarLink.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
	#import	<NSDateComponents-CalendarUnits/NSDateComponents+CalendarUnits.h>
#endif



@interface RKCalendarLink ()

@property (nonatomic) NSTimer * timer;
@property (nonatomic, copy) void (^ updateBlock)();

@end


@implementation RKCalendarLink

- (instancetype) initWithCalendarUnit:(NSCalendarUnit)calendarUnit updateBlock:(void (^)())updateBlock
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

		self.updateBlock = updateBlock;

		// first update
		[self __timerFired];
	}

	return self;
}

- (void) dealloc
{
	[self __invalidateTimer];
}

- (void) setUnitInterval:(NSUInteger)unitInterval
{
	_unitInterval = unitInterval;

	[self __invalidateTimer];
	[self __scheduleNext];
}

- (void) setCalendarUnit:(NSCalendarUnit)calendarUnit
{
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


#pragma mark Private

- (void) __invalidateTimer
{
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
	self.timer = [[NSTimer alloc] initWithFireDate:nextFireDate interval:0 target:self
										  selector:@selector(__timerFired) userInfo:nil repeats:NO];

	// schedule timer
	[[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void) __timerFired
{
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
	[compsPlus setComponent:unitInterval forCalendarUnit:calendarUnit];
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

@end
