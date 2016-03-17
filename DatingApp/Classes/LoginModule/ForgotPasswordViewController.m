//
//  ForgotPasswordViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ForgotPasswordViewController.h"
#import "CustomTextField.h"
#import "ValidationManager.h"

@interface ForgotPasswordViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet CustomTextField *txtfEmail;

- (IBAction)btnResetPasswordTapped:(id)sender;
- (IBAction)didTapBackButton:(id)sender;

@end

@implementation ForgotPasswordViewController

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
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.txtfEmail resignFirstResponder];
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	[textField resignFirstResponder];
    return YES;
}

#pragma mark - Button Methods
- (IBAction)didTapBackButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnResetPasswordTapped:(id)sender{
    
    [self.txtfEmail resignFirstResponder];
    
    NSString *str = [self.txtfEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    // Check and validate the email address
    if ([str isEqualToString:KNullValue] || str.length == 0) {
        [appSharedData showAlertView:@"" withMessage:kNotificationMissedInput withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }
    if (![ValidationManager validateEmailID:str]) {
        [appSharedData showAlertView:@"" withMessage:kNotificationEmailNotValid withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }
    
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  str, @"email", nil];
    [serviceManager executeServiceWithURL:URL_FORGOT_PASSWORD withUIViewController:self withTitle:@"Please wait..."  forTask:kTaskRegisterUser withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                [appSharedData showAlertView:@"Success" withMessage:[response objectForKey:@"status"] withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
                return;
            }
        }
        [appSharedData showAlertView:@"Error" withMessage:[response objectForKey:@"status"] withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }];
}

@end
