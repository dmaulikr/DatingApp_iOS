//
//  SearchViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "SearchViewController.h"
#import "SideBarViewController.h"
#import "AsyncImageView.h"
#import "ProfileViewController.h"
#import "DatingAppTabBarViewController.h"
#import "LocalStorageService.h"
#import "UIImageView+AFNetworking.h"
#import "SearchSettingsController.h"

#define CELL_IDENTIFIER @"cellIdentifier"

@interface SearchViewController () <UITableViewDataSource, UITableViewDelegate, SideBarViewControllerDelegate, SearchSettingsControllerDelegate> {
    int thresholdDistance;
    int thresholdAge;
    BOOL isRowSelected;
    
    BOOL isSideMenuVisible;
    SideBarViewController *objSBVC;
}

@property (weak, nonatomic) IBOutlet UIView *viewSideBar;
@property (weak, nonatomic) IBOutlet UIView *viewSearch;
@property (weak, nonatomic) IBOutlet UITableView *tblView;

- (IBAction) btnSplitTapped:(UIButton *)sender;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Initialize view and class members
    [self initViewAndClassMembers];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    if (isRowSelected == NO) {
        [self callSearchRequest];
    } else {
        isRowSelected = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (isSideMenuVisible) {
        [self toggleSideMenu];
    }
}

// Initialize view and class members
- (void) initViewAndClassMembers {
    
    // init distance and age threshold values
    thresholdAge = -1;
    thresholdDistance = 20;
    
    isRowSelected = NO;
    
    objSBVC = (SideBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SideBarViewController"];
    [objSBVC setDelegate:self];
    [objSBVC setStrClassIdentifier:@"SearchViewController"];
    [self.viewSideBar addSubview:objSBVC.view];
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

// Toggle slide menu
- (void)toggleSideMenu {
    
    if (!isSideMenuVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.viewSideBar.frame = CGRectMake(0, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewSearch.frame = CGRectMake(210, self.viewSearch.frame.origin.y, self.viewSearch.frame.size.width, self.viewSearch.frame.size.height);
        [UIView commitAnimations];
        isSideMenuVisible = YES;
    } else {
        [UIView beginAnimations: @"Fade In" context:nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.viewSideBar.frame = CGRectMake(-210, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewSearch.frame = CGRectMake(0, self.viewSearch.frame.origin.y, self.viewSearch.frame.size.width, self.viewSearch.frame.size.height);
        [UIView commitAnimations];
        [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        isSideMenuVisible = NO;
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    isRowSelected = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // When user select one user, display profile screen
    ProfileViewController * objPVC =
        (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
    objPVC.fromChatSession = NO;
    objPVC.userProfile = [[appSharedData arrSearchUsers] objectAtIndex:indexPath.row];
    objPVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:objPVC animated:YES];
}

- (void) tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma mark - UITableViewDataSource
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return appSharedData.arrSearchUsers.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_IDENTIFIER];
    }
    
    UIImageView *iview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    cell.selectedBackgroundView = iview;
    iview = nil;
    
    // user profile image
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
    profileImage.layer.cornerRadius = 32;
    profileImage.layer.masksToBounds = YES;
    
    // Profile Info for each user
    ProfileDetails *searchUser = [appSharedData.arrSearchUsers objectAtIndex:indexPath.row];
    if (searchUser != nil) {
        [profileImage setImageWithURL:[NSURL URLWithString:searchUser.strProfilePicture] placeholderImage:[UIImage imageNamed:@"no_image_available.png"]];
        long  years = [appSharedData getAgeFromBirthday:searchUser.strDOB];
        UILabel *lblEventTitle = (UILabel *)[cell viewWithTag:2];
        [lblEventTitle setText:[NSString stringWithFormat:@"%@, %ld", searchUser.strName,years]];
        
        UILabel *lblHeadline = (UILabel *)[cell viewWithTag:3];
        [lblHeadline setText:searchUser.strHeadLineCode];
        
        UILabel *lblAddress = (UILabel *)[cell viewWithTag:4];
        int distance = floorf([searchUser.strDistance floatValue] * 10.0f);
        [lblAddress setText:[NSString stringWithFormat:@"%g miles", distance / 10.0f]];
    }
    
    return cell;
}

#pragma mark - Button Methods
- (IBAction)btnSplitTapped:(UIButton *)sender {
    
    [self toggleSideMenu];
}

#pragma mark - SideBarViewControllerDelegate method
- (void)didSelectSideMenuItem:(NSNumber *)index {

    if (index.integerValue == 0) {
        isRowSelected = YES;
        SearchSettingsController *settingsController = (SearchSettingsController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SearchSettingsController"];
        [settingsController setDefaultDistanceWithAge:thresholdDistance age:thresholdAge];
        settingsController.delegate = self;
        settingsController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:settingsController animated:YES];
    }
}

#pragma mark - SearchSettingsControllerDelegate method
- (void)didChangeSearchDistanceWithAge:(int)distance age:(int)age {
    
    thresholdDistance = distance;
    thresholdAge = age;
    [self callSearchRequest];
}

// Send find nearby user request to server
- (void) callSearchRequest {
    
    NSString *strLattitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLattitude]] stringValue];
    NSString *strLongitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLongitude]] stringValue];
    
    NSString *distance = [NSString stringWithFormat:@"%d", thresholdDistance];
    NSString *age = [NSString stringWithFormat:@"%d", thresholdAge];
    NSString *strID = [[LocalStorageService shared] getSavedAuthUserInfo].strID;
    
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                strID,             @"id",
                                strLongitude,      @"longitude",
                                strLattitude,      @"latitude",
                                distance,          @"distance",
                                age,               @"age",      nil];
    [serviceManager executeServiceWithURL:GetNearUserRequestUrl withUIViewController:self withTitle:@"Fetching Users"  forTask:kTaskGetNearUser withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            NSMutableArray *searchResult = [NSMutableArray array];
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                for (id userDict in [response objectForKey:@"User"]) {
                    [searchResult addObject:[[ProfileDetails alloc] initWithDictionary:userDict]];
                }
                if ([searchResult count] > 0) {
                    [appSharedData.arrSearchUsers removeAllObjects];
                    [appSharedData setArrSearchUsers:searchResult];
                    [self.tblView reloadData];
                }
                return;
            }
            [appSharedData.arrSearchUsers removeAllObjects];
            [self.tblView reloadData];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

#pragma mark TextField delegate methods
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [string rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if(textField.tag==1) {
        if (textField.text.length + string.length > 4) {
            [appSharedData showToastMessage:@"Reached on limit" onView:self.view];
            if (location != NSNotFound){
                [textField resignFirstResponder];
            }
            return NO;
        }
    } else {
        if (textField.text.length + string.length > 3) {
            [appSharedData showToastMessage:@"Reached on limit" onView:self.view];
            if (location != NSNotFound){
                [textField resignFirstResponder];
            }
            return NO;
        }
    }
	return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
	return YES;
}

@end
