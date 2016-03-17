//
//  SideBarViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "SideBarViewController.h"
#import "EditProfileViewController.h"
#import "CommonViewController.h"
#import "AsyncImageView.h"
#import "ProfileDetails.h"
#import "CreatEventViewController.h"
#import "LocalStorageService.h"
#import "UIImageView+AFNetworking.h"

@interface SideBarViewController() <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> {
    
    IBOutlet UIImageView *imgVersionIcon;
    IBOutlet UILabel *lblVersionNumber;
    ProfileDetails *authUserInfo;
}

@property (weak, nonatomic) IBOutlet UITableView *tblView;
@property (weak, nonatomic) IBOutlet UIImageView *imgProfilePic;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;

@end

@implementation SideBarViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    // Build - count : NSString *appBuildString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
    NSString *appVersionString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    NSString *versionBuildString = [NSString stringWithFormat:@"Version: %@", appVersionString];
    [lblVersionNumber setText:versionBuildString];
    
    self.imgProfilePic.layer.cornerRadius = 15.0;
    self.imgProfilePic.layer.masksToBounds = YES;
    self.imgProfilePic.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.imgProfilePic.layer.borderWidth = 1.0;
    
    authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    
    [self.imgProfilePic setHidden:YES];
    [lblVersionNumber setHidden:YES];
    [imgVersionIcon setHidden:YES];
    if([self.strClassIdentifier isEqualToString:@"DashBoardViewController"]) {
        [self.imgProfilePic setImageWithURLString:authUserInfo.strProfilePicture placeholderImage:[UIImage imageNamed:@"no_image_available.png"] toScaledSize:self.imgProfilePic.bounds.size];
        [self.imgProfilePic setHidden:NO];
        [lblVersionNumber setHidden:NO];
        [imgVersionIcon setHidden:NO];
        [self.lblTitle setText:authUserInfo.strName];
    } else if([self.strClassIdentifier isEqualToString:@"SearchViewController"]) {
        [self.lblTitle setText:@"Search"];
    } else if([self.strClassIdentifier isEqualToString:@"ChatViewController"]) {
        [self.lblTitle setText:@"Chat"];
    } else if([self.strClassIdentifier isEqualToString:@"DiceGameViewController"]) {
        [self.lblTitle setText:@"Drinking Game"];
    } else if([self.strClassIdentifier isEqualToString:@"EventViewController"]) {
        [self.lblTitle setText:@"Event"];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProfileThumbnail)
                                                 name:KCheckProfileIsUpdated object:nil];
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (void)updateProfileThumbnail {
    
    authUserInfo = [[LocalStorageService shared] getSavedAuthUserInfo];
    [self.imgProfilePic setImageWithURLString:authUserInfo.strProfilePicture placeholderImage:[UIImage imageNamed:@"no_image_available.png"] toScaledSize:self.imgProfilePic.bounds.size];
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(didSelectSideMenuItem:)]) {
        [self.delegate performSelector:@selector(didSelectSideMenuItem:) withObject:[NSNumber numberWithInt:indexPath.row]];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    NSInteger row = 0;
    if([self.strClassIdentifier isEqualToString:@"DashBoardViewController"])
        row = 6;
    else if([self.strClassIdentifier isEqualToString:@"SearchViewController"])
        row = 1;
    else if([self.strClassIdentifier isEqualToString:@"ChatViewController"])
        row = 2;
    else if([self.strClassIdentifier isEqualToString:@"DiceGameViewController"])
        row = 1;
    else if([self.strClassIdentifier isEqualToString:@"EventViewController"])
        row = 1;
    return row;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *cellIdentifier = @"cellIdentifier";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    if ([self.strClassIdentifier isEqualToString:@"DashBoardViewController"]) {
        if (indexPath.row == 0) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Edit Profile";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"edit_profile.png"];
        } else if (indexPath.row == 1) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Change Password";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"change_password_ico.png"];
        } else if (indexPath.row == 2) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Contact Us";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"contact_ico.png"];
        } else if (indexPath.row == 3) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Privacy Policy";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"privecy_ico.png"];
        } else if (indexPath.row == 4) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Terms of Service";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"privecy_ico.png"];
        } else if (indexPath.row == 5) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Logout";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"logout_ico.png"];
        }
    } else if([self.strClassIdentifier isEqualToString:@"SearchViewController"]) {
        if (indexPath.row == 0) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Settings";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"settings_ico.png"];
        }
    } else if([self.strClassIdentifier isEqualToString:@"ChatViewController"]) {
        if (indexPath.row == 0) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"User Profile";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"settings_ico.png"];
        } else if(indexPath.row == 1) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Block User";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"change_password_ico.png"];
        }
    } else if([self.strClassIdentifier isEqualToString:@"DiceGameViewController"]) {
        if (indexPath.row == 0) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"History";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"icon_game_history.png"];
        }
    } else if ([self.strClassIdentifier isEqualToString:@"EventViewController"]) {
        if (indexPath.row == 0) {
            UILabel *lblTitle = (UILabel *)[cell viewWithTag:103];
            lblTitle.text = @"Create Event";
            UIImageView *imageView = (UIImageView *)[cell viewWithTag:102];
            imageView.image = [UIImage imageNamed:@"icon_create_event.png"];
        }
    }
    
    UIImage *selectionBackground = [UIImage imageNamed:@"newBG.png"];
    UIImageView *iview = [[UIImageView alloc] initWithImage:selectionBackground];
    cell.selectedBackgroundView = iview;
    iview = nil;
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *view = [[UIView alloc] init] ;
    [view setBackgroundColor:[UIColor clearColor]];
    UIImageView *img=[[UIImageView alloc]init];
    [img setFrame:CGRectMake(0, 0, 210, 0.1)];
    [img setBackgroundColor:[UIColor lightGrayColor]];
    [view addSubview:img];
    img = nil;
    return view;
}

@end
