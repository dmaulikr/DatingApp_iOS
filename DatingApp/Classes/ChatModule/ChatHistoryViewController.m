//
//  ChatHistoryViewController.m
//  DatingApp
//
//  Created by WongFeiHong on 11/7/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ChatHistoryViewController.h"
#import "AsyncImageView.h"
#import "UIImageView+AFNetworking.h"
#import "CommonUtils.h"

@interface ChatHistoryViewController()

@property (nonatomic, strong) NSMutableArray *dialogs;
@property (nonatomic, weak) IBOutlet UITableView *dialogsTableView;

@end

@implementation ChatHistoryViewController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    self.dialogs = appSharedData.arrDialogs;
    
    if (appSharedData.isDialogsUpdated) {
        [appSharedData showCustomLoaderWithTitle:@"" message:@"Loading..." onView:self.view];
        [QBChat dialogsWithExtendedRequest:nil delegate:self];
        appSharedData.isDialogsUpdated = NO;
    } else {
        [self.dialogsTableView reloadData];
    }
    
    [self.dialogsTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    appSharedData.newMessageCount = 0;
    [[[[self.tabBarController viewControllers] objectAtIndex:2] tabBarItem] setBadgeValue:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [self.dialogs count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"history_cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"history_cell"];
    }
    
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    
    // show user info
    ProfileDetails *userProfile = [appSharedData getUserFromSessionID:chatDialog.recipientID];
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
    profileImage.contentMode = UIViewContentModeScaleAspectFill;
    profileImage.layer.cornerRadius = 32.0;
    profileImage.layer.masksToBounds = YES;
    
    UIImage *blankImage = [UIImage imageNamed:@"no_image_available.png"];
    NSURL *imageUrl = [NSURL URLWithString:userProfile.strProfilePicture];
    [profileImage setImageWithURL:imageUrl placeholderImage:blankImage];
    
    UILabel *labelUserName = (UILabel *)[cell viewWithTag:2];
    [labelUserName setText:userProfile.strName];
    
    UILabel *labelRecentMessage = (UILabel *)[cell viewWithTag:3];
    if ([chatDialog.lastMessageText isEqualToString:KNullValue] || chatDialog.lastMessageText.length <= 0) {
        labelRecentMessage.text = @"no recent messages";
    } else {
        labelRecentMessage.text = chatDialog.lastMessageText;
    }
    
    UILabel *dateTimeLable = (UILabel *)[cell viewWithTag:4];
    CommonUtils *utils = [CommonUtils shared];
    NSString *timeString = @"";
    if (chatDialog.lastMessageDate != nil) {
        if ([utils isToday:chatDialog.lastMessageDate]) {
            timeString = [utils convertDateToString:chatDialog.lastMessageDate withFormat:@"h:mm a"];
        } else {
            timeString = [utils convertDateToString:chatDialog.lastMessageDate withFormat:@"MM/dd/yyyy"];
        }
    }
    [dateTimeLable setText:timeString];
    utils = nil;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    QBChatDialog *chatDialog = self.dialogs[indexPath.row];
    [appSharedData setCreatedDialog:chatDialog];
    [appSharedData setSelectedRecipient:[appSharedData getUserFromSessionID:chatDialog.recipientID]];
    
    ChatViewController *chatController = [[self storyboard] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:chatController animated:YES];
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    
    [appSharedData removeLoadingView];
    if (result.success && [result isKindOfClass:[QBDialogsPagedResult class]]) {
        QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
        //
        NSArray *dialogs = pagedResult.dialogs;
        self.dialogs = [dialogs mutableCopy];
        [appSharedData setArrDialogs:self.dialogs];
        [self.dialogsTableView reloadData];
    }
}

@end
