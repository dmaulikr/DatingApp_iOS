//
//  ParsingManager.m
//  DatingApp
//
//  Created by jayesh jaiswal on 12/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ParsingManager.h"
#import "ProfileDetails.h"
#import "Events.h"
#import "UserProfilePicture.h"
#import "EventPicture.h"
#import "UserAllProfilePics.h"
#import "EventComment.h"

static ParsingManager *objParsingManager;

@implementation ParsingManager

+ (ParsingManager *)sharedManager{
    static dispatch_once_t predicate;
    if(objParsingManager == nil){
        dispatch_once(&predicate,^{
            objParsingManager = [[ParsingManager alloc] init];
        });
    }
    return objParsingManager;
}

- (id)parseResponse:(id)response forTask:(TaskType)task{
	
    NSMutableDictionary *parseDictionary;
	
#pragma mark - Start Login Module
	if(task==kTaskRegisterUser)
        parseDictionary=[self callkTaskRegisterUser:response forTask:task];
    else if(task==kTaskForgotPassword)
        parseDictionary=[self callkTaskForgotPassword:response forTask:task];
    else if(task==kTaskEditProfile)
        parseDictionary=[self callkTaskEditProfile:response forTask:task];
    else if(task==kTaskChangePassword)
        parseDictionary=[self callkTaskChangePassword:response forTask:task];
    else if(task==kTaskLogout)
        parseDictionary=[self callkTaskLogout:response forTask:task];
    else if(task==kTaskDeleteEvent)
        parseDictionary=[self callkTaskDeleteEvent:response forTask:task];
    else if(task==kTaskGetUserAllProfilePics)
        parseDictionary=[self callkTaskGetUserAllProfilePics:response forTask:task];
    
    return parseDictionary;
}

#pragma mark - Login Module
-(id) callkTaskRegisterUser:(id) response forTask:(TaskType)task
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
		[dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
        NSDictionary *dict=[response objectForKey:@"User"];
        if(dict.count>0)
        {
            [appSharedData setUserID:[dict objectForKey:@"id"]];
        }
    }
	return dictionary;
}

-(id) callkTaskForgotPassword:(id) response forTask:(TaskType)task
{
	NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
		[dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
    }
	return dictionary;
}

-(id) callkTaskChangePassword:(id) response forTask:(TaskType)task
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
		[dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
    }
    return dictionary;
}
-(id) callkTaskLogout:(id) response forTask:(TaskType)task
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
		[dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
    }
    return dictionary;
}

-(id) callkTaskEditProfile:(id) response forTask:(TaskType)task
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
		[dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
        NSDictionary *dict=[response objectForKey:@"User"];
        if(dict.count>0)
        {
            ProfileDetails *objProfileDetails=[[ProfileDetails alloc] init];
            if([[dict objectForKey:@"id"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrID:KNullValue];
            else
                [objProfileDetails setStrID:[dict objectForKey:@"id"]];
            if([[dict objectForKey:@"gender"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrGender:KNullValue];
            else
                [objProfileDetails setStrGender:[dict objectForKey:@"gender"]];
            if([[dict objectForKey:@"name"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrName:KNullValue];
            else
                [objProfileDetails setStrName:[dict objectForKey:@"name"]];
            if([[dict objectForKey:@"dob"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrDOB:KNullValue];
            else
                [objProfileDetails setStrDOB:[dict objectForKey:@"dob"]];
            
            if([[dict objectForKey:@"head_line_code"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrHeadLineCode:KNullValue];
            else
                [objProfileDetails setStrHeadLineCode:[dict objectForKey:@"head_line_code"]];
            if([[dict objectForKey:@"interest"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrInterest:KNullValue];
            else
                [objProfileDetails setStrInterest:[dict objectForKey:@"interest"]];
            
            if([[dict objectForKey:@"favourite_drink"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrFavouriteDrink:KNullValue];
            else
                [objProfileDetails setStrFavouriteDrink:[dict objectForKey:@"favourite_drink"]];
            if([[dict objectForKey:@"chat_count"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrChatCount:KNullValue];
            else
                [objProfileDetails setStrChatCount:[dict objectForKey:@"chat_count"]];
            if([[dict objectForKey:@"event_count"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrEventCount:KNullValue];
            else
                [objProfileDetails setStrEventCount:[dict objectForKey:@"event_count"]];
            if([[dict objectForKey:@"message_count"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrMessageCount:KNullValue];
            else
                [objProfileDetails setStrMessageCount:[dict objectForKey:@"message_count"]];
            if([[dict objectForKey:@"about_me"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrAboutMe:KNullValue];
            else
                [objProfileDetails setStrAboutMe:[dict objectForKey:@"about_me"]];
            
            if([[dict objectForKey:@"longitude"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrLongitude:KNullValue];
            else
                [objProfileDetails setStrLongitude:[dict objectForKey:@"longitude"]];
            if([[dict objectForKey:@"latitude"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrLatitude:KNullValue];
            else
                [objProfileDetails setStrLatitude:[dict objectForKey:@"latitude"]];
            if([[dict objectForKey:@"altitude"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrAltitude:KNullValue];
            else
                [objProfileDetails setStrAltitude:[dict objectForKey:@"altitude"]];
            if([[dict objectForKey:@"profile_pic_path"] isKindOfClass:[NSNull class]])
                [objProfileDetails setStrProfilePicture:KNullValue];
            else
                [objProfileDetails setStrProfilePicture:[dict objectForKey:@"profile_pic_path"]];
            
            if([[appSharedData arrProfileDetails] count]>0)
                [[appSharedData arrProfileDetails] removeAllObjects];
            [[appSharedData arrProfileDetails] addObject:objProfileDetails];
        }
    }
	return dictionary;
}

-(id) callkTaskGetUserAllProfilePics:(id) response forTask:(TaskType)task
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
        [dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
        NSArray *arrUserPicture=[response objectForKey:@"Images"];
        if([arrUserPicture count]>0)
		{
            NSMutableArray *arrUserAllPicList = [NSMutableArray array];
            [arrUserPicture enumerateObjectsUsingBlock:^(id UserPicObjectDict, NSUInteger index, BOOL *stop)
             {
                 UserAllProfilePics *obj=[[UserAllProfilePics alloc] init];
                 if([[UserPicObjectDict objectForKey:@"profile_pic_path"] isKindOfClass:[NSNull class]])
                     [obj setStrProfilePicture:KNullValue];
                 else
                     [obj setStrProfilePicture:[UserPicObjectDict objectForKey:@"profile_pic_path"]];
                 [arrUserAllPicList addObject:obj];
                 obj=nil;
             }];
            if([arrUserAllPicList count]>0)
            {
                if([[appSharedData arrUserAllProfilePicture]count]>0)
                   [[appSharedData arrUserAllProfilePicture] removeAllObjects];
                [appSharedData setArrUserAllProfilePicture:arrUserAllPicList];
            }
        }
    }
    return dictionary;
}

-(id) callkTaskDeleteEvent:(id) response forTask:(TaskType)task
{
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
	if([[response objectForKey:@"result"] isEqualToString:@"Success"])
	{
        [dictionary setObject:[response objectForKey:@"result"] forKey:@"result"];
        [dictionary setObject:[response objectForKey:@"status"] forKey:@"status"];
    }
    return dictionary;
}

@end
