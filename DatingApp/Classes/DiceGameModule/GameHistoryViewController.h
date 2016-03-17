//
//  GameHistoryViewController.h
//  DatingApp
//
//  Created by WongFeiHong on 11/13/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameHistoryViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    NSMutableArray *historyUsers;
}

@property (strong, nonatomic) IBOutlet UITableView *historyTable;

- (IBAction)didTapBackButton:(UIButton *)sender;

@end
