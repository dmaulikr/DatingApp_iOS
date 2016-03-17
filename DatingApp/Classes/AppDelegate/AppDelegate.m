//
//  AppDelegate.m
//  DatingApp
//
//  Created by jayesh jaiswal on 06/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "AppDelegate.h"
#import "LocalStorageService.h"
#import "LoginViewController.h"
#import "DatingAppTabBarViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // [[UITabBar appearance] setSelectionIndicatorImage:[UIImage imageNamed:@"tabbar_selected.png"]];
//    [[UITabBar appearance] setSelectedImageTintColor:[UIColor yellowColor]];
    NSString *strApplicationUUID  = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    [appSharedData setStrDeviceID:strApplicationUUID];
    
    // Set QuickBlox credentials (You must create application in admin.quickblox.com)
    //
    [QBApplication sharedApplication].applicationId = 15571;
    [QBConnection registerServiceKey:@"EatRvKZxJz-mnHv"];
    [QBConnection registerServiceSecret:@"NvaUGhEATfOG9tA"];
    [QBSettings setAccountKey:@"EGnY13s1xwynNyWppJ4w"];
    
    // Request push notification service if not requested before
    if ([[LocalStorageService shared] getSavedDeviceTokenForPushNotification] == nil) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
            [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        } else {
            [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound |UIRemoteNotificationTypeAlert)];
        }
    }
    
    // Instantiate view controller objects with identifier
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"DatingAppNavigationController"];
    DatingAppTabBarViewController *mainTabbarController = (DatingAppTabBarViewController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"DatingAppTabBarViewController"];
    
    // Check if user has already logged in, and display main screen if logged in
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    if (authUserInfo == nil || authUserInfo.strID == nil) {
        self.window.rootViewController = loginNavigationController;
    } else {
        self.window.rootViewController = mainTabbarController;
        if (launchOptions != nil) {
            NSDictionary *pushInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
            if (pushInfo != nil) {
                [[NSNotificationCenter defaultCenter] postNotificationName:kPushDidReceive object:nil userInfo:pushInfo];
            }
        }
    }
    
    [FBLoginView class];
    [FBProfilePictureView class];
    
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"QWTCGDRWJT36B4Y3GDS4"];
    [Flurry setEventLoggingEnabled:YES];
    [Flurry setDebugLogEnabled:YES];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)showActivityIndicator {
	
    self.view_Overlay= [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.window.frame.size.width, self.window.frame.size.height)];
    [self.view_Overlay setBackgroundColor:[UIColor blackColor]];
    [self.view_Overlay setAlpha:0.7];
    CGRect phoneScreen=[[UIScreen mainScreen]bounds];
    if (phoneScreen.size.height > 480)
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135, 254, 50, 50)];
    else
        self.activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(135, 215, 50, 50)];
    [self.activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
    [self.view_Overlay addSubview:self.activityIndicator];
    [self.activityIndicator startAnimating];
    [self.window addSubview:self.view_Overlay];
}

- (void)hideActivityIndicator {
    
    [self.activityIndicator stopAnimating];
    [self.view_Overlay removeFromSuperview];
	self.activityIndicator = nil;
	self.view_Overlay = nil;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
    DatingAppTabBarViewController *instance = [DatingAppTabBarViewController sharedInstance];
    if (instance != nil) {
        [instance loginChatService];
    }
}

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error {
}

#ifdef __IPHONE_8_0
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
    // handle the actions
    if ([identifier isEqualToString:@"declineAction"]) {
    } else if ([identifier isEqualToString:@"answerAction"]) {
    }
}
#endif

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [[LocalStorageService shared] saveDeviceTokenForPushNotification:deviceToken];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    
    [[LocalStorageService shared] saveDeviceTokenForPushNotification:nil];
    [appSharedData showToastMessage:@"Warning: Your app can not receive push notifications on this device" onView:nil];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
    if (application.applicationState == UIApplicationStateActive) {
        [self parseRemoteNotification:userInfo];
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

- (void)parseRemoteNotification:(NSDictionary *)userInfo {

    NSDictionary *pushInfo = userInfo[QBMPushMessageApsKey][QBMPushMessageAlertKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:kPushDidReceive object:nil userInfo:pushInfo];
}

@end
