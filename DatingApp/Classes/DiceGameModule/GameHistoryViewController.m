//
//  GameHistoryViewController.m
//  DatingApp
//
//  Created by WongFeiHong on 11/13/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "GameHistoryViewController.h"
#import "LocalStorageService.h"
#import "UIImageView+AFNetworking.h"

@implementation GameHistoryViewController

@synthesize historyTable;

- (void)viewDidLoad {
    
    historyUsers = [[LocalStorageService shared] getGameUserHistory];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)didTapBackButton:(UIButton *)sender {
    
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [historyUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"history_cell"];
    }
    
    ProfileDetails *userProfile = [historyUsers objectAtIndex:indexPath.row];
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    
    // show user info
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
    profileImage.contentMode = UIViewContentModeScaleAspectFill;
    profileImage.layer.cornerRadius = 25.0;
    profileImage.layer.masksToBounds = YES;
    
    UIImage *blankImage = [UIImage imageNamed:@"no_image_available.png"];
    NSURL *imageUrl = [NSURL URLWithString:userProfile.strProfilePicture];
    [profileImage setImageWithURL:imageUrl placeholderImage:blankImage];
    
    UILabel *labelUserName = (UILabel *)[cell viewWithTag:2];
    [labelUserName setText:userProfile.strName];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init] ;
    [view setBackgroundColor:[UIColor clearColor]];
    [view setFrame:CGRectMake(0, 0, 210, 0.1)];
    return view;
}


@end
