//
//  Events.m
//  DatingApp
//
//  Created by jayesh jaiswal on 16/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "Events.h"

@implementation Events

@synthesize
strEventAddress, strEventCreated,strEventStartDate,
strEventDetails, strEventId, strEventLocation, strEventName,
strEventStartTime, strEventUserId, strEventEndTime, strEventPicPath,
strInviteRadius;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    
    if (self) {
        strEventId          = [dictionary[@"id"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"id"];
        strEventAddress     = [dictionary[@"address"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"address"];
        strEventCreated     = [dictionary[@"created"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"created"];
        strEventStartDate   = [dictionary[@"start_date"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"start_date"];
        strEventDetails     = [dictionary[@"event_details"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"event_details"];
        strEventLocation    = [dictionary[@"location"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"location"];
        strEventName        = [dictionary[@"name"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"name"];
        strEventStartTime   = [dictionary[@"start_time"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"start_time"];
        strEventEndTime     = [dictionary[@"end_time"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"end_time"];
        strEventUserId      = [dictionary[@"user_id"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"user_id"];
        strEventPicPath     = [dictionary[@"event_picture_path"] isKindOfClass:[NSNull class]] ? nil : dictionary[@"event_picture_path"];
        strInviteRadius     = [dictionary[@"invite_radius"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"invite_radius"];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    
    return @{
             @"id"                  : strEventId,
             @"address"             : strEventAddress,
             @"created"             : strEventCreated,
             @"start_date"          : strEventStartDate,
             @"event_details"       : strEventDetails,
             @"location"            : strEventLocation,
             @"name"                : strEventName,
             @"start_time"          : strEventStartTime,
             @"end_time"            : strEventEndTime,
             @"user_id"             : strEventUserId,
             @"event_picture_path"  : strEventPicPath,
             @"invite_radius"       : strInviteRadius
             };
}

- (void)setStatus:(EVENT_TYPE)eventType {
    
    currentEventType = eventType;
}

- (EVENT_TYPE)getStatus {
    
    return currentEventType;
}

@end
