//
//  ProfileDetails.m
//  DatingApp
//
//  Created by jayesh jaiswal on 11/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ProfileDetails.h"

@implementation ProfileDetails

@synthesize strAltitude, strDOB, strEmail, quickbloxUserID, password, strID, strLatitude,strLongitude,strName,strProfilePicture,strAboutMe,strChatCount, strEventCount, strFavouriteDrink, strGender, strHeadLineCode, strInterest, strMessageCount, strImageURL0, strImageURL1,strImageURL2, strImageURL3, strImageURL4, strDistance, facebookId;

- (id)initWithDictionary:(NSDictionary *)userDict {
    self = [super init];
    if (self) {
        self.strID = userDict[@"id"];
        self.strName = userDict[@"name"];
        NSString *pass = userDict[@"password"];
        if ([pass isKindOfClass:[NSNull class]] || [pass length] == 0) {
            pass = KNullValue;
        }
        self.password = pass;
        self.strEmail = userDict[@"email"];
        self.quickbloxUserID = [userDict[@"chat_account_id"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"chat_account_id"];
        self.strGender = userDict[@"gender"];
        self.strDOB = userDict[@"dob"];
        self.strHeadLineCode = [userDict[@"head_line_code"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"head_line_code"];
        self.strInterest = [userDict[@"interest"] isKindOfClass:[NSNull class]] || [userDict[@"interest"] length] == 0 ? KNullValue : userDict[@"interest"];
        self.strFavouriteDrink = [userDict[@"favourite_drink"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"favourite_drink"];
        self.strChatCount = [userDict[@"chat_count"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"chat_count"];
        self.strEventCount = [userDict[@"event_count"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"event_count"];
        self.strMessageCount = [userDict[@"message_count"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"message_count"];
        self.strAboutMe = [userDict[@"about_me"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"about_me"];
        self.strLatitude = [userDict[@"latitude"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"latitude"];
        self.strLongitude = [userDict[@"longitude"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"longitude"];
        self.strAltitude = [userDict[@"altitude"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"altitude"];
        self.strProfilePicture = [userDict[@"profile_pic_path"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"profile_pic_path"];
        self.strDistance = [userDict[@"distance"] isKindOfClass:[NSNull class]] ? KNullValue : userDict[@"distance"];
        self.facebookId = [userDict[@"facebook_id"] isKindOfClass:[NSNull class]] || [userDict[@"facebook_id"] length] == 0 ? KNullValue : userDict[@"facebook_id"];
    }
    return self;
}

- (NSDictionary *)toDictionary {
    
    return @{
             @"id"                  : self.strID,
             @"name"                : self.strName,
             @"password"            : self.password,
             @"email"               : self.strEmail,
             @"chat_account_id"     : self.quickbloxUserID,
             @"gender"              : self.strGender,
             @"dob"                 : self.strDOB,
             @"head_line_code"      : self.strHeadLineCode,
             @"interest"            : self.strInterest,
             @"favourite_drink"     : self.strFavouriteDrink,
             @"chat_count"          : self.strChatCount,
             @"event_count"         : self.strEventCount,
             @"message_count"       : self.strMessageCount,
             @"about_me"            : self.strAboutMe,
             @"latitude"            : self.strLatitude,
             @"longitude"           : self.strLongitude,
             @"altitude"            : self.strAltitude,
             @"profile_pic_path"    : self.strProfilePicture,
             @"distance"            : self.strDistance,
             @"facebook_id"         : self.facebookId
             };
}

- (NSUInteger)getQuickbloxUserID {
    return [NSNumber numberWithLongLong:self.quickbloxUserID.longLongValue].unsignedIntegerValue;
}

@end
