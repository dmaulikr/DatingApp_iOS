//
//  CreatEventViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 13/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "CreatEventViewController.h"
#import "CustomTextField.h"
#import "EventPicture.h"
#import "LocalStorageService.h"
#import "UIImageView+AFNetworking.h"
#import "CommonUtils.h"
#import "NSDate+Compare.h"

@interface CreatEventViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate> {
    
    NSDate *selectedEventDate;
    NSDate *selectedEventStartTime;
    NSDate *selectedEventEndTime;
    
    CommonUtils *helperUtils;
}

@property (weak, nonatomic) IBOutlet UIButton *btnUpdateEvent;
@property (weak, nonatomic) IBOutlet UIButton *btnCreateEvent;
@property (weak, nonatomic) IBOutlet UIView *viewUploadPhoto;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UIView *viewTextFields;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEventName;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEventDate;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEventLocation;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEventAddress;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEventDetails;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfStartTime;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfEndTime;
@property (weak, nonatomic) IBOutlet UILabel *txtfInviteRadius;
@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (strong, nonatomic) UITextField *txtfGlobal;

//Date Picker
@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneDatePicker;

@property (weak, nonatomic) IBOutlet UIButton *btnStartTime;
@property (weak, nonatomic) IBOutlet UIButton *btnEndTime;
@property (weak, nonatomic) IBOutlet UIButton *btnEventDate;
@property (assign, nonatomic) BOOL isDatePicker;
@property (assign, nonatomic) BOOL isStartTime;
@property (assign, nonatomic) BOOL isEndTime;
@property (strong, nonatomic) NSString *strStartDateTime;
@property (strong, nonatomic) NSString *strEndDateTime;

@property (strong, nonatomic) IBOutlet UIImageView *eventImage;

- (IBAction)btnStartTimeTapped:(UIButton *)sender;
- (IBAction)btnEndTimeTapped:(UIButton *)sender;
- (IBAction)btnUploadPhotoTapped:(id)sender;
- (IBAction)btnEventDateTapped:(UIButton *)sender;
- (IBAction)cancelDatePickerTapped:(UIBarButtonItem *)sender;
- (IBAction)doneDatePickerTapped:(UIBarButtonItem *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)sliderValueChanged:(id)sender;

- (IBAction)btnCreateEventTapped:(UIButton *)sender;
- (IBAction)btnUpdateEventTapped:(UIButton *)sender;

@end

@implementation CreatEventViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self initViewAndClassMembers];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)initViewAndClassMembers {
    
    helperUtils = [CommonUtils shared];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTapUploadImage)];
    [self.eventImage addGestureRecognizer:singleTap];
    singleTap = nil;
    
    if ([self.strIdentifier isEqualToString:@"UPDATE"]) {
        [self.lblTitle setText:@"Update Event"];
        [self.btnCreateEvent setHidden:YES];
        [self.txtfEventName setText:self.objEvent.strEventName];
        
        selectedEventStartTime = [helperUtils convertStringToDate:self.objEvent.strEventStartTime withFormat:@"HH:mm:ss"];
        [self.txtfStartTime setText:[helperUtils convertDateToString:selectedEventStartTime withFormat:@"hh:mm a"]];
        
        if (![self.objEvent.strEventEndTime isEqualToString:KNullValue]) {
            selectedEventEndTime = [helperUtils convertStringToDate:self.objEvent.strEventEndTime withFormat:@"HH:mm:ss"];
            [self.txtfEndTime setText:[helperUtils convertDateToString:selectedEventEndTime withFormat:@"hh:mm a"]];
        }
        
        [self.txtfEventDate setText:self.objEvent.strEventStartDate];
        [self.txtfEventLocation setText:self.objEvent.strEventLocation];
        [self.txtfEventAddress setText:self.objEvent.strEventAddress];
        [self.txtfEventDetails setText:self.objEvent.strEventDetails];
        
        [self.btnCreateEvent setHidden:YES];
        [self.btnUpdateEvent setHidden:NO];
        [self.eventImage setImageWithURLString:self.objEvent.strEventPicPath placeholderImage:[UIImage imageNamed:@"defaultevent_icon.png"] toScaledSize:self.eventImage.bounds.size];
        [self.radiusSlider setValue:[self.objEvent.strInviteRadius floatValue]];
        [self.txtfInviteRadius setText:self.objEvent.strInviteRadius];
        [self.radiusSlider setUserInteractionEnabled:NO];
    } else if ([self.strIdentifier isEqualToString:@"CREATE"]) {
        [self.lblTitle setText:@"Create Event"];
        [self.btnCreateEvent setHidden:NO];
        [self.btnUpdateEvent setHidden:YES];
        [self.radiusSlider setUserInteractionEnabled:YES];
        [self.radiusSlider setValue:3.0];
    }
}

#pragma mark
#pragma mark Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note {
    
    if (self.txtfGlobal == self.txtfEventName) {
        return;
    }
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.viewTextFields.frame = CGRectMake(self.viewTextFields.frame.origin.x, 45, self.viewTextFields.frame.size.width, self.viewTextFields.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    if (self.txtfGlobal == self.txtfEventName) {
        return;
    }
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.viewTextFields.frame = CGRectMake(self.viewTextFields.frame.origin.x, 142, self.viewTextFields.frame.size.width, self.viewTextFields.frame.size.height);
    [UIView commitAnimations];
}

- (void)didTapUploadImage {
    
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
	if(textField.tag == 29)
		[self btnEventDateTapped:self.btnEventDate];
	else if(textField.tag == 33)
        [self.txtfEventAddress becomeFirstResponder];
    else if(textField.tag == 34)
        [self.txtfEventDetails becomeFirstResponder];
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
	self.txtfGlobal = textField;
	return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
	[self.txtfGlobal resignFirstResponder];
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    self.viewTextFields.frame = CGRectMake(self.viewTextFields.frame.origin.x, 142, self.viewTextFields.frame.size.width, self.viewTextFields.frame.size.height);
    [UIView commitAnimations];
}

#pragma mark - Button Methods
- (IBAction)btnBackTapped:(UIButton *)sender {
    
    [self navigateBack];
}

- (IBAction)btnCreateEventTapped:(UIButton *)sender {
    
    [self.txtfGlobal resignFirstResponder];
    [self checkAndPostRequest];
}

- (IBAction)btnUploadPhotoTapped:(id)sender {
    
    [self didTapUploadImage];
}

- (void)navigateBack {
    
    [self.navigationController popViewControllerAnimated:YES];
}

// Check user input and send create event request to server
- (void)checkAndPostRequest {
    
    if (self.txtfEventName.text.length == 0 || self.txtfEventDate.text.length == 0 ||
        self.txtfEventLocation.text.length == 0 || self.txtfEventDetails.text.length == 0 ||
        self.txtfEventAddress.text.length == 0 || self.txtfStartTime.text.length == 0) {
        [appSharedData showToastMessage:kNotificationMissedInput onView:self.view];
        return;
    }
    
    NSString *strEventDate = [helperUtils convertDateToString:selectedEventDate withFormat:@"yyyy-MM-dd"];
    NSString *strEventStartTime = [helperUtils convertDateToString:selectedEventStartTime withFormat:@"HH:mm:ss"];
    NSString *strEventEndTime;
    if (selectedEventEndTime == nil) {
        strEventEndTime = @"";
    } else {
        strEventEndTime = [helperUtils convertDateToString:selectedEventEndTime withFormat:@"HH:mm:ss"];
    }
    NSString *userID = [[LocalStorageService shared] getSavedAuthUserInfo].strID;
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  userID ,                      @"user_id",
                                  self.txtfEventName.text,      @"name",
                                  strEventDate,                 @"start_date",
                                  strEventStartTime,            @"start_time",
                                  strEventEndTime,              @"end_time",
                                  self.txtfEventLocation.text,  @"location",
                                  self.txtfEventAddress.text,   @"address",
                                  self.txtfEventDetails.text,   @"event_details",
                                  self.txtfInviteRadius.text,   @"invite_radius",
                                  nil];
    [serviceManager executeServiceWithURL:CreateEventRequestURL withUIViewController:self withTitle:@"Uploading new event" forTask:kTaskCreateEvent withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error){
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]){

                ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
                // Send analytics to Flurry
                NSDictionary *analytics = [NSDictionary dictionaryWithObjectsAndKeys:
                                           @"New Event Created", @"notification",
                                           authUserInfo.strName, @"user_name",
                                           authUserInfo.strEmail, @"user_email", nil];
                [Flurry logEvent:@"New Event Created" withParameters:analytics];
                
                NSMutableArray *nearUsers = [NSMutableArray array];
                for (id userDict in [response objectForKey:@"near_users"]) {
                    [nearUsers addObject:[[ProfileDetails alloc] initWithDictionary:userDict]];
                }
                if ([nearUsers count] > 0) {
                    NSString *recipientIDs = @"";
                    for (ProfileDetails *user in nearUsers) {
                        recipientIDs = [recipientIDs stringByAppendingString:[NSString stringWithFormat:@",%@", user.quickbloxUserID]];
                    }
                    recipientIDs = [recipientIDs substringFromIndex:1];
                    
                    NSString *createdEventID = [response objectForKey:@"new_id"];
                    NSMutableDictionary *message = [NSMutableDictionary dictionary];
                    [message setObject:@"event_invite" forKey:@"tag"];
                    [message setObject:createdEventID forKey:@"event_id"];
                    [message setObject:self.txtfEventName.text forKey:@"event_name"];
                    [message setObject:@"You have new event invite" forKey:@"body"];
                    [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
                    } errorBlock:^(QBError *error) {
                        [appSharedData showToastMessage:@"Failed to send invite to other users" onView:self.view];
                        [Flurry logError:@"New_Event_Invite_Error" message:@"New_Event_Invite_Error" error:nil];
                    }];
                }
                [appSharedData setIsEventListUpdated:YES];
                [self navigateBack];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            [Flurry logError:@"Create_Event_Error" message:@"Create_Event_Error" error:nil];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
        }
    }];
}

#pragma mark - UIActionSheet delegate Method

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType =UIImagePickerControllerSourceTypePhotoLibrary;
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
    [self.eventImage setImage:[helperUtils cropImage:chosenImage scaledToSize:self.eventImage.bounds.size]];
	CGFloat compression = 0.27f;
	CGFloat maxCompression = 0.07f;
	int maxFileSize = 100*1024;
	NSData *imgData = UIImageJPEGRepresentation(chosenImage, compression);
	while ([imgData length] > maxFileSize && compression >= maxCompression)	{
		compression -= 0.10;
		imgData = UIImageJPEGRepresentation(chosenImage, compression);
	}
    [appSharedData setPickerImageData:imgData];
    NSString *str = [helperUtils getContentTypeForImageData:imgData];
    [appSharedData setStrFileExtension:str];
    
    [appSharedData setIsUploadMedia:YES];
	[picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DatePicker
- (IBAction)btnEventDateTapped:(UIButton *)sender {
    
    self.datePicker.datePickerMode = UIDatePickerModeDate;
    self.isDatePicker = YES;
    self.isStartTime = NO;
    self.isEndTime = NO;
	[self.txtfGlobal resignFirstResponder];
    if (self.txtfEventDate.text.length == 0) {
        self.datePicker.date = [NSDate date];
    } else {
        self.datePicker.date = [helperUtils convertStringToDate:self.txtfEventDate.text withFormat:@"yyyy-MM-dd"];
    }
    [self toggleDatePicker:YES];
}

- (IBAction)btnStartTimeTapped:(UIButton *)sender {
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.isDatePicker = NO;
    self.isStartTime = YES;
    self.isEndTime = NO;
    [self.txtfGlobal resignFirstResponder];
    if (self.txtfStartTime.text.length == 0) {
        self.datePicker.date = [NSDate date];
    } else {
        self.datePicker.date = [helperUtils convertStringToDate:self.txtfStartTime.text withFormat:@"hh:mm a"];
    }
    [self toggleDatePicker:YES];
}

- (IBAction)btnEndTimeTapped:(UIButton *)sender {
    
    self.datePicker.datePickerMode = UIDatePickerModeTime;
    self.isDatePicker = NO;
    self.isStartTime = NO;
    self.isEndTime = YES;
    [self.txtfGlobal resignFirstResponder];
    if (self.txtfEndTime.text.length == 0) {
        self.datePicker.date = [NSDate date];
    } else {
        self.datePicker.date = [helperUtils convertStringToDate:self.txtfEndTime.text withFormat:@"hh:mm a"];
    }
    [self toggleDatePicker:YES];
}

- (IBAction)cancelDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
}

- (IBAction)doneDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
    if (self.isDatePicker) {
        selectedEventDate = self.datePicker.date;
        if (selectedEventDate != nil) {
            [self.txtfEventDate setText:[helperUtils convertDateToString:selectedEventDate withFormat:@"yyyy-MM-dd"]];
        }
    } else if (self.isStartTime) {
        if ([selectedEventEndTime isEarlierTimeThan:self.datePicker.date]) {
            [appSharedData showAlertView:@"" withMessage:@"End time must be later than start time" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
            return;
        }
        selectedEventStartTime = self.datePicker.date;
        if (selectedEventStartTime != nil) {
            [self.txtfStartTime setText:[helperUtils convertDateToString:selectedEventStartTime withFormat:@"hh:mm a"]];
        }
    } else if (self.isEndTime) {
        if ([self.datePicker.date isEarlierTimeThan:selectedEventStartTime]) {
            [appSharedData showAlertView:@"" withMessage:@"End time must be later than start time" withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
            return;
        }
        selectedEventEndTime = self.datePicker.date;
        if (selectedEventEndTime != nil) {
            [self.txtfEndTime setText:[helperUtils convertDateToString:selectedEventEndTime withFormat:@"hh:mm a"]];
        }
    }
}

- (IBAction)sliderValueChanged:(id)sender {
    
    [self.txtfInviteRadius setText:[NSString stringWithFormat:@"%d", (int)self.radiusSlider.value]];
}

- (void)dateDidChange {
}

- (IBAction)btnUpdateEventTapped:(UIButton *)sender {
    
    [self.txtfGlobal resignFirstResponder];
    if(self.txtfEventName.text.length > 0 && self.txtfEventDate.text.length > 0 && self.txtfStartTime.text.length > 0 && self.txtfEventLocation.text.length > 0 && self.txtfEventAddress.text.length > 0 && self.txtfEventDetails.text.length > 0) {
        [appSharedData setIsUploadMedia:YES];
        NSString *userID = [[LocalStorageService shared] getSavedAuthUserInfo].strID;
        NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                      userID,                       @"user_id",
                                      self.objEvent.strEventId,     @"event_id",
                                      self.txtfEventName.text,      @"name",
                                      self.txtfEventDate.text,      @"start_date",
                                      self.txtfStartTime.text,      @"start_time",
                                      self.txtfEndTime.text,        @"end_time",
                                      self.txtfEventLocation.text,  @"location",
                                      self.txtfEventAddress.text,   @"address",
                                      self.txtfEventDetails.text,   @"event_details",
                                      self.txtfInviteRadius.text,   @"invite_radius",
                                      nil];
        [serviceManager executeServiceWithURL:UpdateEventRequestUrl withUIViewController:self withTitle:@"Updating Event" forTask:kTaskUpdateEvent withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
            if (!error) {
                if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                    [appSharedData setIsEventListUpdated:YES];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                    return;
                }
                [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            } else {
                [appSharedData showToastMessage:@"connection error" onView:self.view];
            }
        }];
    } else {
        [appSharedData showToastMessage:kNotificationMissedInput onView:self.view];
    }
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

@end
