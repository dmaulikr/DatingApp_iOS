//
//  DatingAppTabBarViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatViewController.h"

@interface DatingAppTabBarViewController : UITabBarController <UITabBarControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) QBChatDialog *createdDialog;

+ (DatingAppTabBarViewController *)sharedInstance;
- (void)startApplication;
- (void)loginChatService;

@end
