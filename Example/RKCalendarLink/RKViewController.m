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
	self.minuteCalendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitMinute updateBlock:^ {
        [w_self updateDisplayedDate];
		NSLog(@"minutes has changed");
	}];

    self.secondsCalendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitSecond updateBlock:^{
        w_self.shouldShowColon = !w_self.shouldShowColon;
        [w_self updateDisplayedDate];
    }];
}

- (void) updateDisplayedDate
{
    NSDateFormatter *withFormatter = [[NSDateFormatter alloc] init];
    withFormatter.dateFormat = self.shouldShowColon ? @"HH:mm" : @"HH mm";

    self.timeLabel.text = [withFormatter stringFromDate:[NSDate date]];
}

@end
