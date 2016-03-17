//
//  NSDate+Compare.m
//  DatingApp
//
//  Created by JuanSanchez on 12/3/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "NSDate+Compare.h"

@implementation NSDate (Compare)

- (BOOL)isEarlierThan:(NSDate *)date {
    
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)isEarlierThanOrEqualTo:(NSDate *)date {
    
    return !([self compare:date] == NSOrderedDescending);
}

- (BOOL)isEarlierTimeThan:(NSDate *)date {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:date];
    NSDateComponents *selfComponents = [gregorian components:(NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:self];
    if ([components hour] < [selfComponents hour])
        return NO;
    if ([components hour] == [selfComponents hour]) {
        if ([components minute] < [selfComponents minute])
            return NO;
    }
    return YES;
}

@end
