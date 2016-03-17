//
//  UserProfilePicture.m
//  DatingApp
//
//  Created by jayesh jaiswal on 19/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "UserProfilePicture.h"

@implementation UserProfilePicture

@synthesize strProfilePicture,strPictureID;

- (id)initWithDictionary:(NSDictionary *)dictionary {
    
    self = [super init];
    if (self) {
        strPictureID        = [dictionary[@"id"] isKindOfClass:[NSNull class]] ? @"" : dictionary[@"id"];
        strProfilePicture   = [dictionary[@"profile_pic_path"] isKindOfClass:[NSNull class]] ? @"" : dictionary[@"profile_pic_path"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    
    return @{
             @"id"                  : strPictureID,
             @"profile_pic_path"    : strProfilePicture
             };
}

@end
