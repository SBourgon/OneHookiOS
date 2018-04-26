//
//  NSDate+Utility.m
//  oneHookLibrary
//
//  Created by Eagle Diao on 2015-05-18.
//  Copyright (c) 2015 oneHook inc. All rights reserved.
//

#import "NSDate+Utility.h"
#import <UIKit/UIKit.h>
#import "OHMacros.h"
#import "OHLocalization.h"

@implementation NSDate (Utility)

+ (NSString*)getWeekdaySymbolAt:(int)weekday
{
    switch (weekday) {
        case 0:
            return [OHLocalization localizedString:@"Sunday"];
        case 1:
            return [OHLocalization localizedString:@"Monday"];
        case 2:
            return [OHLocalization localizedString:@"Tuesday"];
        case 3:
            return [OHLocalization localizedString:@"Wednesday"];
        case 4:
            return [OHLocalization localizedString:@"Thursday"];
        case 5:
            return [OHLocalization localizedString:@"Friday"];
        case 6:
            return [OHLocalization localizedString:@"Saturday"];
        default:
            return @"Unknown";
            break;
    }
}

- (int)weekdayIndex
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [gregorian components:NSCalendarUnitWeekday fromDate:self];
    long weekday = [comps weekday] - 1;
    return (int) weekday;
}

- (NSDate *)beginningOfDay
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:self];
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    return [calendar dateFromComponents:components];
}

- (NSDate *)endOfDay
{
    NSDate* date = [self beginningOfDay];
    return [NSDate dateWithTimeInterval:86399 sinceDate:date];
}

- (NSDate *)yesterday
{
    return [self dateByAddingTimeInterval:-86400];
}

- (BOOL)isSameDay:(NSDate *)other
{
    if(!other) {
        return NO;
    }
    return [[self shortDate] isEqualToString:[other shortDate]];
}

+ (NSDateFormatter*)isoDateFormatter
{
    static NSDateFormatter* isoDateFormatter;
    if(!isoDateFormatter) {
        isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    }
    return isoDateFormatter;
}

+ (NSDateFormatter*)isoDateFormatterNoTimeZone {
    static NSDateFormatter* isoDateFormatter;
    if(!isoDateFormatter) {
        isoDateFormatter = [[NSDateFormatter alloc] init];
        [isoDateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [isoDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
    }
    return isoDateFormatter;
}

const int SECOND = 1;
const int MINUTE = 60*SECOND;
const int HOUR = 60*MINUTE;
const int DAY = HOUR*24;
const int WEEK = DAY*7;
const int MONTH = WEEK*4;
const int YEAR = DAY*365;

-(NSString *)relativeTime
{
    NSDate *currentDate = [NSDate date];
    long deltaSeconds = labs(lroundf([self timeIntervalSinceDate:currentDate]));
    BOOL dateInFuture = ([self timeIntervalSinceDate:currentDate] > 0);
    
    if(deltaSeconds < 2*SECOND) {
        return [OHLocalization localizedString: @"Now"];
    } else if(deltaSeconds < MINUTE) {
        return [self formattedStringForCurrentDate:currentDate count:deltaSeconds past:@"%d seconds ago" future:@"%d seconds from now"];
    } else if(deltaSeconds < 1.5*MINUTE) {
        return !dateInFuture ? [OHLocalization localizedString: @"A minute ago"] : [OHLocalization localizedString: @"A minute from now"];
    } else if(deltaSeconds < HOUR) {
        int minutes = (int)lroundf((float)deltaSeconds/(float)MINUTE);
        return [self formattedStringForCurrentDate:currentDate count:minutes past:@"%d minutes ago" future:@"%d minutes from now"];
    } else if(deltaSeconds < 1.5*HOUR) {
        return !dateInFuture ? [OHLocalization localizedString: @"An hour ago"] : [OHLocalization localizedString: @"An hour from now"];
    } else if(deltaSeconds < DAY) {
        int hours = (int)lroundf((float)deltaSeconds/(float)HOUR);
        return [self formattedStringForCurrentDate:currentDate count:hours past:@"%d hours ago" future:@"%d hours from now"];
    } else if(deltaSeconds < 1.5*DAY) {
        return !dateInFuture ? [OHLocalization localizedString: @"A day ago"] : [OHLocalization localizedString: @"A day from now"];
    } else if(deltaSeconds < WEEK) {
        int days = (int)lroundf((float)deltaSeconds/(float)DAY);
        return [self formattedStringForCurrentDate:currentDate count:days past:@"%d days ago" future:@"%d days from now"];
    } else if(deltaSeconds < 1.5*WEEK) {
        return !dateInFuture ? [OHLocalization localizedString: @"A week ago"] : [OHLocalization localizedString: @"A week from now"];
    } else if(deltaSeconds < MONTH) {
        int weeks = (int)lroundf((float)deltaSeconds/(float)WEEK);
        return [self formattedStringForCurrentDate:currentDate count:weeks past:@"%d weeks ago" future:@"%d weeks from now"];
    } else if(deltaSeconds < 1.5*MONTH) {
        return !dateInFuture ? [OHLocalization localizedString: @"A month ago"] : [OHLocalization localizedString: @"A month from now"];
    } else if(deltaSeconds < YEAR) {
        int months = (int)lroundf((float)deltaSeconds/(float)MONTH);
        return [self formattedStringForCurrentDate:currentDate count:months past:@"%d months ago" future:@"%d months from now"];
    } else if(deltaSeconds < 1.5*YEAR) {
        return !dateInFuture ? [OHLocalization localizedString: @"A year ago"] : [OHLocalization localizedString: @"A year from now"];
    } else {
        int years = (int)lroundf((float)deltaSeconds/(float)YEAR);
        return [self formattedStringForCurrentDate:currentDate count:years past:@"%d years ago" future:@"%d years from now"];
    }
}

- (NSString*)relativeTimeShort
{
    NSDate *currentDate = [NSDate date];
    long deltaSeconds = labs(lroundf([self timeIntervalSinceDate:currentDate]));
    
    if(deltaSeconds < 2*SECOND) {
        return [OHLocalization localizedString: @"Now"];
    } else if(deltaSeconds < MINUTE) {
        return [self formattedStringForCurrentDate:currentDate count:deltaSeconds past:@"%ds" future:@"in %ds"];
    }else if(deltaSeconds < HOUR) {
        int minutes = (int)lroundf((float)deltaSeconds/(float)MINUTE);
        return [self formattedStringForCurrentDate:currentDate count:minutes past:@"%dm" future:@"in %dm"];
    } else if(deltaSeconds < DAY) {
        int hours = (int)lroundf((float)deltaSeconds/(float)HOUR);
        return [self formattedStringForCurrentDate:currentDate count:hours past:@"%dh" future:@"in %dh"];
    } else if(deltaSeconds < WEEK) {
        int days = (int)lroundf((float)deltaSeconds/(float)DAY);
        return [self formattedStringForCurrentDate:currentDate count:days past:@"%dd" future:@"in %dd"];
    } else if(deltaSeconds < MONTH) {
        int weeks = (int)lroundf((float)deltaSeconds/(float)WEEK);
        return [self formattedStringForCurrentDate:currentDate count:weeks past:@"%dw" future:@"in %dw"];
    } else if(deltaSeconds < YEAR) {
        int months = (int)lroundf((float)deltaSeconds/(float)MONTH);
        return [self formattedStringForCurrentDate:currentDate count:months past:@"%dm" future:@"in %dm"];
    } else {
        int years = (int)lroundf((float)deltaSeconds/(float)YEAR);
        return [self formattedStringForCurrentDate:currentDate count:years past:@"%dy" future:@"in %dy"];
    }
}

-(NSString *)formattedStringForCurrentDate:(NSDate *)currentDate count:(long)count past:(NSString *)past future:(NSString *)future
{
    if ([self timeIntervalSinceDate:currentDate] > 0) {
        return [NSString stringWithFormat:[OHLocalization localizedString:future], count];
    } else {
        return [NSString stringWithFormat:[OHLocalization localizedString:past], count];
    }
}

- (NSString *)shortDate
{
    static NSDateFormatter* dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[OHLocalization localizedString:@"shortDateNoYearFormat"]];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateWithYear
{
    static NSDateFormatter* dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:[OHLocalization localizedString:@"shortDateWithYearFormat"]];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortTime
{
    static NSDateFormatter* dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"hh:mm a"];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortWeek
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:self];
    return cal.veryShortWeekdaySymbols[[comp weekday]];
}

- (NSString *)shortWeekUTC
{
        NSCalendar* cal = [NSCalendar currentCalendar];
        cal.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        NSDateComponents* comp = [cal components:NSCalendarUnitWeekday fromDate:self];
        return cal.veryShortWeekdaySymbols[[comp weekday]];
}
    
- (NSString *)shortDateUTC
{
    static NSDateFormatter* dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setDateFormat:[OHLocalization localizedString:@"shortDateNoYearFormat"]];
    }
    return [dateFormatter stringFromDate:self];
}

- (NSString *)shortDateWithYearUTC
{
    static NSDateFormatter* dateFormatter;
    if(!dateFormatter) {
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
        [dateFormatter setDateFormat:[OHLocalization localizedString:@"shortDateWithYearFormat"]];
    }
    return [dateFormatter stringFromDate:self];
}


- (int)year
{
    NSCalendar* cal = [NSCalendar currentCalendar];
    NSDateComponents* comp = [cal components:NSCalendarUnitYear fromDate:self];
    int year = (int) [comp year];
    return year;
}

-(NSDate *)dateWithOutTime
{
    NSDateComponents* comps = [[NSCalendar currentCalendar] components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:self];
    return [[NSCalendar currentCalendar] dateFromComponents:comps];
}

@end
