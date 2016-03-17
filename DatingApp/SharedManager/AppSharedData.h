//
//  AppSharedData.h
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <Quickblox/Quickblox.h>
#import "ProfileDetails.h"

@interface AppSharedData : NSObject <CLLocationManagerDelegate>

@property (strong,nonatomic) NSMutableDictionary *dictCatchedImages;
@property (strong,nonatomic) NSMutableArray *arrUserProfileInfo;
@property (strong,nonatomic) NSMutableArray *arrProfileDetails;
@property (strong,nonatomic) NSMutableArray *arrUserProfilePics;
@property (strong,nonatomic) NSMutableArray *arrEventPics;

@property (strong,nonatomic) NSMutableArray *arrEventList;
@property (strong,nonatomic) NSMutableArray *arrSearchUsers;
@property (strong, nonatomic)   NSMutableArray *arrAllUsers;
@property (strong, nonatomic)   NSMutableArray *arrDialogs;
@property (strong, nonatomic)   ProfileDetails *selectedRecipient;
@property (nonatomic, strong)   QBChatDialog *createdDialog;
@property (nonatomic, strong)   ProfileDetails *currentGameOpponent;
@property (nonatomic, strong) NSMutableDictionary *allMessages;

@property (strong,nonatomic) NSMutableArray *arrUserProfileData;
@property (strong,nonatomic) NSMutableArray *arrUserAllProfilePicture;
@property (strong,nonatomic) NSMutableArray *arrComments;
@property (strong,nonatomic) CLLocationManager *locationManager;
@property (assign,nonatomic) CLLocationDegrees userCurrentLattitude;
@property (assign,nonatomic) CLLocationDegrees userCurrentLongitude;
@property (assign,nonatomic) CLLocationDistance userCurrentAltitude;
@property (strong,nonatomic) UIView *viewToast;
@property (strong,nonatomic) UIView *view_Overlay;
@property (strong,nonatomic) UILabel *lblToastMessage;
@property (strong,nonatomic) NSData *pickerImageData;
@property (strong,nonatomic) NSString *strDeviceID;
@property (strong,nonatomic) NSString *strFileExtension;

@property (assign, nonatomic) BOOL isUploadMedia;
@property (assign, nonatomic) BOOL isErrorOrFailResponse;
@property (assign, nonatomic) BOOL isFacebookLoginSuccessful;
@property (assign, nonatomic) BOOL isSplitViewPresent;
@property (assign, nonatomic) BOOL isEventListUpdated;
@property (assign, nonatomic) BOOL isDialogsUpdated;

@property (strong, nonatomic) NSURL *fbPictureUrl;
@property (strong, nonatomic) NSString *fbName;
@property (strong, nonatomic) NSString *classIdentifier;
@property (strong, nonatomic) NSString *UserID;
@property (strong, nonatomic) NSString *chatAccountID;

@property (assign, nonatomic) int newEventCount;
@property (assign, nonatomic) int newMessageCount;

+ (AppSharedData *)sharedInstance;
- (void)showCustomLoaderWithTitle:(NSString*)title message:(NSString*)message onView:(UIView*)parentView;
- (void)removeLoadingView;
- (NSData *)base64DataFromString: (NSString *)string;
- (void) showAlertView:(NSString *)alertTitle withMessage:(NSString *)alertMessage withDelegate:(id)delegate withCancelBtnTitle:(NSString *)buttonCancelTitle withOtherButton:(NSString *)otherButtonTitle;
- (NSString *)convertGMTtoLocal:(NSString *)gmtDateStr;
- (void) showToastMessage:(NSString *) message onView:(UIView *)onView;
- (void) showViewOverLay:(UIView *)onView withClass:(NSString *)className;
- (void) hideViewOverLay;

- (long)getAgeFromBirthday:(NSString *)birthday;
- (QBChatDialog *)getSessionDailogFromArray:(NSUInteger)sessionID;
- (ProfileDetails *)getUserFromSessionID:(NSUInteger)sessionID;
- (GameStatus)getGameStatus;
- (void)setGameStatus:(GameStatus)status;

@end
