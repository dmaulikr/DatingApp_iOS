//
//  UserProfilePicture.h
//  DatingApp
//
//  Created by jayesh jaiswal on 19/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserProfilePicture : NSObject

@property (strong, nonatomic) NSString *strPictureID;
@property (strong, nonatomic) NSString *strProfilePicture;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;

@end
