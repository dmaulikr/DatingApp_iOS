//
//  ChatViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DatingAppTabBarViewController.h"

@interface ChatViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate> {
    IBOutlet UIView *messageInputBox;
}

@property (nonatomic, strong) IBOutlet UITextField *messageTextField;
@property (nonatomic, strong) IBOutlet UITableView *messagesTableView;
@property (nonatomic, strong) IBOutlet UIScrollView *messageScrollView;
@property (nonatomic, strong) IBOutlet UIImageView *recipientImage;
@property (nonatomic, strong) IBOutlet UILabel *recipientName;

@property (nonatomic, strong) QBChatDialog *dialog;

- (IBAction)didTapSendButton:(UIButton *)sender;
- (IBAction)didTapBackButton:(UIButton *)sender;
- (IBAction)didTapMoreButton:(UIButton *)sender;

+ (ChatViewController *)sharedInstance;

@end
