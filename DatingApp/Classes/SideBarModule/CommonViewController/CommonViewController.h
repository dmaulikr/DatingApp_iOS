//
//  CommonViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 02/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommonViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate> {
    
    IBOutlet UITextView *txtView1;
    IBOutlet UITextView *txtView;
    IBOutlet UILabel *lblTitle;
    IBOutlet UIView *viewChange;
    IBOutlet UITextField *txtfOldPassword;
    IBOutlet UITextField *txtfNewPassword;
    IBOutlet UITextField *txtfConfirmPassword;
}

@property (strong, nonatomic) NSString *strTitle;
- (IBAction)btnBackTapped:(id)sender;
- (IBAction)btnChangePassword:(UIButton *)sender;

@end
