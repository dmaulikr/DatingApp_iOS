//
//  LoginViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 06/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "LoginViewController.h"
#import "CustomTextField.h"
#import "ValidationManager.h"
#import "DatingAppTabBarViewController.h"
#import "RegistrationViewController.h"
#import "ForgotPasswordViewController.h"
#import "DashBoardViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "LocalStorageService.h"

@interface LoginViewController () <UITextFieldDelegate> {
    IBOutlet UIButton *facebookButton;
}

@property (weak, nonatomic) IBOutlet CustomTextField *txtfUserName;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfPassword;

- (IBAction)btnSignInTapped:(id)sender;
- (IBAction)btnFacebookTapped:(id)sender;

@end

@implementation LoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Initialize view elements and class members
    [self initViewAndClassMembers];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void) initViewAndClassMembers {
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField *)textField {
    
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [string rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    
    if(textField.tag == 2) {
        if (textField.text.length == 20) {
            if ([string isEqualToString:@""]) {
            } else if([string isEqualToString:@"\n"]) {
                if (location != NSNotFound) {
                    [textField resignFirstResponder];
                }
                return NO;
            } else {
                [appSharedData showToastMessage:@"Reached on limit" onView:self.view];
                return NO;
            }
        } else if (textField.text.length + string.length > 20) {
            [appSharedData showToastMessage:@"Reached on limit" onView:self.view];
            if (location != NSNotFound){
                [textField resignFirstResponder];
            }
            return NO;
        } else if (location != NSNotFound){
            [textField resignFirstResponder];
            return NO;
        }
    }
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {

    [self.txtfUserName resignFirstResponder];
    [self.txtfPassword resignFirstResponder];
}

#pragma mark - Button Tapped
- (IBAction)btnSignInTapped:(id)sender {
    
    [self checkAndPostLoginRequest];
}

- (IBAction)btnFacebookTapped:(id)sender {
    
    facebookButton.enabled = NO;
    [FBSession openActiveSessionWithReadPermissions:@[@"user_birthday",@"email", @"public_profile"] allowLoginUI:YES completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
        [appSharedData showCustomLoaderWithTitle:@"Connecting to Facebook" message:@"Please wait..." onView:self.view];
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (!error) {
                [self postLoginWithFacebookUser:user];
            } else {
                [appSharedData showAlertView:@"" withMessage:@"Failed to login with Facebook" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
                facebookButton.enabled = YES;
                [appSharedData removeLoadingView];
            }
        }];
    }];
}

- (void)checkAndPostLoginRequest {
    
    if (![self isValidUserInput]) {
        return;
    }
    NSString *strLattitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLattitude]] stringValue];
    NSString *strLongitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLongitude]] stringValue];
    NSString *strAltitude = [[NSNumber numberWithFloat:[appSharedData userCurrentAltitude]] stringValue];
    NSString *strToken = [[LocalStorageService shared] getSavedPushTokenAsString];
    NSDictionary  *requestBody = [NSDictionary dictionaryWithObjectsAndKeys:
                                   self.txtfUserName.text,      @"email",
                                   self.txtfPassword.text,      @"password",
                                   @"iOS",                      @"platform",
                                   appSharedData.strDeviceID,   @"device_id",
                                   strLattitude,                @"latitude",
                                   strLongitude,                @"longitude",
                                   strAltitude,                 @"altitude",
                                   strToken,                    @"apns_token",
                                   nil];
    [serviceManager executeServiceWithURL:LoginRequestURL withUIViewController:self withTitle:@"User Login" forTask:kTaskLoginUser withDictionary:requestBody completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]){
                ProfileDetails *authUserInfo = [[ProfileDetails alloc] initWithDictionary:[response objectForKey:@"User"]];
                authUserInfo.password = self.txtfPassword.text;
                authUserInfo.strDistance = @"0";
                [[LocalStorageService shared] saveAuthUserInfo:authUserInfo];
                
                DatingAppTabBarViewController *objDATBVC = (DatingAppTabBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DatingAppTabBarViewController"];
                objDATBVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:objDATBVC animated:YES completion:nil];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
        }
    }];
}

- (BOOL)isValidUserInput {
    
    NSRange whiteSpaceRange = [self.txtfUserName.text rangeOfCharacterFromSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *strUserName = [self.txtfUserName.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *strPassword = self.txtfPassword.text;
    if (whiteSpaceRange.location != NSNotFound) {
        [appSharedData showAlertView:@"" withMessage:@"Space is not allowed for email" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
    } else if(strUserName.length < 1 || strPassword.length < 1) {
        [appSharedData showAlertView:@"" withMessage:kNotificationMissedInput withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
    } else if(![ValidationManager validateEmailID:self.txtfUserName.text]) {
        [appSharedData showAlertView:@"" withMessage:kNotificationEmailNotValid withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
    }
    return YES;
}

- (void)postLoginWithFacebookUser:(NSDictionary<FBGraphUser> *)fbuser {
    
    NSString *facebookId = [fbuser objectForKey:@"id"];
    // Create user on QuickBlox
    [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
        // Configure user info based on user input
        QBUUser *user = [QBUUser user];
        user.login = facebookId;
        user.password = facebookId;
        
        // Send sign up request to server
        [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
            NSString *sessionID = [NSString stringWithFormat:@"%tu", user.ID];
            // Load chat service
            QBSessionParameters *params = [QBSessionParameters new];
            params.userLogin = facebookId;
            params.userPassword = facebookId;
            
            [QBRequest createSessionWithExtendedParameters:params successBlock:^(QBResponse *response, QBASession *session) {
                
                [self registerUserWithQuickBlox:fbuser quickbloxId:sessionID];
            } errorBlock:^(QBResponse *response) {
                [appSharedData removeLoadingView];
                [appSharedData showToastMessage:kNotificationPushDisabled onView:self.view];
            }];
        } errorBlock:^(QBResponse *response) {
            NSMutableArray *reasons = [[NSMutableArray alloc] initWithArray:response.error.reasons[@"errors"][@"login"]];
            NSString *reason = [reasons objectAtIndex:0];
            if ([reason isEqualToString:kLoginAlreadyTaken]) {
                [self registerUserWithQuickBlox:fbuser quickbloxId:@""];
            } else {
                [appSharedData removeLoadingView];
                [appSharedData showToastMessage:kNotificationRegisterFailed onView:self.view];
            }
        }];
    } errorBlock:^(QBResponse *response) {
        [appSharedData removeLoadingView];
        [appSharedData showToastMessage:kNotificationRegisterFailed onView:self.view];
    }];
    [appSharedData showCustomLoaderWithTitle:@"Loading" message:@"Please wait..." onView:self.view];
}

- (void)registerUserWithQuickBlox:(NSDictionary<FBGraphUser> *)user quickbloxId:(NSString *)quickbloxId {
    
    NSString *strApplicationUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *strLattitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLattitude]] stringValue];
    NSString *strLongitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLongitude]] stringValue];
    NSString *strAltitude = [[NSNumber numberWithFloat:[appSharedData userCurrentAltitude]] stringValue];
    NSString *userImageUrl = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", [user objectForKey:@"id"]];
    NSString *userBirthday = user.birthday;
    NSString *strToken = [[LocalStorageService shared] getSavedPushTokenAsString];
    if (userBirthday == nil) {
        userBirthday = @"1990-01-01";
    }
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [user name],                       @"name",
                                 [user objectForKey:@"email"],      @"email",
                                 [user objectForKey:@"gender"],     @"gender",
                                 strApplicationUUID,                @"device_id",
                                 [user objectForKey:@"id"],         @"facebook_id",
                                 @"iOS",                            @"platform",
                                 strLongitude,                      @"longitude",
                                 strLattitude,                      @"latitude",
                                 strAltitude,                       @"altitude",
                                 userImageUrl,                      @"profile_pic",
                                 userImageUrl,                      @"profile_pic_path",
                                 strToken,                          @"apns_token",
                                 userBirthday,                      @"dob",
                                 quickbloxId,                       @"chat_account_id",
                                 nil];
    [serviceManager executeServiceWithURL:FacebookLoginRequestUrl withUIViewController:self withTitle:@"Login" forTask:kTaskFacebookLogin withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                ProfileDetails *authUserInfo = [[ProfileDetails alloc] initWithDictionary:[response objectForKey:@"User"]];
                authUserInfo.password = authUserInfo.facebookId;
                authUserInfo.strDistance = @"0";
                [[LocalStorageService shared] saveAuthUserInfo:authUserInfo];
                
                DatingAppTabBarViewController *objDATBVC = (DatingAppTabBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DatingAppTabBarViewController"];
                objDATBVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:objDATBVC animated:YES completion:nil];
                return;
            }
            [appSharedData showAlertView:@"" withMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
            facebookButton.enabled = YES;
        }
    }];
}

@end
