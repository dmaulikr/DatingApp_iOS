//
//  PostCommentViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/10/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "PostCommentViewController.h"
#import "EventComment.h"
#import "AsyncImageView.h"
#import "ProfileViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CommonUtils.h"
#import "LocalStorageService.h"

@interface PostCommentViewController ()<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UITextViewDelegate> {
    NSMutableArray *commentsList;
    CommonUtils *helperUtils;
    NSString *userID;
}

@property (weak, nonatomic) IBOutlet UITextField *txtFieldComment;
@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UITextView *txtView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)didTapPostButton:(UIButton *)sender;
- (IBAction)btnBackTapped:(UIButton *)sender;

@end

@implementation PostCommentViewController

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
    
    commentsList = [NSMutableArray array];
    helperUtils = [CommonUtils shared];
    userID = [[LocalStorageService shared] getSavedAuthUserInfo].strID;
    [self fetchAllComments];
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    self.txtFieldComment.delegate = self;
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

-(void) viewWillLayoutSubviews{
    
    [super viewWillLayoutSubviews];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidHideNotification object:nil];
}

#pragma mark
#pragma mark Keyboard notifications

- (void)keyboardWillShow:(NSNotification *)note {

    [self.scrollView setContentOffset:CGPointMake(0, 205) animated:YES];
}

- (void)keyboardWillHide:(NSNotification *)note {
    
    [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}

#pragma mark Button Methods
- (IBAction)btnBackTapped:(UIButton *)sender{
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapPostButton:(UIButton *)sender {
    
    if (self.txtFieldComment.text.length == 0) {
        return;
    }
    [self.txtFieldComment resignFirstResponder];
    [self postComment];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [commentsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    EventComment *obj = [[appSharedData arrComments] objectAtIndex:indexPath.row];
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:COMMENT_LIST_ITEM_IDENTIFIER];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:COMMENT_LIST_ITEM_IDENTIFIER];
    }
    
    // set background image
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    
    // set user profile image
    UIImageView *profileImage = (UIImageView *)[cell viewWithTag:1];
    profileImage.layer.cornerRadius = 30.0;
    profileImage.layer.masksToBounds = YES;
    [profileImage setImageWithURL:[NSURL URLWithString:obj.strUserPicture] placeholderImage:[UIImage imageNamed:@"no_image_available.png"]];

    // set user name
    UILabel *lblUserName = (UILabel *)[cell viewWithTag:2];
    [lblUserName setText:obj.strUserName];
    
    // set posted date
    UILabel *lblPostedDate = (UILabel *)[cell viewWithTag:3];
    NSDate *postedDate = [helperUtils convertStringToDate:obj.strCommentDateTime withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *now = [NSDate date];
    NSDateComponents *postedComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:postedDate];
    NSDateComponents *nowComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear fromDate:now];
    NSString *dateTimeString;
    if ([postedComponents day] == [nowComponents day] &&
        [postedComponents month] == [nowComponents month] &&
        [postedComponents year] == [postedComponents year]) {
        dateTimeString = [helperUtils convertDateToString:postedDate withFormat:@"hh:mm a"];
    } else {
        dateTimeString = [helperUtils convertDateToString:postedDate withFormat:@"MMM dd, yyyy | hh:mm a"];
    }
    [lblPostedDate setText:dateTimeString];
    
    // shows comment
    UILabel *lblComment = (UILabel *)[cell viewWithTag:4];
    [lblComment setText:obj.strComment];
    [lblComment sizeToFit];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([userID isEqualToString:self.objEvent.strEventUserId]) {
        return YES;
    }
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        EventComment *eventComment = [commentsList objectAtIndex:indexPath.row];
        NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                      eventComment.strId, @"comment_id", nil];
        [serviceManager executeServiceWithURL:URL_DELETE_COMMENT withUIViewController:self withTitle:@"Fetch comments" forTask:kTaskGetComment withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
            if (!error) {
                if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                    [commentsList removeObject:eventComment];
                    [self.tblView reloadData];
                    return;
                }
                [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            } else {
                [appSharedData showToastMessage:@"Connection error" onView:self.view];
            }
        }];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init] ;
    [view setBackgroundColor:[UIColor clearColor]];
    [view setFrame:CGRectMake(0, 0, 210, 0.1)];
    return view;
}

- (void)fetchAllComments {
    
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.objEvent.strEventId, @"event_id", nil];
    [serviceManager executeServiceWithURL:GetCommentRequestUrl withUIViewController:self withTitle:@"Fetch comments" forTask:kTaskGetComment withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            NSMutableArray *result = [NSMutableArray array];
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                for (id dictionary in [response objectForKey:@"Comment"]) {
                    [result addObject:[[EventComment alloc] initWithDictionary:dictionary]];
                }
                [appSharedData setArrComments:result];
                commentsList = result;
            }
            [self.tblView reloadData];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
     }];
}

#pragma mark
#pragma TextField Delegate methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField {

	[textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {

	return YES;
}

- (BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    NSCharacterSet *doneButtonCharacterSet = [NSCharacterSet newlineCharacterSet];
    NSRange replacementTextRange = [string rangeOfCharacterFromSet:doneButtonCharacterSet];
    NSUInteger location = replacementTextRange.location;
    if (textField.text.length + string.length > 100) {
		if (location != NSNotFound) {
			[textField resignFirstResponder];
		}
		return NO;
    } else if (location != NSNotFound) {
		[textField resignFirstResponder];
		return NO;
    }
    return YES;
}

// Send request to server in order to post comment
- (void)postComment {
    
    NSDate *now = [NSDate date];
    NSString *postedDate = [helperUtils convertDateToString:now withFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[LocalStorageService shared] getSavedAuthUserInfo].strID,    @"user_id",
                                  self.objEvent.strEventId,                                     @"event_id",
                                  self.txtFieldComment.text,                                    @"comment",
                                  postedDate,                                                   @"created",
                                  nil];
    [serviceManager executeServiceWithURL:PostCommentRequestUrl withUIViewController:self withTitle:@"Posting Comment"  forTask:kTaskPostComment withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                [self fetchAllComments];
                [self.txtFieldComment setText:@""];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            [Flurry logError:@"Post_Comment_Error" message:@"Post_Comment_Error" error:nil];
        } else {
            [appSharedData showToastMessage:@"connection error" onView:self.view];
        }
    }];
}

@end
