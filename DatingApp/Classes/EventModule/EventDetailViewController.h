//
//  EventDetailViewController.h
//  DatingApp
//
//  Created by jayesh jaiswal on 26/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Events.h"

@interface EventDetailViewController : UIViewController

@property (strong, nonatomic) NSString *strEventID;
@property (strong, nonatomic) Events *objEvent;

- (IBAction)didTapLocation:(id)sender;

@end
