//
//  Events.h
//  DatingApp
//
//  Created by jayesh jaiswal on 16/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Events : NSObject {
    EVENT_TYPE currentEventType;
}

@property (strong, nonatomic) NSString *strEventId;
@property (strong, nonatomic) NSString *strEventName;
@property (strong, nonatomic) NSString *strEventStartDate;
@property (strong, nonatomic) NSString *strEventStartTime;
@property (strong, nonatomic) NSString *strEventEndTime;
@property (strong, nonatomic) NSString *strEventLocation;
@property (strong, nonatomic) NSString *strEventAddress;
@property (strong, nonatomic) NSString *strEventDetails;
@property (strong, nonatomic) NSString *strEventUserId;
@property (strong, nonatomic) NSString *strEventCreated;
@property (strong, nonatomic) NSString *strEventPicPath;
@property (strong, nonatomic) NSString *strInviteRadius;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;

- (void)setStatus:(EVENT_TYPE)eventType;
- (EVENT_TYPE)getStatus;

@end
