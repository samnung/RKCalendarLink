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

static void waitForSeconds(NSTimeInterval seconds)
{
    waitUntil(^(DoneCallback done) {
        // wait for 1 second
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            done();
        });
    });
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

it(@"it does not call the update block right after initialization", ^{
    __block int triggerCount = 0;

    @autoreleasepool {
        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond updateBlock:^{
            triggerCount += 1;
        }];
    }

    waitForSeconds(2);

    expect(triggerCount).will.equal(0); // the block should not be called
});

it(@"it handles deallocation of link well, it invalidates self after deallocation", ^{
    __block int triggerCount = 0;

    @autoreleasepool {
        __block RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond updateBlock:^{
            triggerCount += 1;
        }];

        // wait for first invoke (after 1 second)
        waitForSeconds(1);
        link = nil;
    }

    waitForSeconds(2);
    expect(triggerCount).will.equal(1);
});

describe(@"start & stop", ^{
    it(@"allows to start the link after some time", ^{
        __block int triggerCount = 0;

        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond start:NO updateBlock:^{
            triggerCount += 1;
        }];

        waitForSeconds(2);
        expect(triggerCount).to.equal(0);

        [link start];

        waitForSeconds(1);
        expect(triggerCount).to.equal(1);
    });

    it(@"allows to stop the link after some time", ^{
        __block int triggerCount = 0;

        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond updateBlock:^{
            triggerCount += 1;
        }];

        waitForSeconds(1);
        expect(triggerCount).to.equal(1);

        [link stop];

        waitForSeconds(2);
        expect(triggerCount).to.equal(1);
    });

    it(@"allows to investigate whether the link is active", ^{
        __block int triggerCount = 0;

        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond start:NO updateBlock:^{
            triggerCount += 1;
        }];
        expect(link.isActive).to.equal(NO);

        [link start];
        expect(link.isActive).to.equal(YES);

        [link stop];
        expect(link.isActive).to.equal(NO);

        [link invalidate];
        expect(link.isActive).to.equal(NO);
    });

    it(@"allows to investigate whether the link is valid", ^{
        __block int triggerCount = 0;

        RKCalendarLink *link = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond start:NO updateBlock:^{
            triggerCount += 1;
        }];
        expect(link.isValid).to.equal(YES);

        [link start];
        expect(link.isValid).to.equal(YES);

        [link stop];
        expect(link.isValid).to.equal(YES);

        [link invalidate];
        expect(link.isValid).to.equal(NO);
    });
});

SpecEnd
