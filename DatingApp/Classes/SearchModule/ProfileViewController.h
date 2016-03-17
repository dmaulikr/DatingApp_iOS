//
//  ProfileViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 01/10/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MWPhotoBrowser.h"
#import "DatingAppTabBarViewController.h"
#import "ProfileDetails.h"

@interface ProfileViewController : UIViewController<MWPhotoBrowserDelegate>

@property (strong, nonatomic) ProfileDetails *userProfile;
@property BOOL fromChatSession;

@end
