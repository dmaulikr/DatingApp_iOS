//
//  LocalStorageService.h
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProfileDetails.h"

@interface LocalStorageService : NSObject

@property (nonatomic, strong) NSDictionary *appUserInfo;
@property (nonatomic, strong) NSArray *users;
@property (nonatomic, readonly) NSDictionary *usersAsDictionary;

+ (instancetype)shared;

- (void) saveAuthUserInfo:(ProfileDetails *)userInfo;
- (ProfileDetails *) getSavedAuthUserInfo;

- (void)saveDeviceTokenForPushNotification:(NSData *)deviceToken;
- (NSData *)getSavedDeviceTokenForPushNotification;
- (NSString *)getSavedPushTokenAsString;

- (void)saveGameUserHistory:(NSMutableArray *)historyUsers;
- (void)addUserToGameHistory:(ProfileDetails *)user;
- (NSMutableArray *)getGameUserHistory;

@end
