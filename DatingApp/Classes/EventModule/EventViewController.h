//
//  EventViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Modified by Hong ChengMin
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventViewController : UIViewController

@property (nonatomic, strong) IBOutlet UISegmentedControl *eventSegment;

- (IBAction)eventSegmentAction:(id)sender;

@end
