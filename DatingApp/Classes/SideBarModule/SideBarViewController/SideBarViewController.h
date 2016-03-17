//
//  SideBarViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SideBarViewControllerDelegate <NSObject>

@optional

- (void)didSelectSideMenuItem:(NSNumber *)index;

@end

@interface SideBarViewController : UIViewController

@property (weak, nonatomic) NSObject<SideBarViewControllerDelegate> *delegate;
@property (nonatomic, strong) NSString *strClassIdentifier;
@property (nonatomic, strong) UIViewController *parentTabController;

@end
