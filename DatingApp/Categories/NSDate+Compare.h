//
//  NSDate+Compare.h
//  DatingApp
//
//  Created by JuanSanchez on 12/3/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Compare)

- (BOOL)isEarlierThan:(NSDate *)date;
- (BOOL)isEarlierThanOrEqualTo:(NSDate *)date;
- (BOOL)isEarlierTimeThan:(NSDate *)date;

@end
