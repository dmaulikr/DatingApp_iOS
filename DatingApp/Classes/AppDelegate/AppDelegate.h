//
//  AppDelegate.h
//  DatingApp
//
//  Created by jayesh jaiswal on 06/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "ProfileDetails.h"
#import "DiceGameViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, retain) UIView *view_Overlay;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)showActivityIndicator;
- (void)hideActivityIndicator;

@end
