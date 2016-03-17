//
//  DiceGameViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "DiceGameViewController.h"
#import "SideBarViewController.h"
#import "LocalStorageService.h"
#import "GameHistoryViewController.h"

@interface DiceGameViewController () <UIAlertViewDelegate, SideBarViewControllerDelegate> {
    float radiansOfWheel;
    float angularSpeed;
    NSTimer *theTimer;
    NSArray *activitiesCommands;
    NSArray *activityNumbers;
    NSString *prompt;
    
    BOOL isSideMenuVisible;
    SideBarViewController *objSBVC;
}

@property (weak, nonatomic) IBOutlet UIView *viewSideBar;
@property (weak, nonatomic) IBOutlet UIView *viewDiceGame;
@property (strong, nonatomic) IBOutlet UIImageView *theRoulette;

@property (strong, nonatomic) IBOutlet UILabel *titleNote;
@property (strong, nonatomic) IBOutlet UIButton *spinButton;

- (IBAction)btnSplitTapped:(UIButton *)sender;
- (IBAction)didTapFinishButton:(UIButton *)sender;
- (IBAction)didTapSpinButton:(UIButton *)sender;

@end

@implementation DiceGameViewController

@synthesize spinButton;

#define SPIN_INTERVAL 1.0 / 60.0
#define SPIN_START_SPEED_MAX 0.4
#define SPIN_START_SPEED_MIN 0.35
#define SPIN_DECELLERATION 0.001

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    [self initViewAndClassMembers];
}

- (void)initViewAndClassMembers {
    
    radiansOfWheel = 0.0;
    activitiesCommands = [NSArray arrayWithObjects:
                          @"Chug then freestyle rap",
                          @"Drink while humming a song",
                          @"Touch your nipple",
                          @"Get the person to your right a drink",
                          @"Get the person to your left a drink",
                          @"Drink on one leg",
                          @"Take a shot then shout victory",
                          @"Everybody drinks",
                          @"Take a drink then tell a joke",
                          @"Sing a song",
                          @"Drink in slow motion",
                          @"Nobody drinks",
                          nil];
    activityNumbers = @[@12, @6, @1, @10, @4, @8, @2, @5, @11, @3, @7, @9];
    
    objSBVC = (SideBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SideBarViewController"];
    [objSBVC setDelegate:self];
    [objSBVC setStrClassIdentifier:@"DiceGameViewController"];
    [self.viewSideBar addSubview:objSBVC.view];
    isSideMenuVisible = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    [self changeStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    if (isSideMenuVisible) {
        [self toggleSideMenu];
    }
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

// Toggle slide menu
- (void)toggleSideMenu {
    
    if (!isSideMenuVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.viewSideBar.frame = CGRectMake(0, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewDiceGame.frame = CGRectMake(210, self.viewDiceGame.frame.origin.y, self.viewDiceGame.frame.size.width, self.viewDiceGame.frame.size.height);
        [UIView commitAnimations];
        isSideMenuVisible = YES;
    } else {
        [UIView beginAnimations: @"Fade In" context:nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.viewSideBar.frame = CGRectMake(-210, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewDiceGame.frame = CGRectMake(0, self.viewDiceGame.frame.origin.y, self.viewDiceGame.frame.size.width, self.viewDiceGame.frame.size.height);
        [UIView commitAnimations];
        [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        isSideMenuVisible = NO;
    }
}

#pragma mark - Button Delegate Methods
- (IBAction)btnSplitTapped:(UIButton *)sender {
    
    [self toggleSideMenu];
}

- (IBAction)didTapFinishButton:(UIButton *)sender {
    
    if ([appSharedData getGameStatus] == kNotConnected)
        return;
    ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    NSString *recipientIDs = appSharedData.currentGameOpponent.quickbloxUserID;
    NSMutableDictionary *message = [NSMutableDictionary dictionary];
    [message setObject:@"game_finish" forKey:@"tag"];
    [message setObject:authUserInfo.strID forKey:@"opponent_id"];
    [message setObject:[NSString stringWithFormat:@"%@ ended game", authUserInfo.strName] forKey:@"body"];
    [appSharedData showCustomLoaderWithTitle:nil message:@"Please wait..." onView:self.view];
    [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
        [appSharedData removeLoadingView];
        [appSharedData setGameStatus:kNotConnected];
        appSharedData.currentGameOpponent = nil;
        [appSharedData showToastMessage:@"Finished" onView:self.view];
        [self changeStatus];
    } errorBlock:^(QBError *error) {
        [appSharedData removeLoadingView];
        [appSharedData showToastMessage:@"failed, try again" onView:self.view];
    }];
}

// the selector which which is triggered when user touch "SPIN" button
- (IBAction)didTapSpinButton:(UIButton *)sender {
    
    if (theTimer == nil) {
        double currentMillis = [[NSDate date] timeIntervalSince1970];
        double randVal = currentMillis - floor(currentMillis);
        float spinStartSpeed = SPIN_START_SPEED_MIN + (SPIN_START_SPEED_MAX - SPIN_START_SPEED_MIN) * randVal;
        angularSpeed = spinStartSpeed;
        theTimer = [NSTimer scheduledTimerWithTimeInterval:SPIN_INTERVAL target:self selector:@selector(rotateRoulette) userInfo:nil repeats:YES];
    }
}

// the selector which is for rotating roulette
- (void)rotateRoulette {
    if (angularSpeed >= 0.0001) {
        angularSpeed -= SPIN_DECELLERATION;
        radiansOfWheel += angularSpeed;
        self.theRoulette.center = CGPointMake(self.theRoulette.center.x, self.theRoulette.center.y);
        self.theRoulette.transform = CGAffineTransformMakeRotation(radiansOfWheel);
    } else {
        [self showActivity];
        [theTimer invalidate];
        theTimer = nil;
    }
}

// the selector which is for showing activity
- (void)showActivity {
    
    radiansOfWheel = radiansOfWheel - floor(radiansOfWheel / (2 * M_PI)) * 2 * M_PI;
    int activityIndex = 12 - (int)(radiansOfWheel * 180 / M_PI - 15) / 30 - 1;
    prompt = [NSString stringWithFormat:@"%@: %@", [activityNumbers objectAtIndex:activityIndex], [activitiesCommands objectAtIndex:activityIndex]];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Activity" message:prompt delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

- (void)changeStatus {
    
    if ([appSharedData getGameStatus] == kAvailableToSpin) {
        [spinButton setEnabled:YES];
    } else {
        [spinButton setEnabled:NO];
    }
    
    if ([appSharedData getGameStatus] == kNotConnected) {
        self.titleNote.hidden = NO;
    } else {
        self.titleNote.hidden = YES;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 0) {
        ProfileDetails *authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
        NSString *recipientIDs = appSharedData.currentGameOpponent.quickbloxUserID;
        NSMutableDictionary *message = [NSMutableDictionary dictionary];
        [message setObject:@"game_activity" forKey:@"tag"];
        [message setObject:authUserInfo.strID forKey:@"opponent_id"];
        [message setObject:[NSString stringWithFormat:@"%@'s Activity - %@", authUserInfo.strName, prompt] forKey:@"body"];
        [appSharedData showCustomLoaderWithTitle:nil message:@"Please wait..." onView:self.view];
        [[ChatService instance] sendPushMessage:message toUsers:recipientIDs successBlock:^(QBResponse *response, QBMEvent *event) {
            [appSharedData removeLoadingView];
            [appSharedData setGameStatus:kWaitingOpponent];
            [self changeStatus];
        } errorBlock:^(QBError *error) {
            [appSharedData removeLoadingView];
            [appSharedData showToastMessage:@"Failed to send" onView:self.view];
        }];
    }
}

- (void)didSelectSideMenuItem:(NSNumber *)index {
    
    if (index.integerValue == 0) {
        GameHistoryViewController *historyController = (GameHistoryViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"GameHistoryViewController"];
        historyController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self presentViewController:historyController animated:YES completion:nil];
    }
}

@end
