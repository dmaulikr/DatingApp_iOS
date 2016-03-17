//
//  EventDetailViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 26/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "EventDetailViewController.h"
#import "ProfileDetails.h"
#import "CreatEventViewController.h"
#import "PostCommentViewController.h"
#import "UIImageView+AFNetworking.h"
#import "LocalStorageService.h"
#import "CommonUtils.h"
#import "ProfileViewController.h"
#import "AppSharedData.h"

@interface EventDetailViewController () <UITableViewDataSource, UITableViewDelegate> {
    ProfileDetails *creator;
    ProfileDetails *selectedUser;
    IBOutlet UIScrollView *mainScrollView;
    IBOutlet UITableView *tableAttendUsers;
    
    NSMutableArray *attendingUsers;
}

@property (weak, nonatomic) IBOutlet UILabel *lblDrinkMotto;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDate;
@property (weak, nonatomic) IBOutlet UILabel *lblEventTime;
@property (weak, nonatomic) IBOutlet UILabel *lblEventLocation;
@property (weak, nonatomic) IBOutlet UILabel *lblAddress;
@property (weak, nonatomic) IBOutlet UILabel *lblEventDetail;
@property (weak, nonatomic) IBOutlet UILabel *lblHostedBy;
@property (weak, nonatomic) IBOutlet UILabel *lblOn;

@property (weak, nonatomic) IBOutlet UIButton *btnEdit;
@property (weak, nonatomic) IBOutlet UIButton *btnRSVP;
@property (weak, nonatomic) IBOutlet UIImageView *imgEvent;
@property (weak, nonatomic) IBOutlet UIImageView *creatorProfileImage;

- (IBAction)btnCommentTapped:(UIButton *)sender;
- (IBAction)btnRSVPTapped:(UIButton *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnEditEvent:(UIButton *)sender;
- (IBAction)didTapCreatorProfile:(UIButton *)sender;

@end

@implementation EventDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Populate the content of Event Detail page
    [self initViewAndClassMembers];
    
    [self fetchAttendingUsers];
}

- (void)viewWillLayoutSubviews {
    
    [super viewWillLayoutSubviews];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

// Populate the content of Event Detail Page
- (void)initViewAndClassMembers {
    
    CommonUtils *utils = [CommonUtils shared];
    
    attendingUsers = [[NSMutableArray alloc] init];

    self.imgEvent.contentMode = UIViewContentModeScaleAspectFill;
    [self.imgEvent setImageWithURLString:self.objEvent.strEventPicPath placeholderImage:[UIImage imageNamed:@"defaultevent_icon.png"] toScaledSize:self.imgEvent.bounds.size];
    [self.lblDrinkMotto setText:self.objEvent.strEventName];
    [self.lblEventDate setText:self.objEvent.strEventStartDate];
    
    NSDate *eventDate = [utils convertStringToDate:self.objEvent.strEventStartDate withFormat:@"yyyy-MM-dd"];
    [self.lblEventDate setText:[utils convertDateToString:eventDate withFormat:@"MMM dd, yyyy"]];
    
    NSDate *startTime = [utils convertStringToDate:self.objEvent.strEventStartTime withFormat:@"HH:mm:ss"];
    NSDate *endTime = [utils convertStringToDate:self.objEvent.strEventEndTime withFormat:@"HH:mm:ss"];
    NSString *strStart = [utils convertDateToString:startTime withFormat:@"hh:mm a"];
    if (endTime != nil) {
        NSString *strEnd = [utils convertDateToString:endTime withFormat:@"hh:mm a"];
        strStart = [strStart stringByAppendingString:[NSString stringWithFormat:@" to %@", strEnd]];
    }
    [self.lblEventTime setText:strStart];
    [self.lblEventLocation setText:self.objEvent.strEventLocation];
    [self.lblAddress setText:self.objEvent.strEventAddress];
    [self.lblEventDetail setText:self.objEvent.strEventDetails];
    
    creator = nil;
    if ([self.objEvent.strEventUserId isEqualToString:[[LocalStorageService shared] getSavedAuthUserInfo].strID]) {
        creator = [[LocalStorageService shared] getSavedAuthUserInfo];
    } else {
        for (ProfileDetails *user in appSharedData.arrAllUsers) {
            if ([self.objEvent.strEventUserId isEqualToString:user.strID]) {
                creator = user;
                break;
            }
        }
    }
    
    self.btnEdit.hidden = YES;
    self.btnRSVP.enabled = YES;
    if (creator != nil) {
        [self.lblHostedBy setText:creator.strName];
        self.creatorProfileImage.layer.masksToBounds = YES;
        self.creatorProfileImage.layer.cornerRadius = 24;
        [self.creatorProfileImage setImageWithURLString:creator.strProfilePicture placeholderImage:[UIImage imageNamed:@"no_image_available.png"] toScaledSize:self.creatorProfileImage.bounds.size];
        if ([creator.strID isEqualToString:[[LocalStorageService shared] getSavedAuthUserInfo].strID]) {
            self.btnEdit.hidden = NO;
            self.btnRSVP.enabled = NO;
        }
    }
    
    NSDate *createdDate = [utils convertStringToDate:self.objEvent.strEventCreated withFormat:@"yyyy-MM-dd HH:mm:ss"];
    [self.lblOn setText:[utils convertDateToString:createdDate withFormat:@"MMM dd, yyyy"]];
    
    if ([self.objEvent getStatus] == PAST_EVENT) {
        self.btnRSVP.enabled = NO;
    }
    
    if ([self.objEvent getStatus] == NEW_EVENT) {
        [self.btnRSVP setTitle:@"ATTEND" forState:UIControlStateNormal];
    } else if ([self.objEvent getStatus] == UPCOMING_EVENT) {
        [self.btnRSVP setTitle:@"UNATTEND" forState:UIControlStateNormal];
    }
}

- (void)fetchAttendingUsers {
    
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.objEvent.strEventId, @"event_id",
                                  nil];
    [serviceManager executeServiceWithURL:GetEventDetailRequestURL withUIViewController:self withTitle:@"Fetching users list" forTask:kTaskCreateEvent withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]){
                for (id userDict in [response objectForKey:@"User"]) {
                    [attendingUsers addObject:[[ProfileDetails alloc] initWithDictionary:userDict]];
                }
            }
            [self populateAttendingUsersList];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
        }
    }];
}

- (void)populateAttendingUsersList {
    
    [tableAttendUsers reloadData];
    
    CGFloat height = tableAttendUsers.contentSize.height;
    CGFloat maxHeight = 500;
    
    if (height > maxHeight) {
        height = maxHeight;
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        CGRect frame = tableAttendUsers.frame;
        frame.size.height = height;
        [tableAttendUsers setFrame:frame];
        
        [mainScrollView setScrollEnabled:YES];
        [mainScrollView setContentSize:CGSizeMake(320, height + frame.origin.y)];
    }];
}

#pragma mark - Button Methods
- (IBAction)btnCommentTapped:(UIButton *)sender {
    
    PostCommentViewController *objEPVC = (PostCommentViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"PostCommentViewController"];
    objEPVC.objEvent = self.objEvent;
    objEPVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:objEPVC animated:YES];
}

- (IBAction)btnRSVPTapped:(UIButton *)sender {
    
    NSString *user_status = @"";
    if ([self.objEvent getStatus] == NEW_EVENT) {
        user_status = @"1";
    } else if ([self.objEvent getStatus] == UPCOMING_EVENT) {
        user_status = @"0";
    }
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [[LocalStorageService shared] getSavedAuthUserInfo].strID, @"user_id",
                                 self.objEvent.strEventId,                                  @"event_id",
                                 user_status,                                               @"user_status",
                                 nil];
    [serviceManager executeServiceWithURL:URL_CHANGE_ATTEND withUIViewController:self withTitle:@"Processing" forTask:kTaskCreateEvent withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error){
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]){
                [appSharedData setIsEventListUpdated:YES];
                [self.navigationController popViewControllerAnimated:YES];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            [Flurry logError:@"Attending_Event_Error" message:@"Attending_Event_Error" error:nil];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
        }
    }];
}

- (IBAction)btnBackTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnEditEvent:(UIButton *)sender {
    
    CreatEventViewController *eventEditController = (CreatEventViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreatEventViewController"];
    eventEditController.strIdentifier = @"UPDATE";
    eventEditController.objEvent = self.objEvent;
    eventEditController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:eventEditController animated:YES];
}

- (IBAction)didTapCreatorProfile:(UIButton *)sender {
    
    if ([self.objEvent.strEventUserId isEqualToString:[[LocalStorageService shared] getSavedAuthUserInfo].strID]) {
        [self.navigationController.tabBarController setSelectedIndex:0];
    } else {
        if (creator != nil) {
            [self navigateToUserProfile:creator];
        }
    }
}

- (IBAction)didTapLocation:(id)sender {
    
    NSString *urlString = [NSString stringWithFormat:@"http://maps.google.com/?q=%@", self.objEvent.strEventAddress];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [attendingUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ATTENDING_USET_LIST_ITEM_IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ATTENDING_USET_LIST_ITEM_IDENTIFIER];
    }
    
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    UILabel *userName = (UILabel *)[cell viewWithTag:2];
    ProfileDetails *userProfile = [attendingUsers objectAtIndex:indexPath.row];
    [userName setText:userProfile.strName];
    
    // show user info
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
    profileImage.contentMode = UIViewContentModeScaleAspectFill;
    profileImage.layer.cornerRadius = 25.0;
    profileImage.layer.masksToBounds = YES;
    
    UIImage *blankImage = [UIImage imageNamed:@"no_image_available.png"];
    NSURL *imageUrl = [NSURL URLWithString:userProfile.strProfilePicture];
    [profileImage setImageWithURL:imageUrl placeholderImage:blankImage];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self navigateToUserProfile:[attendingUsers objectAtIndex:indexPath.row]];
}

- (void)navigateToUserProfile:(ProfileDetails *)user {
    
    // When user select one user, display profile screen
    ProfileViewController * objPVC =
    (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    objPVC.userProfile = user;
    objPVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:objPVC animated:YES];
}

@end
