//
//  ProfileViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 01/10/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ProfileViewController.h"
#import "AsyncImageView.h"
#import "UserAllProfilePics.h"
#import "UIImageView+AFNetworking.h"
#import "LocalStorageService.h"
#import "ChatViewController.h"

@interface ProfileViewController () <QBActionStatusDelegate> {
    BOOL REQUEST_NEW_DIALOG;
    QBChatDialog *currentDialog;
}

@property (weak, nonatomic) IBOutlet AsyncImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblNameAgeSex;
@property (weak, nonatomic) IBOutlet UILabel *lblHeadlinecode;
@property (weak, nonatomic) IBOutlet UILabel *lblDistance;
@property (weak, nonatomic) IBOutlet UILabel *lblaboutME;
@property (weak, nonatomic) IBOutlet UILabel *lblFavourite;
@property (strong, nonatomic) NSMutableArray *photos;

- (IBAction)btnBackTapped:(UIButton *)sender;
- (IBAction)btnPicsTapped:(UIButton *)sender;
- (IBAction)didTapMessageButton:(UIButton *)sender;
- (IBAction)didTapGameButton:(UIButton *)sender;

@end

@implementation ProfileViewController

@synthesize userProfile;

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
    [self populateViewContent];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

#pragma mark - MBPhotoBrowser Delegate
- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
    
}

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    
    return self.photos.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    
    if (index < self.photos.count)
        return [self.photos objectAtIndex:index];
    return nil;
}

#pragma mark - UIButton Methods
- (IBAction) btnBackTapped:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)btnPicsTapped:(UIButton *)sender {
    
    NSDictionary * dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  self.userProfile.strID, @"user_id", nil];
    [serviceManager executeServiceWithURL:GetUserAllProfilePicsRequestUrl withUIViewController:self withTitle:@"Getting Photo"  forTask:kTaskGetUserAllProfilePics withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            if (![[response objectForKey:@"result"] isKindOfClass:[NSNull class]]) {
                NSMutableDictionary *parsedData = [parsingManager parseResponse:response forTask:task];
                if ([[parsedData objectForKey:@"result"] isEqualToString:@"Success"]) {
                    if ([[appSharedData arrUserAllProfilePicture] count]>0) {
                        self.photos = [NSMutableArray array];
                        for (int i = 0; i < [[appSharedData arrUserAllProfilePicture] count]; i++) {
                            UserAllProfilePics *Obj=[[appSharedData arrUserAllProfilePicture] objectAtIndex:i];
                            [self.photos addObject:[MWPhoto photoWithURL:[NSURL URLWithString:Obj.strProfilePicture]]];
                        }
                        [self.photos exchangeObjectAtIndex:0 withObjectAtIndex:0];//me
                        
                        // Create & present browser
                        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
                        // Set options
                        browser.displayActionButton = NO; // Show action button to allow sharing, copying, etc (defaults to YES)
                        browser.displayNavArrows = YES; // Whether to display left and right nav arrows on toolbar (defaults to NO)
                        browser.zoomPhotosToFill = YES; // Images that almost fill the screen will be initially zoomed to fill (defaults to YES)
                        //[browser setCurrentPhotoIndex:browser.currentIndex]; // Example: allows second image to be presented first
                        browser.wantsFullScreenLayout = YES; // iOS 5 & 6 only: Decide if you want the photo browser full screen, i.e. whether the status bar is affected (defaults to YES)
                        
                        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
                        [self presentViewController:nc animated:NO completion:nil];
                        
                        // Manipulate!
                        [browser showPreviousPhotoAnimated:YES];
                        browser=nil;
                    }
                }
                else
                    [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
            }
            else
                [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
        }
        else
            if([appSharedData isErrorOrFailResponse])
                [appSharedData setIsErrorOrFailResponse:NO];
    }];
}

// Populate user profile on the view
- (void)populateViewContent{
    
    // load user profile image
    [self.imgProfilePic setImageWithURLString:userProfile.strProfilePicture placeholderImage:[UIImage imageNamed:@"no_image_available.png"] toScaledSize:self.imgProfilePic.bounds.size];
    long years = [appSharedData getAgeFromBirthday:userProfile.strDOB];
    
    // display user distance info
    if ([userProfile.strDistance isEqualToString:KNullValue]) {
        [self.lblDistance setText:@"n/a"];
    } else {
        int distance = floorf([userProfile.strDistance floatValue] * 10.0f);
        [self.lblDistance setText:[NSString stringWithFormat:@"%g miles", distance / 10.0f]];
    }
    
    [self.lblNameAgeSex setText:[NSString stringWithFormat:@"%@, %ld", userProfile.strName, years]];
    if (!(userProfile.strHeadLineCode.length <= 0 || [userProfile.strHeadLineCode isEqualToString:KNullValue])) {
        [self.lblHeadlinecode setText:[NSString stringWithFormat:@"\"%@\"", userProfile.strHeadLineCode]];
    } else {
        [self.lblHeadlinecode setText:@""];
    }

    [self.lblaboutME setText:userProfile.strAboutMe];
    [self.lblFavourite setText:userProfile.strFavouriteDrink];
    [self.lblFavourite sizeToFit];
}

// Shows chat page when user taps on Message Button
- (IBAction)didTapMessageButton:(UIButton *)sender {
    
    if (self.fromChatSession) {
        [self btnBackTapped:nil];
        return;
    }
    [appSharedData showCustomLoaderWithTitle:@"Starting chat" message:@"please wait..." onView:self.view];
    currentDialog = nil;
    REQUEST_NEW_DIALOG = NO;
    if ([appSharedData.arrDialogs count] > 0) {
        currentDialog = [appSharedData getSessionDailogFromArray:[userProfile getQuickbloxUserID]];
        if (currentDialog != nil) {
            [self navigateToChatPage];
            return;
        }
    }
    [QBChat dialogsWithExtendedRequest:nil delegate:self];
}

#pragma mark -
#pragma mark QBActionStatusDelegate

// QuickBlox API queries delegate
- (void)completedWithResult:(Result *)result{
    if (result.success) {
        NSUInteger opponentID = [userProfile getQuickbloxUserID];
        if (REQUEST_NEW_DIALOG == NO) {
            QBDialogsPagedResult *pagedResult = (QBDialogsPagedResult *)result;
            NSArray *dialogs = pagedResult.dialogs;
            appSharedData.arrDialogs = [dialogs mutableCopy];
            currentDialog = [appSharedData getSessionDailogFromArray:opponentID];
            if (currentDialog != nil) {
                [self navigateToChatPage];
            } else {
                // Create new dialog
                REQUEST_NEW_DIALOG = YES;
                QBChatDialog *chatDialog = [QBChatDialog new];
                chatDialog.occupantIDs = @[@(opponentID)];
                chatDialog.type = QBChatDialogTypePrivate;
                [QBChat createDialog:chatDialog delegate:self];
            }
        } else {
            QBChatDialogResult *dialogRes = (QBChatDialogResult *)result;
            currentDialog = dialogRes.dialog;
            [appSharedData.arrDialogs addObject:currentDialog];
            [self navigateToChatPage];
        }
    } else {
        [appSharedData removeLoadingView];
        [appSharedData showToastMessage:@"Failed to create chat session, try again" onView:self.view];
    }
}

// Navigates to main chat screen
- (void)navigateToChatPage {
    [appSharedData removeLoadingView];
    [appSharedData setSelectedRecipient:userProfile];
    [appSharedData setCreatedDialog:currentDialog];
    
    ChatViewController *chatController = [[self storyboard] instantiateViewControllerWithIdentifier:@"ChatViewController"];
    chatController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:chatController animated:YES];
}

- (IBAction)didTapGameButton:(UIButton *)sender {
    
    // Send game invitation
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    NSString *recipientIDs = userProfile.quickbloxUserID;
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setObject:@"game_invite" forKey:@"tag"];
    [message setObject:authUserInfo.strID forKey:@"opponent_id"];
    [message setObject:[NSString stringWithFormat:@"%@ made new game invite to you", authUserInfo.strName] forKey:@"body"];
    [appSharedData showCustomLoaderWithTitle:nil message:@"Sending invite..." onView:self.view];
    [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
        [appSharedData removeLoadingView];
        [appSharedData setGameStatus:kWaitingOpponent];
        [self navigateToGamePage];
    } errorBlock:^(QBError *error) {
        [appSharedData removeLoadingView];
        [appSharedData showToastMessage:@"Failed to send invite" onView:self.view];
        [Flurry logError:@"DrinkingGame_Invite_Error" message:@"DrinkingGame_Invite_Error" error:nil];
    }];
}

// Navigates to game page
- (void)navigateToGamePage {
    [appSharedData setSelectedRecipient:userProfile];
    self.tabBarController.selectedIndex = 3;
}

@end
