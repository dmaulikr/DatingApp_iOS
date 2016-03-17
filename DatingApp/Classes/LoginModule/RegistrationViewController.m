//
//  RegistrationViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 07/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "RegistrationViewController.h"
#import "CustomTextField.h"
#import "ValidationManager.h"
#import "ASIFormDataRequest.h"
#import "UIImage+Resize.h"
#import <FacebookSDK/FacebookSDK.h>
#import "DatingAppTabBarViewController.h"
#import "LocalStorageService.h"
#import "CommonUtils.h"
#import "CommonViewController.h"

@interface RegistrationViewController ()<UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate,UIActionSheetDelegate> {
    NSDate *selectedDate;
    CommonUtils *helperUtils;
}

@property (weak, nonatomic) IBOutlet UIImageView *imageViewAddPhoto;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfName;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEmail;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfPassword;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfDOB;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfConfirmPassword;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;
@property (weak, nonatomic) IBOutlet UIButton *btnFemale;
@property (weak, nonatomic) IBOutlet UIButton *btnAddPhoto;
@property (weak, nonatomic) IBOutlet UIButton *btnCalender;
@property (strong, nonatomic) UITextField *txtfGlobal;
@property (strong, nonatomic) NSString *strGenderOfUser;
@property (strong, nonatomic) NSString *strImageData;
@property (weak, nonatomic) IBOutlet UIView *viewTOSPP;
@property (weak, nonatomic) IBOutlet UIButton *btnTermsOfService;
@property (weak, nonatomic) IBOutlet UIButton *btnPrivacyPolicy;

//Date Picker
@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneDatePicker;

- (IBAction)btnMaleTapped:(UIButton *)sender;
- (IBAction)btnFemaleTapped:(UIButton *)sender;
- (IBAction)btnAddPhotoTapped:(id)sender;
- (IBAction)btnCalendarTapped:(UIButton *)sender;
- (IBAction)btnTermsOfServiceTapped:(UIButton *)sender;
- (IBAction)btnPrivacyPolicyTapped:(UIButton *)sender;
- (IBAction)cancelDatePickerTapped:(UIBarButtonItem *)sender;
- (IBAction)doneDatePickerTapped:(UIBarButtonItem *)sender;
- (IBAction)btnRegistrationTapped:(id)sender;
- (IBAction)didTapBackButton:(id)sender;

@end

@implementation RegistrationViewController

- (void) dealloc {
    
    if (self.txtfGlobal) self.txtfGlobal = nil;
    if (self.strGenderOfUser) self.strGenderOfUser = nil;
    if (self.strImageData) self.strImageData = nil;
    if (self.strImageData) self.strImageData = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapOnImageView)];
	[self.imageViewAddPhoto addGestureRecognizer:singleTap];
    singleTap = nil;
    
    self.strGenderOfUser = @"Male";
    helperUtils = [CommonUtils shared];
    [self.datePicker addTarget:self action:@selector(datePickerChanged) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setMinimumDate:[helperUtils convertStringToDate:@"1964-01-01" withFormat:@"yyyy-MM-dd"]];
    NSDateComponents *dateComponenets = [[NSDateComponents alloc] init];
    [dateComponenets setYear:-18];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *maxDate = [calendar dateByAddingComponents:dateComponenets toDate:[NSDate date] options:0];
    [self.datePicker setMaximumDate:maxDate];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    [self.btnMale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLayoutSubviews{
    
    if(IS_OS_7_OR_LATER && IS_IPHONE_5){
        CGRect frame = self.viewDatePicker.frame;
        frame.origin.y = self.view.frame.size.height-self.viewDatePicker.frame.size.height;
        [self.viewDatePicker setFrame:frame];
    }
}

- (void)postCreateUserRequest {
    NSString *strApplicationUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString *strLattitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLattitude]] stringValue];
    NSString *strLongitude = [[NSNumber numberWithFloat:[appSharedData userCurrentLongitude]] stringValue];
    NSString *strAltitude  = [[NSNumber numberWithFloat:[appSharedData userCurrentAltitude]] stringValue];
    NSString *strChatAccountId = [appSharedData chatAccountID];
    [appSharedData setIsUploadMedia:YES];
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                self.txtfName.text,             @"name",
                                self.txtfEmail.text,            @"email",
                                self.txtfPassword.text,         @"password",
                                self.strGenderOfUser,           @"gender",
                                self.txtfConfirmPassword.text,  @"confirmpassword",
                                strApplicationUUID,             @"device_id",
                                self.txtfDOB.text,              @"dob",
                                @"iOS",                         @"platform",
                                @"1",                           @"status",
                                @"signup",                      @"page",
                                strLongitude,                   @"longitude",
                                strLattitude,                   @"latitude",
                                strAltitude,                    @"altitude",
                                strChatAccountId,               @"chat_account_id",
                                nil];
    [serviceManager executeServiceWithURL:RegistrationRequestURL withUIViewController:self withTitle:@"User Registration"  forTask:kTaskRegisterUser withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                ProfileDetails *authUserInfo = [[ProfileDetails alloc] initWithDictionary:[response objectForKey:@"User"]];
                authUserInfo.strDistance = @"0";
                authUserInfo.password = self.txtfPassword.text;
                [[LocalStorageService shared] saveAuthUserInfo:authUserInfo];
                
                // Send analytics to Flurry
                NSDictionary *analytics = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"New user registered", @"notification",
                                           authUserInfo.strName, @"user_name",
                                           authUserInfo.strEmail, @"user_email", nil];
                [Flurry logEvent:@"User_Registered" withParameters:analytics];
                
                DatingAppTabBarViewController *objDATBVC = (DatingAppTabBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"DatingAppTabBarViewController"];
                objDATBVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
                [self presentViewController:objDATBVC animated:YES completion:nil];
                return;
            }
            [appSharedData showAlertView:@"" withMessage:[response objectForKey:@"status"] withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        } else {
            [appSharedData showAlertView:@"" withMessage:@"Connection error" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        }
    }];
}

#pragma mark - Button Methods
- (IBAction)btnMaleTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
	self.strGenderOfUser = @"Male";
    [self.btnMale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btnFemale setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)btnFemaleTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
	self.strGenderOfUser = @"Female";
    [self.btnFemale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btnMale setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)btnAddPhotoTapped:(id)sender {
    
    [self singleTapOnImageView];
}

- (IBAction)btnTermsOfServiceTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
    
    CommonViewController *viewController = (CommonViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommonViewController"];
    viewController.strTitle = @"Terms Of Service";
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)btnPrivacyPolicyTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
    
    CommonViewController *viewController = (CommonViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CommonViewController"];
    viewController.strTitle = @"Privacy Policy";
    viewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)btnRegistrationTapped:(id)sender {
    
    [self.txtfGlobal resignFirstResponder];
    if ([self isValidUserInput]) {
        
        // Create user on QuickBlox
        [QBRequest createSessionWithSuccessBlock:^(QBResponse *response, QBASession *session) {
            // Configure user info based on user input
            QBUUser *user = [QBUUser user];
            user.email = self.txtfEmail.text;
            user.password = self.txtfPassword.text;
            
            // Send sign up request to server
            [QBRequest signUp:user successBlock:^(QBResponse *response, QBUUser *user) {
                NSString *sessionID = [NSString stringWithFormat:@"%tu", user.ID];
                [appSharedData setChatAccountID:sessionID];
                [appSharedData removeLoadingView];
                [self postCreateUserRequest];
            } errorBlock:^(QBResponse *response) {
                [appSharedData showToastMessage:@"Failed to register chat service, contact admin" onView:self.view];
                [appSharedData removeLoadingView];
                
                NSMutableArray *reasons = [[NSMutableArray alloc] initWithArray:response.error.reasons[@"errors"][@"email"]];
                NSString *reason = [reasons objectAtIndex:0];
                if ([reason isEqualToString:kLoginAlreadyTaken]) {
                    [appSharedData showAlertView:@"" withMessage:@"Same email is registered on chat server" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
                } else {
                    [appSharedData showAlertView:@"" withMessage:@"Failed to register chat service. Contact admin" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
                    [appSharedData removeLoadingView];
                }
            }];
        } errorBlock:^(QBResponse *response) {
            [appSharedData showAlertView:@"" withMessage:@"Failed to register chat service. Contact admin" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
            [appSharedData removeLoadingView];
        }];
        [appSharedData showCustomLoaderWithTitle:@"Register to chat service" message:@"Please wait..." onView:self.view];
    }
}

- (IBAction)didTapBackButton:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)singleTapOnImageView {
    
    NSString *other1 = @"Gallery";
    NSString *other2 = @"Camera";
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Upload Picture" delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:other1, other2, nil];
    [actionSheet showInView:self.view];
    actionSheet = nil;
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
	[textField resignFirstResponder];
    
	if (textField.tag == 11)
		[self.txtfEmail becomeFirstResponder];
	else if(textField.tag == 12)
        [self.txtfPassword becomeFirstResponder];
	else if(textField.tag == 13)
		[self.txtfConfirmPassword becomeFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
	self.txtfGlobal = textField;
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
	BOOL retutnValue = NO;
    if (textField.tag == 11)	{
		retutnValue = YES;
    } else if (textField.tag == 12) {
		retutnValue = [self callTextField:textField withRange:range withString:string withValidationCount:50];
    } else if (textField.tag == 13) {
		retutnValue = [self callTextField:textField withRange:range withString:string withValidationCount:16];
    } else if (textField.tag == 14)	{
		retutnValue = [self callTextField:textField withRange:range withString:string withValidationCount:16];
    }
    return retutnValue;
}

- (BOOL)callTextField:(UITextField *)textField withRange:(NSRange)range withString:(NSString *)string withValidationCount:(int)ValidCount {
    
	BOOL returnValue = NO;
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [string rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
	if (textField.text.length == ValidCount) {
		if ([string isEqualToString:@""])
			returnValue = YES;
        else if([string isEqualToString:@"\n"]) {
			if (location != NSNotFound)
				[textField resignFirstResponder];
			returnValue = NO;
		} else {
			[appSharedData showToastMessage:@"Reached on limit" onView:self.view];
			returnValue = NO;
		}
	} else if (textField.text.length + string.length > ValidCount) {
		[appSharedData showToastMessage:@"Reached on limit" onView:self.view];
		if (location != NSNotFound)
			[textField resignFirstResponder];
		returnValue = NO;
    } else if (textField.text.length+string.length <ValidCount+1) {
		returnValue = YES;
    } else if (location != NSNotFound) {
		[textField resignFirstResponder];
		returnValue = NO;
	}
	return returnValue;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.txtfGlobal resignFirstResponder];
}

#pragma mark - DatePicker
- (IBAction)btnCalendarTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
    [self toggleDatePicker:YES];
}

- (IBAction)cancelDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
}

- (IBAction)doneDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
    selectedDate = self.datePicker.date;
    if (selectedDate != nil) {
        [self.txtfDOB setText:[helperUtils convertDateToString:selectedDate withFormat:@"yyyy-MM-dd"]];
    }
}

- (void)datePickerChanged {
    
    selectedDate = self.datePicker.date;
}

- (void)toggleDatePicker:(BOOL)visible {
    
    if (visible) {
        [appSharedData showViewOverLay:self.view withClass:@"RegistrationViewController"];
        [self.view bringSubviewToFront:self.viewDatePicker];
        [UIView beginAnimations: @"Fade In" context:nil];
        [UIView setAnimationDelay:.1];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.viewDatePicker.alpha = 1;
        [UIView commitAnimations];
        [self.viewDatePicker setHidden:NO];
    } else {
        [UIView beginAnimations: @"Fade Out" context:nil];
        [UIView setAnimationDelay:.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.5];
        self.viewDatePicker.alpha = 0.0;
        [UIView commitAnimations];
        [appSharedData hideViewOverLay];
    }
}

#pragma mark - UIActionSheet delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    } else if (buttonIndex == 1) {
		UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePicker Delegate Methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
	UIImage *chosenImage = (UIImage*)[info objectForKey:@"UIImagePickerControllerOriginalImage"];
	CGFloat compression = 0.27f;
	CGFloat maxCompression = 0.07f;
	int maxFileSize = 100*1024;
	NSData *imgData = UIImageJPEGRepresentation(chosenImage, compression);
	while ([imgData length] > maxFileSize && compression >= maxCompression) {
		compression -= 0.10;
		imgData = UIImageJPEGRepresentation(chosenImage, compression);
	}
    [appSharedData setPickerImageData:imgData];
	self.strImageData= [helperUtils base64forData:imgData];
    NSString *str = [helperUtils getContentTypeForImageData:imgData];
    [appSharedData setStrFileExtension:str];
    UIImage *img;
    if (chosenImage.size.width > 50) {
		img = [chosenImage resizedImageToFitInSize:CGSizeMake(50, 50) scaleIfSmaller:YES];
		[self.imageViewAddPhoto setImage:img];
    }
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Other Methods
- (BOOL)isValidUserInput {
    
	NSString *strEmail = [self.txtfEmail.text stringByReplacingOccurrencesOfString:@" " withString:@""];
	NSString *strPassword = self.txtfPassword.text;
    if (strEmail.length < 1)	{
        [appSharedData showAlertView:@"" withMessage:@"Please enter email address" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
	}
    if (![ValidationManager validateEmailID:strEmail]) {
        [appSharedData showAlertView:@"" withMessage:kNotificationEmailNotValid withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
	}
    if (strPassword.length < 1) {
        [appSharedData showAlertView:@"" withMessage:@"Please enter password" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
	}
	if (![strPassword isEqualToString:self.txtfConfirmPassword.text]) {
        [appSharedData showAlertView:@"" withMessage:@"Password mismatch" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return NO;
    }
    return YES;
}

@end
