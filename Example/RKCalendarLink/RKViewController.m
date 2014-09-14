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

@property (weak, nonatomic) IBOutlet UILabel * timeLabel;

@property (strong, nonatomic) NSDateFormatter * dateFormatter;

@property (strong, nonatomic) RKCalendarLink * calendarLink;

@end



@implementation RKViewController

- (void) viewDidLoad
{
	[super viewDidLoad];

	NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
	formatter.dateFormat = @"HH:mm";
	self.dateFormatter = formatter;

	__weak __typeof(self) w_self = self;
	self.calendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitMinute updateBlock:^ {

		w_self.timeLabel.text = [w_self.dateFormatter stringFromDate:[NSDate date]];

		NSLog(@"minutes has changed");
	}];
}

@end
