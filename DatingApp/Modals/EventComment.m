//
//  EventComment.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/10/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "EventComment.h"

@implementation EventComment

@synthesize strId, strComment, strEventId, strUserId, strUserName, strUserPicture, strCommentDateTime;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    
    if (self) {
        strId               = [dictionary[@"id"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"id"];
        strEventId          = [dictionary[@"event_id"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"event_id"];
        strUserId           = [dictionary[@"user_id"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"user_id"];
        strUserName         = [dictionary[@"name"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"name"];
        strComment          = [dictionary[@"comment"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"comment"];
        strCommentDateTime  = [dictionary[@"created"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"created"];
        strUserPicture      = [dictionary[@"profile_pic_path"] isKindOfClass:[NSNull class]] ? KNullValue : dictionary[@"profile_pic_path"];
    }
    
    return self;
}

- (NSDictionary *)toDictionary {
    
    return @{
             @"id"                  : strId,
             @"event_id"            : strEventId,
             @"user_id"             : strUserId,
             @"name"                : strUserName,
             @"comment"             : strComment,
             @"created"             : strCommentDateTime,
             @"profile_pic_path"    : strUserPicture
             };
}

@end
