//
//  RKViewController.m
//  RKCalendarLink
//
//  Created by Roman Kříž on 09/14/2014.
//  Copyright (c) 2014 Roman Kříž. All rights reserved.
//

#import "RKViewController.h"

#import <RKCalendarLink/RKCalendarLink.h>



@interface RKViewController ()

@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (strong, nonatomic) RKCalendarLink *minuteCalendarLink;
@property (strong, nonatomic) RKCalendarLink *secondsCalendarLink;

@property (nonatomic) BOOL shouldShowColon;

@end



@implementation RKViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

    self.shouldShowColon = YES;

	__weak __typeof(self) w_self = self;
    self.minuteCalendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitMinute start:NO updateBlock:^ {
        [w_self updateDisplayedDate];
		NSLog(@"minutes has changed");
	}];

    self.secondsCalendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond start:NO updateBlock:^{
        w_self.shouldShowColon = !w_self.shouldShowColon;
        [w_self updateDisplayedDate];
    }];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.minuteCalendarLink start];
    [self.secondsCalendarLink start];

    [self updateDisplayedDate];
}

- (void) viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];

    [self.minuteCalendarLink stop];
    [self.secondsCalendarLink stop];
}

- (void) updateDisplayedDate
{
    NSDateFormatter *withFormatter = [[NSDateFormatter alloc] init];
    withFormatter.dateFormat = self.shouldShowColon ? @"HH:mm" : @"HH mm";

    self.timeLabel.text = [withFormatter stringFromDate:[NSDate date]];
}

@end
