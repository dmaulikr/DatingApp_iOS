//
//  Constants.h
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#ifndef DinningApp_Constants_h
#define DinningApp_Constants_h

#define REST_HOST @"http://104.237.151.125/Barbuds_PHP/api"

#define RegistrationRequestURL          REST_HOST @"/registration"
#define LoginRequestURL                 REST_HOST @"/user_login"
#define URL_FORGOT_PASSWORD             REST_HOST @"/forgot_password"
#define FacebookLoginRequestUrl         REST_HOST @"/facebook_login"

#define GetProfileDetailsRequestURL     REST_HOST @"/get_profile_detail/"
#define EditProfileRequestURL           REST_HOST @"/save_profile"
#define UploadProfilePicRequestUrl      REST_HOST @"/upload_profile_pic"
#define UserProfilePicRequestUrl        REST_HOST @"/get_profile_pics"
#define DeleteProfilePicRequestUrl      REST_HOST @"/delete_profile_pic"

#define ChangePasswordRequestURL        REST_HOST @"/change_password"
#define LogoutRequestURL                REST_HOST @"/user_logout"

#define CreateEventRequestURL           REST_HOST @"/create_events"
#define SaveEventRequestURL             REST_HOST @"/save_event_pic"
#define GetEventListRequestURL          REST_HOST @"/events/"
#define GetEventDetailRequestURL        REST_HOST @"/get_event_detail"
#define DeleteEventRequestUrl           REST_HOST @"/delete_event"
#define UpdateEventRequestUrl           REST_HOST @"/update_events"

#define GetNearUserRequestUrl           REST_HOST @"/search"
#define GetUserProfileDataRequestUrl    REST_HOST @"/get_profile_detail/"
#define GetUserAllProfilePicsRequestUrl REST_HOST @"/get_profile_pics"

#define PostCommentRequestUrl           REST_HOST @"/comment"
#define GetCommentRequestUrl            REST_HOST @"/get_comment"

#define URL_GET_ALL_USERS               REST_HOST @"/get_all_users"
#define URL_DELETE_COMMENT              REST_HOST @"/delete_comment"
#define URL_CHANGE_ATTEND               REST_HOST @"/change_attend"

#define IS_IPHONE_5 ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON )
#define IS_OS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)

typedef  enum
{
	//Login Module
    kTaskRegisterUser,
    kTaskLoginUser,
	kTaskForgotPassword,
    kTaskFacebookLogin,
    
    kTaskGetProfileInfo,
    kTaskEditProfile,
    kTaskUploadProfilePic,
    kTaskUserProfilePic,
    kTaskDeleteProfilePic,
    
    
    kTaskChangePassword,
    kTaskLogout,
    
    kTaskCreateEvent,
    kTaskGetEventList,
    kTaskGetEventDetails,
    kTaskDeleteEvent,
    kTaskUpdateEvent,
    
    kTaskGetNearUser,
    kTaskGetUserProfileData,
    kTaskGetUserAllProfilePics,
    
    kTaskPostComment,
    kTaskGetComment
} TaskType;

typedef enum {
    kNotConnected,
    kWaitingOpponent,
    kAvailableToSpin
} GameStatus;

// enumerate type for event types
// added by Hong
typedef enum {
    UPCOMING_EVENT,
    NEW_EVENT,
    PAST_EVENT
} EVENT_TYPE;

#define KNotificationFacebookLginSuccessful @"facebookLoginSuccessful"
#define KCheckProfileIsUpdated @"checkProfileIsUpdated"
#define KNullValue @""
#define kPushDidReceive @"DidReceivePushNotification"

// Error codes
#define kLoginAlreadyTaken @"has already been taken"

// Messages
#define kNotificationMissedInput        @"Please fill all the required fields"
#define kNotificationResponseError      @"Connection error"
#define kNotificationEmailNotValid      @"Invalid email"
#define kNotificationPasswordMismatch   @"Password mismatch"
#define kNotificationPushDisabled       @"You can not receive push notifications on this device"
#define kNotificationChatDisabled       @"Failed to connected to chat service, you can not send or receive message"
#define kNotificationRegisterFailed     @"Register failed"
#define kNotificationProfilePicsLimit   @"You can upload upto 5 photos. Please remove one of them."

// Cell Identifiers
#define EVENT_LIST_ITEM_IDENTIFIER              @"event_list_item"
#define COMMENT_LIST_ITEM_IDENTIFIER            @"comments_list_item"
#define ATTENDING_USET_LIST_ITEM_IDENTIFIER     @"attending_user_cell"

#define kContactUsEmail             @"info@mybarbuds.com"

// Drink Motto
#define kDrinkMottos [NSMutableArray arrayWithObjects:@"There's always time for a glass of wine",@"Beer me",@"Cheer's for craft beers",                @"Wine is fine, but liquor is quicker", nil]

#endif
