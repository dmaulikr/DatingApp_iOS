//
//  DatingAppTabBarViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "DatingAppTabBarViewController.h"
#import "LocalStorageService.h"
#import "ChatService.h"
#import "UITabBarItem+CustomBadge.h"
#import "CommonUtils.h"

@interface DatingAppTabBarViewController () {
    
    NSString *pushTag;
}

@end

static DatingAppTabBarViewController *instance;

@implementation DatingAppTabBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    NSArray *items = self.tabBar.items;
    for (UITabBarItem *item in items) {
        UIImage *image = item.image;
        item.selectedImage = image;
        item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:)
                                                 name:kPushDidReceive
                                               object:nil];
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveMessageNotification:)
                                                 name:kNotificationDidReceiveNewMessage object:nil];
    
    // Fetch online users
    [self loginChatService];
}

- (void)startApplication {
    
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    NSString *strID = authUserInfo.strID;
    
    // calculate age
    long years = 18;
    NSDate *birthDate = [[CommonUtils shared] convertStringToDate:authUserInfo.strDOB withFormat:@"yyyy-MM-dd"];
    NSDate *now = [NSDate date];
    if (birthDate != nil) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitFlags = NSYearCalendarUnit;
        NSDateComponents *components = [gregorian components:unitFlags fromDate:birthDate toDate:now options:0];
        years = [components year];
    }
    
    [Flurry setAge:years];
    [Flurry setGender:authUserInfo.strGender];
    [Flurry setUserID:authUserInfo.strID];
    
    NSString *strLattitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLattitude]] stringValue];
    NSString *strLongitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLongitude]] stringValue];
    NSString *strAltitude = [[NSNumber numberWithFloat:[appSharedData userCurrentAltitude]] stringValue];
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 strID, @"id",
                                 strLattitude, @"latitude",
                                 strLongitude, @"longitude",
                                 strAltitude, @"altitude", nil];
    [serviceManager executeServiceWithURL:URL_GET_ALL_USERS withUIViewController:self withTitle:@"Fetching Users"  forTask:kTaskGetNearUser withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            NSMutableArray *users = [NSMutableArray array];
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                for (id userDict in [response objectForKey:@"User"]) {
                    [users addObject:[[ProfileDetails alloc] initWithDictionary:userDict]];
                }
                appSharedData.arrAllUsers = users;
                ProfileDetails *currentUser = [[ProfileDetails alloc] initWithDictionary:[response objectForKey:@"Admin"]];
                appSharedData.newEventCount = [currentUser.strEventCount intValue];
                if (self.selectedIndex != 4 && appSharedData.newEventCount > 0) {
                    [[[self.viewControllers objectAtIndex:4] tabBarItem] setCustomBadgeValue:[NSString stringWithFormat:@"%d", appSharedData.newEventCount] withFont:[UIFont fontWithName:nil size:12] andFontColor:[UIColor redColor] andBackgroundColor:[UIColor whiteColor]];
                }
                return;
            }
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {

    [super viewWillAppear:NO];
    
    instance = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    instance = nil;
}

+ (DatingAppTabBarViewController *)sharedInstance {
    
    return instance;
}

// Create session for chat
- (void)loginChatService {
    
    [appSharedData showCustomLoaderWithTitle:@"" message:@"Please wait..." onView:self.view];
    // Load chat service
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    QBSessionParameters *params = [QBSessionParameters new];
    if ([authUserInfo.facebookId isEqualToString:KNullValue]) {
        params.userEmail = authUserInfo.strEmail;
        params.userPassword = authUserInfo.password;
    } else {
        params.userLogin = authUserInfo.facebookId;
        params.userPassword = authUserInfo.facebookId;
    }
    
    QBUUser *sessionUser = [QBUUser user];
    sessionUser.ID = [NSNumber numberWithLongLong:authUserInfo.quickbloxUserID.longLongValue].unsignedIntegerValue;
    if ([authUserInfo.facebookId isEqualToString:KNullValue]) {
        sessionUser.email = authUserInfo.strEmail;
        sessionUser.password = authUserInfo.password;
    } else {
        sessionUser.login = authUserInfo.facebookId;
        sessionUser.password = authUserInfo.facebookId;
    }
    
    if (![[QBChat instance] isLoggedIn]) {
        [QBRequest createSessionWithExtendedParameters:params successBlock:^(QBResponse *response, QBASession *session) {
            [[ChatService instance] loginWithUser:sessionUser completionBlock:^{
                [self startApplication];
            }];
            
            // Register to receive push notification
            [QBRequest registerSubscriptionForDeviceToken:[[LocalStorageService shared] getSavedDeviceTokenForPushNotification] successBlock:^(QBResponse *response, NSArray *subscriptions) {
            } errorBlock:^(QBError *error) {
                [appSharedData showAlertView:@"" withMessage:kNotificationPushDisabled withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
            }];
        } errorBlock:^(QBResponse *response) {
            [appSharedData showToastMessage:kNotificationChatDisabled onView:self.view];
            [appSharedData removeLoadingView];
        }];
    } else {
        [self startApplication];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    
    self.createdDialog = nil;
}

- (void)pushDidReceive:(NSNotification *)notification {
    
    // new push notification did receive - show it

    // push message
    NSDictionary *pushInfo = [notification userInfo];
    if (pushInfo == nil) {
        return;
    }
    
    pushTag = [pushInfo objectForKey:@"tag"];
    
    if ([pushTag isEqualToString:@"event_invite"]) {
        appSharedData.newEventCount ++;
        if (self.selectedIndex != 4) {
            [[[self.viewControllers objectAtIndex:4] tabBarItem] setCustomBadgeValue:[NSString stringWithFormat:@"%d", appSharedData.newEventCount] withFont:[UIFont fontWithName:nil size:13] andFontColor:[UIColor redColor] andBackgroundColor:[UIColor whiteColor]];
        }
    }
    
    ProfileDetails *opponent = nil;
    for (ProfileDetails *user in appSharedData.arrAllUsers) {
        if ([user.strID isEqualToString:[pushInfo objectForKey:@"opponent_id"]]) {
            opponent = user;
        }
    }
    if (opponent == nil)
        return;
    
    [appSharedData setCurrentGameOpponent:opponent];
    
    NSString *message = @"";
    
    if ([appSharedData getGameStatus] == kNotConnected) {
        // If user has ended or not started, accept invite
        if ([pushTag isEqualToString:@"game_invite"]) {
            message = [[NSString alloc] initWithFormat:@"%@ invited you to play the drinking game. Accept?", opponent.strName];
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"New message" message:message delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
            [alertMessage show];
        }
    } else {
        // If user is playing game, do not accept any invite
        // also do not accept any message from opponent
        if ([pushTag isEqualToString:@"game_activity"]) {
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"New message" message:[pushInfo objectForKey:@"body"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertMessage show];
        } else if ([pushTag isEqualToString:@"game_decline"]) {
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"New message" message:[pushInfo objectForKey:@"body"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertMessage show];
        } else if ([pushTag isEqualToString:@"game_accept"]) {
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"New message" message:[pushInfo objectForKey:@"body"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertMessage show];
        } else if ([pushTag isEqualToString:@"game_finish"]) {
            message = [[NSString alloc] initWithFormat:@"%@ ended the game", opponent.strName];
            UIAlertView *alertMessage = [[UIAlertView alloc] initWithTitle:@"New message" message:message delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alertMessage show];
        }
    }
}

#pragma mark
#pragma mark Chat Notifications
- (void)chatDidReceiveMessageNotification:(NSNotification *)notification {
    
    QBChatMessage *message = notification.userInfo[kMessage];
    NSString *dialogId = [message.customParameters objectForKey:@"dialog_id"];
    appSharedData.isDialogsUpdated = YES;
    
    ChatViewController *chatController = [ChatViewController sharedInstance];
    if (chatController == nil || ![chatController.dialog.ID isEqualToString:dialogId]) {
        appSharedData.newMessageCount ++;
        [[[self.viewControllers objectAtIndex:2] tabBarItem] setCustomBadgeValue:[NSString stringWithFormat:@"%d", appSharedData.newMessageCount] withFont:[UIFont fontWithName:nil size:12] andFontColor:[UIColor redColor] andBackgroundColor:[UIColor whiteColor]];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveProcessedMessage object:notification.userInfo];
}

# pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    int gameControllerIndex = 3;
    DiceGameViewController *gameController = [self.viewControllers objectAtIndex:gameControllerIndex];
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    if (buttonIndex == 0) {
        if ([pushTag isEqualToString:@"game_decline"]) {
            [appSharedData setGameStatus:kNotConnected];
        } else if ([pushTag isEqualToString:@"game_activity"]) {
            [appSharedData setGameStatus:kAvailableToSpin];
        } else if ([pushTag isEqualToString:@"game_invite"]) {
            // If user click "No" button when he receives invite, send decline notification
            NSString *recipientIDs = appSharedData.currentGameOpponent.quickbloxUserID;
            NSMutableDictionary *message = [NSMutableDictionary dictionary];
            [message setObject:@"game_decline" forKey:@"tag"];
            [message setObject:authUserInfo.strID forKey:@"opponent_id"];
            [message setObject:[NSString stringWithFormat:@"%@ declined game invite", authUserInfo.strName] forKey:@"body"];
            [appSharedData showCustomLoaderWithTitle:nil message:@"Please wait..." onView:self.view];
            [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
                [appSharedData removeLoadingView];
                [appSharedData setCurrentGameOpponent:nil];
                [appSharedData setGameStatus:kNotConnected];
                if (gameController != nil) {
                    [gameController changeStatus];
                }
            } errorBlock:^(QBError *error) {
                [appSharedData removeLoadingView];
                [appSharedData showToastMessage:@"Sending failed" onView:self.view];
            }];
        } else if ([pushTag isEqualToString:@"game_finish"]) {
            [appSharedData setCurrentGameOpponent:nil];
            [appSharedData setGameStatus:kNotConnected];
        } else if ([pushTag isEqualToString:@"game_accept"]) {
            [self addUserToHistory:appSharedData.currentGameOpponent];
            [appSharedData setGameStatus:kAvailableToSpin];
        }
    } else {
        if ([pushTag isEqualToString:@"game_invite"]) {
            // If user click "Yes" button when he receives invite, send accept notification
            NSString *recipientIDs = appSharedData.currentGameOpponent.quickbloxUserID;
            NSMutableDictionary *message = [NSMutableDictionary dictionary];
            [message setObject:@"game_accept" forKey:@"tag"];
            [message setObject:authUserInfo.strID forKey:@"opponent_id"];
            [message setObject:[NSString stringWithFormat:@"%@ accepted game invite", authUserInfo.strName] forKey:@"body"];
            [appSharedData showCustomLoaderWithTitle:nil message:@"Please wait..." onView:self.view];
            [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
                [appSharedData removeLoadingView];
                [self addUserToHistory:appSharedData.currentGameOpponent];
                [appSharedData setGameStatus:kWaitingOpponent];
                self.selectedIndex = gameControllerIndex;
                if (gameController != nil) {
                    [gameController changeStatus];
                }
            } errorBlock:^(QBError *error) {
                [appSharedData removeLoadingView];
                [appSharedData showToastMessage:@"Sending failed" onView:self.view];
            }];
            
            // Send flurry analytics
            NSDictionary *analytics = [NSDictionary dictionaryWithObjectsAndKeys:
                                       @"Game Invite Accepted", @"notification",
                                       authUserInfo.strName, @"user_name",
                                       authUserInfo.strEmail, @"user_email", nil];
            [Flurry logEvent:@"DrinkingGame Invite accepted" withParameters:analytics];
        }
    }
    
    if (gameController != nil) {
        [gameController changeStatus];
    }
}

- (void)addUserToHistory:(ProfileDetails *)user {
    
    [[LocalStorageService shared] addUserToGameHistory:user];
}

@end
