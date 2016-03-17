//
//  CommonViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 02/09/14.
//
//  Modified by Hong 22/11/2014
//
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "CommonViewController.h"
#import "ProfileDetails.h"
#import "LocalStorageService.h"

@implementation CommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    [lblTitle setText:self.strTitle];
    if([self.strTitle isEqualToString:@"Change Password"]) {
        [viewChange setHidden:NO];
    } else if ([self.strTitle isEqualToString:@"Privacy Policy"]) {
        [txtView1 setHidden:NO];
    } else if ([self.strTitle isEqualToString:@"Terms Of Service"]) {
        [txtView setHidden:NO];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [txtfOldPassword resignFirstResponder];
    [txtfNewPassword resignFirstResponder];
    [txtfConfirmPassword resignFirstResponder];
}

#pragma mark - Button methods
- (IBAction)btnBackTapped:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnChangePassword:(UIButton *)sender {
    
    if (txtfOldPassword.text.length == 0 || txtfNewPassword.text.length == 0 || txtfConfirmPassword.text.length == 0) {
        [appSharedData showAlertView:@"" withMessage:kNotificationMissedInput withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }
    if (![txtfNewPassword.text isEqualToString:txtfConfirmPassword.text]) {
        [appSharedData showAlertView:@"" withMessage:kNotificationPasswordMismatch withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }
    
    [self postChangePasswordRequest];
}

- (void)postChangePasswordRequest {
    
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 txtfOldPassword.text,      @"old_password",
                                 txtfNewPassword.text,      @"new_password",
                                 txtfConfirmPassword.text,  @"confirm_password",
                                 authUserInfo.strID,        @"id", nil];
    [serviceManager executeServiceWithURL:ChangePasswordRequestURL withUIViewController:self withTitle:@"Please wait..."  forTask:kTaskChangePassword withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                [appSharedData showAlertView:@"" withMessage:@"Your password changed successfully" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
                [txtfOldPassword setText:@""];
                [txtfNewPassword setText:@""];
                [txtfConfirmPassword setText:@""];
                return;
            }
            [appSharedData showAlertView:@"Error" withMessage:[response objectForKey:@"status"] withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        } else {
            [appSharedData showAlertView:@"Error" withMessage:@"Connection error" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        }
    }];
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if (textField == txtfOldPassword) {
        [txtfNewPassword becomeFirstResponder];
    } else if (textField == txtfNewPassword) {
        [txtfConfirmPassword becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
