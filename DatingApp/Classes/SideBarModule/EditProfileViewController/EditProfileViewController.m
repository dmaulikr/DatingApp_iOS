//
//  EditProfileViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 01/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "EditProfileViewController.h"
#import "EditProfileCell.h"
#import "CustomTextField.h"
#import "ProfileDetails.h"
#import "UIImage+Resize.h"
#import "AsyncImageView.h"
#import "UserProfilePicture.h"
#import "LocalStorageService.h"
#import "CommonUtils.h"
#import "UIImageView+AFNetworking.h"

@interface EditProfileViewController ()<UITextFieldDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIGestureRecognizerDelegate> {
    
    ProfileDetails *objProfileDetails;
    NSDate *currentDOB;
    CommonUtils *helperUtils;
    
    int cancelButtonTag;
    int profilePictureTag;
    
    IBOutlet UIView *viewEditBox;
    IBOutlet UIView *viewDrinkMottos;
    IBOutlet UIView *viewProfilePictures;
    IBOutlet UIButton *btnThere;
    IBOutlet UIButton *btnBeer;
    IBOutlet UIButton *btnCheer;
    IBOutlet UIButton *btnWine;
}

@property (weak, nonatomic) IBOutlet CustomTextField *txtfName;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfHeadline;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfDOB;
@property (weak, nonatomic) IBOutlet CustomTextField *txtfAboutME;
@property (strong, nonatomic) UITextField *txtfGlobal;
@property (strong, nonatomic) NSString *strGender;

@property (weak, nonatomic) IBOutlet UIView *viewDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelDatePicker;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneDatePicker;

@property (strong, nonatomic) NSString *strFavouriteDrink;
@property (strong ,nonatomic) NSString *strSelectedProfilePictureName;
@property (strong ,nonatomic) NSString *strSelectedProfilePicturePath;
@property (strong ,nonatomic) NSString *strSelectedProfilePictureID;

@property (weak, nonatomic) IBOutlet UIButton *btnFemale;
@property (weak, nonatomic) IBOutlet UIButton *btnMale;

- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnFemaleTapped:(UIButton *)sender;
- (IBAction)btnMaleTapped:(UIButton *)sender;
- (IBAction)btnSaveProfileTapped:(UIButton *)sender;
- (IBAction)btnUploadPhoto:(UIButton *)sender;

- (IBAction)didTapCancelButtons:(UIButton *)sender;
- (IBAction)didTapDrinkMottoButtons:(UIButton *)sender;

@end

@implementation EditProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.strFavouriteDrink = @"";
    [self.btnMale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    
    profilePictureTag = 200;
    cancelButtonTag = 300;
    
    for (int i = 0; i < 5; i++) {
        UITapGestureRecognizer *singleFingerTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTapOnProfileImage:)];
        [[viewProfilePictures viewWithTag:(profilePictureTag + i)] addGestureRecognizer:singleFingerTap];
        singleFingerTap = nil;
    }
    
    objProfileDetails = [[LocalStorageService shared] getSavedAuthUserInfo];
    [self fetchUserInfo];
    
    helperUtils = [CommonUtils shared];
    [self.datePicker addTarget:self action:@selector(dateDidChange) forControlEvents:UIControlEventValueChanged];
    [self.datePicker setMinimumDate:[helperUtils convertStringToDate:@"1964-01-01" withFormat:@"yyyy-MM-dd"]];
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setYear:-18];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *maxDate = [calendar dateByAddingComponents:dateComponents toDate:[NSDate date] options:0];
    [self.datePicker setMaximumDate:maxDate];
}

- (void)didSingleTapOnProfileImage:(UITapGestureRecognizer *)recognizer {
    
    [self selectMainPicture:recognizer.view.tag];
}

- (void)selectMainPicture:(NSInteger)tag {

    int selectedIndex = tag - profilePictureTag;
    if ([appSharedData.arrUserProfilePics count] == 0 || selectedIndex >= [appSharedData.arrUserProfilePics count]) {
        return;
    }
    UserProfilePicture *obj = [appSharedData.arrUserProfilePics objectAtIndex:selectedIndex];
    self.strSelectedProfilePictureName = [NSString stringWithFormat:@"%@",[obj.strProfilePicture lastPathComponent]];
    self.strSelectedProfilePicturePath = obj.strProfilePicture;
    self.strSelectedProfilePictureID = obj.strPictureID;
    for (int i = 0; i < 5; i++) {
        UIImageView *imageView = (UIImageView *)[viewProfilePictures viewWithTag:(profilePictureTag + i)];
        if (profilePictureTag + i == tag) {
            imageView.layer.borderColor = [UIColor redColor].CGColor;
        } else {
            imageView.layer.borderColor = [UIColor clearColor].CGColor;
        }
        imageView.layer.borderWidth = 2.0;
    }
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    
    [self.txtfGlobal resignFirstResponder];
}

#pragma mark
#pragma mark Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note {
    
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    viewEditBox.frame = CGRectMake(viewEditBox.frame.origin.x, 185, viewEditBox.frame.size.width, viewEditBox.frame.size.height);
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [UIView beginAnimations: @"Fade In" context:nil];
    [UIView setAnimationDuration:.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    viewEditBox.frame = CGRectMake(viewEditBox.frame.origin.x, 205, viewEditBox.frame.size.width, viewEditBox.frame.size.height);
    [UIView commitAnimations];
}

- (void)changeDrinkMotto {
    
    int drinkChoice = -1;
    for (int i = 0; i < [kDrinkMottos count]; i++) {
        if ([self.strFavouriteDrink isEqualToString:[kDrinkMottos objectAtIndex:i]]) {
            drinkChoice = i;
        }
        UIButton *drinkMottoButton = (UIButton *)[viewDrinkMottos viewWithTag:100 + i];
        [drinkMottoButton setBackgroundImage:[UIImage imageNamed:@"check_out.png"] forState:UIControlStateNormal];
    }
    if (drinkChoice != -1) {
        UIButton *drinkMottoButton = (UIButton *)[viewDrinkMottos viewWithTag:100 + drinkChoice];
        [drinkMottoButton setBackgroundImage:[UIImage imageNamed:@"check_in.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - TextField Delegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    if (textField.tag == 22) {
        [self.txtfHeadline becomeFirstResponder];
    } else if (textField.tag == 23) {
        [self.txtfAboutME becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
	self.txtfGlobal = textField;
	return YES;
}

#pragma mark - DatePicker
- (IBAction)btnCalendarTapped:(UIButton *)sender {
    
	[self.txtfGlobal resignFirstResponder];
    NSDate *date = [helperUtils convertStringToDate:self.txtfDOB.text withFormat:@"yyyy-MM-dd"];
    if (date != nil) {
        self.datePicker.date = date;
    }
    [self toggleDatePicker:YES];
}

- (IBAction)cancelDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
}

- (IBAction)doneDatePickerTapped:(UIBarButtonItem *)sender {
    
    [self toggleDatePicker:NO];
    currentDOB = self.datePicker.date;
    if (currentDOB != nil) {
        [self.txtfDOB setText:[helperUtils convertDateToString:currentDOB withFormat:@"yyyy-MM-dd"]];
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

- (void)dateDidChange {
    
    currentDOB = self.datePicker.date;
}

# pragma mark - Button Methods
- (IBAction)didTapCancelButtons:(UIButton *)sender {
    
    int index = sender.tag - cancelButtonTag;
    UIImageView *imageView = (UIImageView *)[viewProfilePictures viewWithTag:profilePictureTag + index];
    UserProfilePicture *obj = [appSharedData.arrUserProfilePics objectAtIndex:index];
    [self deleteProfilePicture:[obj.strProfilePicture lastPathComponent] withImageID:obj.strPictureID withButton:sender withImageView:imageView];
}

- (IBAction)didTapDrinkMottoButtons:(UIButton *)sender {
    
    int index = -1;
    if (sender == btnThere) {
        index = 0;
    } else if (sender == btnBeer) {
        index = 1;
    } else if (sender == btnCheer) {
        index = 2;
    } else if (sender == btnWine) {
        index = 3;
    }
    if (index != -1) {
        self.strFavouriteDrink = kDrinkMottos[index];
        [self changeDrinkMotto];
    }
}

- (IBAction)btnBackTapped:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnMaleTapped:(UIButton *)sender {
    
    [self.txtfGlobal resignFirstResponder];
	self.strGender = @"Male";
    [self.btnMale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btnFemale setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)btnFemaleTapped:(UIButton *)sender {
    
    [self.txtfGlobal resignFirstResponder];
	self.strGender = @"Female";
    [self.btnFemale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.btnMale setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
}

- (IBAction)btnUploadPhoto:(UIButton *)sender {
    
    NSString *other1 = @"Gallery";
	NSString *other2 = @"Camera";
	NSString *cancelTitle = @"Cancel";
	UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"Upload Picture" delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:other1, other2, nil];
	[actionSheet showInView:self.view];
	actionSheet = nil;
}

- (IBAction)btnSaveProfileTapped:(UIButton *)sender {
    
    [self saveUserProfile];
}

- (void)fetchUserInfo {
    
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 objProfileDetails.strID, @"user_id", nil];
    [serviceManager executeServiceWithURL:UserProfilePicRequestUrl withUIViewController:self withTitle:@"Loading..."  forTask:kTaskUserProfilePic withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            [self parseResponseForUserProfilePictures:response];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
    
    [self.txtfName setText:objProfileDetails.strName];
    [self.txtfHeadline setText:objProfileDetails.strHeadLineCode];
    [self.txtfDOB setText:objProfileDetails.strDOB];
    [self.txtfAboutME setText:objProfileDetails.strAboutMe];
    self.strFavouriteDrink = objProfileDetails.strFavouriteDrink;
    if ([objProfileDetails.strGender isEqualToString:@"Male"]||[objProfileDetails.strGender isEqualToString:@"male"]) {
        [self.btnMale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        self.strGender = @"Male";
    } else {
        self.strGender = @"Female";
        [self.btnFemale setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    }
    [self changeDrinkMotto];
}

- (void)uploadPhoto {
    
    [appSharedData setIsUploadMedia:YES];
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 objProfileDetails.strID, @"user_id", nil];
    [serviceManager executeServiceWithURL:UploadProfilePicRequestUrl withUIViewController:self withTitle:@"Upload Photo"  forTask:kTaskUploadProfilePic withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            [self parseResponseForUserProfilePictures:response];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

- (void)saveUserProfile {
    
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 self.txtfName.text,                   @"name",
                                 self.txtfHeadline.text,               @"head_line_code",
                                 self.txtfDOB.text,                    @"dob",
                                 self.txtfAboutME.text,                @"about_me",
                                 self.strGender,                       @"gender",
                                 objProfileDetails.strID,              @"id",
                                 self.strFavouriteDrink,               @"favourite_drink",
                                 self.strSelectedProfilePictureName,   @"file_name",
                                 self.strSelectedProfilePictureID,     @"image_id",
                                 self.strSelectedProfilePicturePath,   @"file_path",
                                 nil];
    [serviceManager executeServiceWithURL:EditProfileRequestURL withUIViewController:self withTitle:@"Saving user profile..."  forTask:kTaskEditProfile withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            if (![[response objectForKey:@"result"] isKindOfClass:[NSNull class]]) {
                ProfileDetails *authUserInfo = [[ProfileDetails alloc] initWithDictionary:[response objectForKey:@"User"]];
                authUserInfo.password = objProfileDetails.password;
                authUserInfo.strDistance = @"0";
                [[LocalStorageService shared] saveAuthUserInfo:authUserInfo];
                [[NSNotificationCenter defaultCenter] postNotificationName:KCheckProfileIsUpdated object:nil];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

- (void)deleteProfilePicture:(NSString *)pictureName withImageID:(NSString *)imageID withButton:(UIButton *)btn withImageView:(UIImageView *)imgView {
    
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                 objProfileDetails.strID,   @"user_id",
                                 pictureName,               @"pic_name",
                                 imageID,                   @"image_id", nil];
    [serviceManager executeServiceWithURL:DeleteProfilePicRequestUrl withUIViewController:self withTitle:@"Deleting Profile Pic"  forTask:kTaskDeleteProfilePic withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task){
        if (!error) {
            [self parseResponseForUserProfilePictures:response];
            objProfileDetails.strProfilePicture = @"";
            [[LocalStorageService shared] saveAuthUserInfo:objProfileDetails];
            [[NSNotificationCenter defaultCenter] postNotificationName:KCheckProfileIsUpdated object:nil];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

- (void)parseResponseForUserProfilePictures:(id)response {
    
    NSMutableArray *result = [NSMutableArray array];
    if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
        for (id dictionary in [response objectForKey:@"Images"]) {
            UserProfilePicture *obj = [[UserProfilePicture alloc] initWithDictionary:dictionary];
            [result addObject:obj];
            obj = nil;
        }
        [appSharedData setArrUserProfilePics:result];
        [self setImageInUserProfilePics];
        return;
    }
    [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
}

- (void)setImageInUserProfilePics {

    for (int i = 0; i < 5; i ++) {
        UserProfilePicture *profilePic = nil;
        if (i < [appSharedData.arrUserProfilePics count]) {
            profilePic = [appSharedData.arrUserProfilePics objectAtIndex:i];;
        }
        [viewProfilePictures viewWithTag:(cancelButtonTag + i)].hidden = (profilePic == nil);
        UIImageView *imgProfile = (UIImageView *)[viewProfilePictures viewWithTag:(profilePictureTag + i)];
        UIImage *blankImage = [UIImage imageNamed:@"no_image_available.png"];
        if (profilePic != nil) {
            [imgProfile setImageWithURLString:profilePic.strProfilePicture placeholderImage:blankImage toScaledSize:imgProfile.bounds.size];
        } else {
            [imgProfile setImage:blankImage];
        }
    }
}

#pragma mark - UIActionSheet delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if ([appSharedData.arrUserProfilePics count] >= 5) {
        [appSharedData showAlertView:@"" withMessage:kNotificationProfilePicsLimit withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
        return;
    }
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
	[picker dismissViewControllerAnimated:YES completion:nil];
    [self uploadPhoto];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
	
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
