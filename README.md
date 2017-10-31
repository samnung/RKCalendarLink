# RKCalendarLink

[![CI Status](http://img.shields.io/travis/samnung/RKCalendarLink.svg?style=flat)](https://travis-ci.org/samnung/RKCalendarLink)
[![Version](https://img.shields.io/cocoapods/v/RKCalendarLink.svg?style=flat)](http://cocoadocs.org/docsets/RKCalendarLink)
[![License](https://img.shields.io/cocoapods/l/RKCalendarLink.svg?style=flat)](http://cocoadocs.org/docsets/RKCalendarLink)
[![Platform](https://img.shields.io/cocoapods/p/RKCalendarLink.svg?style=flat)](http://cocoadocs.org/docsets/RKCalendarLink)

Minimalistic component for updating UI at right time.

RKCalendarLink is one class, that will invoke your code whenever given calendar unit will change. All is done by using Foundation framework. No magic stuff :)


## Usage

Let's say you want to display time label, which will display hours and minutes. But to keep minutes in sync you have to setup timer, which will fire every second.

But with this library it will fire only one time per minute. Also it is easy to use, see this example:

```objective-c
// self.timeLabel is instance of UILabel
// self.dateFormatter is instance of NSDateFormatter

__weak __typeof(self) w_self = self;
self.calendarLink = [[RKCalendarLink alloc] initWithCalendarUnit:NSCalendarUnitMinute updateBlock:^{
    w_self.timeLabel.text = [w_self.dateFormatter stringFromDate:[NSDate date]];
}];

self.timeLabel.text = [w_self.dateFormatter stringFromDate:[NSDate date]];
```

To see it alive, download this repo and run example project.

## Migration guide from version 0.X to 1.X

From version 1.0, the update block is not called after initialization of the link, so you have to keep that in mind and make appropriate changes.
Also `RKCalendarLink` now allows to start & stop the link, this could be usefull in UIViewController subclass.

## Supported OS & SDK Versions

- Supported build target - iOS 6.0 / Mac OS 10.9 (Xcode 5.0)
- Earliest supported deployment target - iOS 6.0 / Mac OS 10.9

NOTE: Mac is not tested, but it should work.


## Installation

RKCalendarLink is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod 'RKCalendarLink', '~> 0.1'


## Author

Roman Kříž, samnung@gmail.com


## License

RKCalendarLink is available under the MIT license. See the LICENSE file for more info.

