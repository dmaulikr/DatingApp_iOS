//
//  LocalStorageService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/16/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "LocalStorageService.h"

@implementation LocalStorageService

#define AUTH_USER_INFO @"AUTH_USER_INFO"
#define DEVICE_TOKEN_FOR_PUSH_NOTIFICATION @"DEVICE_TOKEN_FOR_PUSH_NOTIFICATION"
#define GAME_HISTORY_USERS @"GAME_HISTORY_USERS"

+ (instancetype)shared
{
	static id instance = nil;
	static dispatch_once_t onceToken;
	
	dispatch_once(&onceToken, ^{
		instance = [[self alloc] init];
	});
	
	return instance;
}

// Save auth user info
- (void) saveAuthUserInfo:(ProfileDetails *)userInfo {
    [[NSUserDefaults standardUserDefaults] setObject:[userInfo toDictionary] forKey:AUTH_USER_INFO];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Get saved auth user info
- (ProfileDetails *) getSavedAuthUserInfo {
    NSDictionary * userDict = [[NSUserDefaults standardUserDefaults] objectForKey:AUTH_USER_INFO];
    ProfileDetails *userInfo = [[ProfileDetails alloc] initWithDictionary:userDict];
    return userInfo;
}

// Save device token for push notification
- (void)saveDeviceTokenForPushNotification:(NSData *)deviceToken {
    [[NSUserDefaults standardUserDefaults] setObject:deviceToken forKey:DEVICE_TOKEN_FOR_PUSH_NOTIFICATION];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

// Load device token for push notification
- (NSData *)getSavedDeviceTokenForPushNotification {
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN_FOR_PUSH_NOTIFICATION];
}

- (NSString *)getSavedPushTokenAsString {
    
    NSData *deviceTokenForAPNS = [self getSavedDeviceTokenForPushNotification];
    NSString *strToken;
    if (deviceTokenForAPNS != nil) {
        strToken = [[deviceTokenForAPNS description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
        strToken = [strToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    } else {
        strToken = @"";
    }
    return strToken;
}

- (NSURL *)getConfigFileURL {
    NSURL *url = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    NSURL *fileURL = [url URLByAppendingPathComponent:@"config.plist"];
    return fileURL;
}

- (void)saveGameUserHistory:(NSMutableArray *)historyUsers {
    NSMutableArray *dictArray = [[NSMutableArray alloc] init];
    for (ProfileDetails *user in historyUsers) {
        [dictArray addObject:[user toDictionary]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:dictArray forKey:GAME_HISTORY_USERS];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)addUserToGameHistory:(ProfileDetails *)user {
    NSMutableArray *historyUsers = [self getGameUserHistory];
    for (ProfileDetails *historyUser in historyUsers) {
        if ([historyUser.strID isEqualToString:user.strID]) {
            return;
        }
    }
    [historyUsers addObject:user];
    [self saveGameUserHistory:historyUsers];
}

- (NSMutableArray *)getGameUserHistory {
    NSMutableArray *historyUsers = [[NSUserDefaults standardUserDefaults] objectForKey:GAME_HISTORY_USERS];
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in historyUsers) {
        [resultArray addObject:[[ProfileDetails alloc] initWithDictionary:dict]];
    }
    return resultArray;
}

@end
