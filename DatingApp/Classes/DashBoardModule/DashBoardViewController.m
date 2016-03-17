//
//  DashBoardViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.

#import <MessageUI/MessageUI.h>
#import "DashBoardViewController.h"
#import "SideBarViewController.h"
#import "AsyncImageView.h"
#import "ProfileDetails.h"
#import "LocalStorageService.h"
#import "ChatService.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "CommonUtils.h"
#import "CommonViewController.h"
#import "EditProfileViewController.h"

@interface DashBoardViewController () <SideBarViewControllerDelegate, MFMailComposeViewControllerDelegate> {
    ProfileDetails *authUserInfo;
    BOOL isSideMenuVisible;
}

@property (weak, nonatomic) IBOutlet UIView *viewSideBar;
@property (weak, nonatomic) IBOutlet UIView *viewDashBoard;
@property (strong, nonatomic) SideBarViewController *objSBVC;

@property (weak, nonatomic) IBOutlet AsyncImageView *imgProfilePicture;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAgeSex;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadlinecode;
@property (weak, nonatomic) IBOutlet UILabel *lblaboutME;
@property (weak, nonatomic) IBOutlet UILabel *lblFavourite;
@property (weak, nonatomic) IBOutlet UIButton *btnSplit;

@property (assign,nonatomic) BOOL isProfileUpdate;

- (IBAction)btnSplitTapped:(UIButton *)sender;

@end

@implementation DashBoardViewController

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
    
    // Initialize view elements and class members
    [self initViewAndClassMembers];
}

// Initialize view elements and class members
- (void)initViewAndClassMembers {
    
    self.isProfileUpdate = NO;
    
    [self populateDashboardContent];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(checkProfileIsUpdate)
                                                 name:KCheckProfileIsUpdated object:nil];
    
    self.objSBVC = (SideBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SideBarViewController"];
    [self.objSBVC setDelegate:self];
    [self.objSBVC setStrClassIdentifier:@"DashBoardViewController"];
    self.objSBVC.parentTabController = self;
    [self.viewSideBar addSubview:self.objSBVC.view];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    if (self.isProfileUpdate) {
        [self populateDashboardContent];
        self.isProfileUpdate = NO;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (isSideMenuVisible) {
        [self toggleSideMenu];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    if (isSideMenuVisible) {
        [self toggleSideMenu];
    }
}

#pragma mark - Button methods
- (IBAction)btnSplitTapped:(UIButton *)sender {
    
    [self toggleSideMenu];
}

// Toggle slide menu
- (void)toggleSideMenu {
    
    if (!isSideMenuVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.viewSideBar.frame = CGRectMake(0, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewDashBoard.frame = CGRectMake(210, self.viewDashBoard.frame.origin.y, self.viewDashBoard.frame.size.width, self.viewDashBoard.frame.size.height);
        [UIView commitAnimations];
        isSideMenuVisible = YES;
    } else {
        [UIView beginAnimations: @"Fade In" context:nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.viewSideBar.frame = CGRectMake(-210, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewDashBoard.frame = CGRectMake(0, self.viewDashBoard.frame.origin.y, self.viewDashBoard.frame.size.width, self.viewDashBoard.frame.size.height);
        [UIView commitAnimations];
        [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        isSideMenuVisible = NO;
    }
}

- (void)populateDashboardContent {
    
    authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    [self.imgProfilePicture setImageWithURLString:authUserInfo.strProfilePicture placeholderImage:[UIImage imageNamed:@"no_image_available.png"] toScaledSize:self.imgProfilePicture.bounds.size];
    
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
    
    [self.lblNameAgeSex setText:[NSString stringWithFormat:@"%@, %ld", authUserInfo.strName, years]];
    if ([authUserInfo.strHeadLineCode length] > 0) {
        [self.lblHeadlinecode setText:[NSString stringWithFormat:@"\"%@\"", authUserInfo.strHeadLineCode]];
    } else {
        [self.lblHeadlinecode setText:@""];
    }
    [self.lblaboutME setText:authUserInfo.strAboutMe];
    [self.lblaboutME sizeToFit];
    [self.lblFavourite setFrame:CGRectMake(_lblFavourite.frame.origin.x, _lblFavourite.frame.origin.y, 200, 33)];
    [self.lblFavourite setText:authUserInfo.strFavouriteDrink];
    [self.lblFavourite sizeToFit];
}

// Log out user from app
- (void)logoutApp {
    NSDictionary  *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:
                                  authUserInfo.strID, @"id", nil];
    [serviceManager executeServiceWithURL:LogoutRequestURL withUIViewController:self withTitle:@"Logout"  forTask:kTaskLogout withDictionary:requestBody completionHandler:^(id response, NSError *error,TaskType task){
        if(!error) {
            if(![[response objectForKey:@"result"] isKindOfClass:[NSNull class]]) {
                NSMutableDictionary *parsedData = [parsingManager parseResponse:response forTask:task];
                if([[parsedData objectForKey:@"result"] isEqualToString:@"Success"]) {
                    [self performLogout];
                } else {
                    [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
                }
            } else {
                [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            }
        } else {
            if([appSharedData isErrorOrFailResponse])
                [appSharedData setIsErrorOrFailResponse:NO];
        }
    }];
}

// Log out the application
- (void)performLogout {
    
    [[LocalStorageService shared] saveAuthUserInfo:nil];
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *loginNavigationController = (UINavigationController *)[mainStoryboard instantiateViewControllerWithIdentifier:@"DatingAppNavigationController"];
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    delegate.window.rootViewController = loginNavigationController;
    [self dismissViewControllerAnimated:YES completion:nil];
    if ([[QBChat instance] isLoggedIn]) {
        [[QBChat instance] logout];
    }
    [QBRequest unregisterSubscriptionWithSuccessBlock:nil errorBlock:nil];
}

#pragma mark - Notification Methods
- (void)checkProfileIsUpdate {
    
    self.isProfileUpdate = YES;
}

#pragma mark - SideBarViewControllerDelegate method
- (void)didSelectSideMenuItem:(NSNumber *)index {
    
    [self toggleSideMenu];
    
    UIViewController *selectedController = nil;
    CommonViewController *objEPVC = (CommonViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommonViewController"];
    switch (index.integerValue) {
        case 0:
            selectedController = (EditProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EditProfileViewController"];
            break;
        case 1:
            objEPVC.strTitle = @"Change Password";
            selectedController = objEPVC;
            break;
        case 2:
        {
            MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
            if ([MFMailComposeViewController canSendMail]) {
                mailViewController.mailComposeDelegate = self;
                NSArray *recipients = [NSArray arrayWithObject:kContactUsEmail];
                [mailViewController setToRecipients:recipients];
                [self presentViewController:mailViewController animated:YES completion:nil];
            }
        }
            break;
        case 3:
            objEPVC.strTitle = @"Privacy Policy";
            selectedController = objEPVC;
            break;
        case 4:
            objEPVC.strTitle = @"Terms Of Service";
            selectedController = objEPVC;
            break;
        case 5:
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Logout?" message:@"" delegate:self cancelButtonTitle:@"NO" otherButtonTitles:@"YES", nil];
            [alert show];
            alert = nil;
        }
            break;
        default:
            break;
    }
    
    if (selectedController != nil) {
        selectedController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:selectedController animated:YES completion:nil];
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    controller.mailComposeDelegate = nil;
    [controller dismissViewControllerAnimated:NO completion:nil];
}

# pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        [self logoutApp];
    }
}

@end