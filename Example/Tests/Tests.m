//
//  RKCalendarLinkTests.m
//  RKCalendarLinkTests
//
//  Created by Roman Kříž on 09/14/2014.
//  Copyright (c) 2014 Roman Kříž. All rights reserved.
//

#import <RKCalendarLink/RKCalendarLink.h>



@interface RKCalendarLink ()

+ (NSDate *) __dateOfNextUnitChange:(NSCalendarUnit)calendarUnit
					   unitInterval:(NSUInteger)unitInterval
						   fromDate:(NSDate *)date
						 inCalendar:(NSCalendar *)calendar;

@end



static NSDate * DateWithOnlyCalendarUnits(NSDate * date, NSCalendar * calendar, NSCalendarUnit units)
{
	NSDateComponents * components = [calendar components:units fromDate:date];
	return [calendar dateFromComponents:components];
}



SpecBegin(InitialSpecs)

describe(@"next unit change math", ^ {
	NSCalendar * const calendar = [NSCalendar currentCalendar];
	NSDate * const nowDate = [NSDate date];

	it(@"should calculate correct time to start of next day", ^ {
		NSDate * startDayDate = DateWithOnlyCalendarUnits(nowDate, calendar, NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);

		const NSTimeInterval expected = startDayDate.timeIntervalSince1970 + (24 * 60 * 60); // add one day in seconds


		NSDate * plusDay = [RKCalendarLink __dateOfNextUnitChange:NSCalendarUnitDay
													 unitInterval:1
														 fromDate:nowDate
													   inCalendar:calendar];

		NSTimeInterval plus = plusDay.timeIntervalSince1970;

		expect(plus).to.beCloseToWithin(expected, 0.001);
	});

	it(@"should calculate correct time to start of next hour", ^ {
		NSDate * startHourDate = DateWithOnlyCalendarUnits(nowDate, calendar, NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour);

		const NSTimeInterval expected = startHourDate.timeIntervalSince1970 + (60 * 60); // add one hour in seconds


		NSDate * plusDay = [RKCalendarLink __dateOfNextUnitChange:NSCalendarUnitHour
													 unitInterval:1
														 fromDate:nowDate
													   inCalendar:calendar];

		NSTimeInterval plus = plusDay.timeIntervalSince1970;

		expect(plus).to.beCloseToWithin(expected, 0.001);
	});

	it(@"should calculate correct time to start of next minute", ^ {
		NSDate * startMinuteDate = DateWithOnlyCalendarUnits(nowDate, calendar, NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute);

		const NSTimeInterval expected = startMinuteDate.timeIntervalSince1970 + 60; // add one minute in seconds


		NSDate * plusDay = [RKCalendarLink __dateOfNextUnitChange:NSCalendarUnitMinute
													 unitInterval:1
														 fromDate:nowDate
													   inCalendar:calendar];

		NSTimeInterval plus = plusDay.timeIntervalSince1970;

		expect(plus).to.beCloseToWithin(expected, 0.001);
	});
});

it(@"it handles deallocation of link well", ^{
    __block int triggerCount = 0;

    @autoreleasepool {
        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond updateBlock:^{
            triggerCount += 1;
        }];
    }

    waitUntil(^(DoneCallback done) {
        // wait for 2 seconds
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            done();
        });
    });

    expect(triggerCount).will.equal(1); // the block should be called exactly one time, the first time before invalidation
});

SpecEnd
