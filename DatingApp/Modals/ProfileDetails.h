//
//  ProfileDetails.h
//  DatingApp
//
//  Created by jayesh jaiswal on 11/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ProfileDetails : NSObject

@property (nonatomic, strong) NSString *strName;
@property (nonatomic, strong) NSString *strID;
@property (nonatomic, strong) NSString *strGender;
@property (nonatomic, strong) NSString *strEmail;
@property (nonatomic, strong) NSString *quickbloxUserID;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) NSString *strDOB;
@property (nonatomic, strong) NSString *strHeadLineCode;
@property (nonatomic, strong) NSString *strInterest;
@property (nonatomic, strong) NSString *strFavouriteDrink;
@property (nonatomic, strong) NSString *strChatCount;
@property (nonatomic, strong) NSString *strEventCount;
@property (nonatomic, strong) NSString *strAboutMe;
@property (nonatomic, strong) NSString *strMessageCount;
@property (nonatomic, strong) NSString *strLongitude;
@property (nonatomic, strong) NSString *strLatitude;
@property (nonatomic, strong) NSString *strAltitude;
@property (nonatomic, strong) NSString *strProfilePicture;
@property (nonatomic, strong) NSString *strImageURL0;
@property (nonatomic, strong) NSString *strImageURL1;
@property (nonatomic, strong) NSString *strImageURL2;
@property (nonatomic, strong) NSString *strImageURL3;
@property (nonatomic, strong) NSString *strImageURL4;
@property (nonatomic, strong) NSString *strDistance;
@property (nonatomic, strong) NSString *facebookId;

- (id)initWithDictionary:(NSDictionary *)userDict;
- (NSDictionary *)toDictionary;
- (NSUInteger)getQuickbloxUserID;

@end
