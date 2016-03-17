//
//  EventViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 29/08/14.
//  Modified by Hong ChengMin
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "EventViewController.h"
#import "SideBarViewController.h"
#import "AsyncImageView.h"
#import "Events.h"
#import "UIImage+Resize.h"
#import "EventDetailViewController.h"
#import "LocalStorageService.h"
#import "CreatEventViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CommonUtils.h"

@interface EventViewController () <UITableViewDelegate,UITableViewDataSource, SideBarViewControllerDelegate> {
    EVENT_TYPE selectedEventType;
    NSMutableArray *eventsList;
    CommonUtils *utilsHelper;
    BOOL isRowSelected;
    
    BOOL isSideMenuVisible;
    SideBarViewController *objSBVC;
}

@property (weak, nonatomic)     IBOutlet UIView *viewSideBar;
@property (weak, nonatomic)     IBOutlet UIView *viewEvent;
@property (weak, nonatomic)     IBOutlet UITableView *tblView;

- (IBAction)btnSplitTapped:(UIButton *)sender;

@end

@implementation EventViewController

@synthesize eventSegment;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {

    [super viewDidLoad];
    
    [self initViewAndClassMembers];
}

- (void)initViewAndClassMembers {
    
    objSBVC = (SideBarViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"SideBarViewController"];
    [objSBVC setStrClassIdentifier:@"EventViewController"];
    [objSBVC setDelegate:self];
    [self.viewSideBar addSubview:objSBVC.view];
    isSideMenuVisible = NO;
    
    eventsList = [[NSMutableArray alloc] init];
    
    utilsHelper = [CommonUtils shared];
    
    isRowSelected = NO;
    [self.tblView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pushDidReceive:)
                                                 name:kPushDidReceive
                                               object:nil];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    if(appSharedData.isEventListUpdated) {
        [appSharedData setIsEventListUpdated:NO];
        [self fetchAllEvents];
    }
    if (isRowSelected == NO) {
        [self fetchAllEvents];
    } else {
        isRowSelected = NO;
    }
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

- (void)viewWillLayoutSubviews {
   
    [super viewWillLayoutSubviews];
    
    if(IS_IPHONE_5 && IS_OS_7_OR_LATER) {
        [self.tblView setFrame:CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, 568-110)];
    } else if (IS_OS_7_OR_LATER && !IS_IPHONE_5) {
         [self.tblView setFrame:CGRectMake(self.tblView.frame.origin.x, self.tblView.frame.origin.y, self.tblView.frame.size.width, 370.0)];
    } else {
    }
}

// Toggle slide menu
- (void)toggleSideMenu {
    
    if (!isSideMenuVisible) {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        self.viewSideBar.frame = CGRectMake(0, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewEvent.frame = CGRectMake(210, self.viewEvent.frame.origin.y, self.viewEvent.frame.size.width, self.viewEvent.frame.size.height);
        [UIView commitAnimations];
        isSideMenuVisible = YES;
    } else {
        [UIView beginAnimations: @"Fade In" context:nil];
        [UIView setAnimationDuration:.5];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        self.viewSideBar.frame = CGRectMake(-210, self.viewSideBar.frame.origin.y, self.viewSideBar.frame.size.width, self.viewSideBar.frame.size.height);
        self.viewEvent.frame = CGRectMake(0, self.viewEvent.frame.origin.y, self.viewEvent.frame.size.width, self.viewEvent.frame.size.height);
        [UIView commitAnimations];
        [self.tabBarController.tabBar setUserInteractionEnabled:YES];
        isSideMenuVisible = NO;
    }
}

- (void)pushDidReceive:(NSNotification *)notification {
    
    // push message
    NSDictionary *pushInfo = [notification userInfo];
    if (pushInfo == nil) {
        return;
    }
    
    NSString *pushTag = [pushInfo objectForKey:@"tag"];
    
    if ([pushTag isEqualToString:@"event_invite"]) {
        [self fetchAllEvents];
    }
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    isRowSelected = YES;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    EventDetailViewController *objEDVC = (EventDetailViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    Events *obj = [eventsList objectAtIndex:indexPath.row];
    objEDVC.objEvent = obj;
    objEDVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.navigationController pushViewController:objEDVC animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    Events *obj = [eventsList objectAtIndex:indexPath.row];
    NSDictionary *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[LocalStorageService shared] getSavedAuthUserInfo].strID,    @"user_id",
                                  obj.strEventId,                                               @"event_id", nil];
    [serviceManager executeServiceWithURL:DeleteEventRequestUrl withUIViewController:self withTitle:@"Deleting Event"  forTask:kTaskDeleteEvent withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
                [appSharedData.arrEventList removeObject:obj];
                [self populateEventList];
                return;
            }
            [appSharedData showToastMessage:[NSString stringWithFormat:@"%@",[response objectForKey:@"status"]] onView:self.view];
        } else {
            [appSharedData showToastMessage:kNotificationResponseError onView:self.view];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [eventsList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:EVENT_LIST_ITEM_IDENTIFIER];
    Events *obj = [eventsList objectAtIndex:indexPath.row];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:EVENT_LIST_ITEM_IDENTIFIER];
    }
    
    // set background image
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"newBG.png"]];
    
    UIImageView *eventThumbnail = (UIImageView *)[cell viewWithTag:1];
    eventThumbnail.layer.cornerRadius = 6.0;
    eventThumbnail.layer.masksToBounds = YES;
    [eventThumbnail setImageWithURL:[NSURL URLWithString:obj.strEventPicPath] placeholderImage:[UIImage imageNamed:@"defaultevent_icon.png"]];
    
    UILabel *lblEventTitle = (UILabel *)[cell viewWithTag:2];
    [lblEventTitle setText:obj.strEventName];
    
    UILabel *lblDateTime = (UILabel *)[cell viewWithTag:3];
    NSDate *eventDate = [utilsHelper convertStringToDate:obj.strEventStartDate withFormat:@"yyyy-MM-dd"];
    NSString *strDate = [utilsHelper convertDateToString:eventDate withFormat:@"MM/dd/yyyy"];
    NSDate *eventStartTime = [utilsHelper convertStringToDate:obj.strEventStartTime withFormat:@"HH:mm:ss"];
    NSString *strStartTime = [utilsHelper convertDateToString:eventStartTime withFormat:@"h:mm a"];
    lblDateTime.text = [NSString stringWithFormat:@"%@ | %@", strDate, strStartTime];
    
    UILabel *locationLabel = (UILabel *)[cell viewWithTag:4];
    [locationLabel setText:[NSString stringWithFormat:@"at %@", obj.strEventLocation]];
    
    UILabel *addressLabel = (UILabel *)[cell viewWithTag:5];
    [addressLabel setText:[NSString stringWithFormat:@"%@", obj.strEventAddress]];
    
    UILabel *creatorCheck = (UILabel *)[cell viewWithTag:7];
    creatorCheck.hidden = ![obj.strEventUserId isEqualToString:[[LocalStorageService shared] getSavedAuthUserInfo].strID];
    
    return cell;
}

#pragma mark - Button Methods
- (IBAction)btnSplitTapped:(UIButton *)sender {
    [self toggleSideMenu];
}

// Fetch all events from the server
- (void)fetchAllEvents {
    
    NSDate *now = [NSDate date];
    NSDictionary  *dictRequest = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [[LocalStorageService shared] getSavedAuthUserInfo].strID, @"user_id", nil];
    [serviceManager executeServiceWithURL:GetEventListRequestURL withUIViewController:self withTitle:@"Getting Event List"  forTask:kTaskGetEventList withDictionary:dictRequest completionHandler:^(id response, NSError *error,TaskType task) {
        if (!error) {
            NSMutableArray *result = [NSMutableArray array];
            if ([[response objectForKey:@"result"] isEqualToString:@"Success"]) {
                for (id dictionary in [response objectForKey:@"Event"]) {
                    Events *event = [[Events alloc] initWithDictionary:[dictionary objectForKey:@"Event"]];
                    // Analysis the event object and change the status
                    NSInteger flag = [[dictionary objectForKey:@"status"] integerValue];
                    NSString *strDateTime = [NSString stringWithFormat:@"%@ %@", event.strEventStartDate, event.strEventStartTime];
                    NSDate *startDateTime = [utilsHelper convertStringToDate:strDateTime withFormat:@"yyyy-MM-dd HH:mm:ss"];
                    if (startDateTime != nil) {
                        if ([startDateTime compare:now] == NSOrderedDescending) {
                            if (flag == 0) {
                                [event setStatus:NEW_EVENT];
                            } else {
                                [event setStatus:UPCOMING_EVENT];
                            }
                        } else {
                            [event setStatus:PAST_EVENT];
                        }
                    } else {
                        [event setStatus:NEW_EVENT];
                    }
                    [result addObject:event];
                    event = nil;
                }
            }
            [appSharedData.arrEventList removeAllObjects];
            [appSharedData setArrEventList:result];
            [self populateEventList];
        } else {
            [appSharedData showToastMessage:@"Connection error" onView:self.view];
        }
    }];
}

// the selector which for handling segment select event
- (IBAction)eventSegmentAction:(id)sender {
    
    if (eventSegment.selectedSegmentIndex == 0) {
        selectedEventType = UPCOMING_EVENT;
    } else if (eventSegment.selectedSegmentIndex == 1) {
        selectedEventType = NEW_EVENT;
        appSharedData.newEventCount = 0;
        [[[[self.tabBarController viewControllers] objectAtIndex:4] tabBarItem] setBadgeValue:nil];
    } else if (eventSegment.selectedSegmentIndex == 2) {
        selectedEventType = PAST_EVENT;
    }
    
    [self populateEventList];
}

// the selector which is to populate event list
- (void)populateEventList {
    
    [eventsList removeAllObjects];
    for (Events *event in appSharedData.arrEventList) {
        if ([event getStatus] == selectedEventType) {
            [eventsList addObject:event];
        }
    }
    [self.tblView reloadData];
}

#pragma mark - SideBarViewControllerDelegate
// The selector which is called when user select item on side menu
// added by Hong
- (void)didSelectSideMenuItem:(NSNumber *)index {
    
    [self toggleSideMenu];
    
    if ([index integerValue] == 0) {
        // If user select Create Event menu
        CreatEventViewController *objEPVC = (CreatEventViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"CreatEventViewController"];
        objEPVC.strIdentifier = @"CREATE";
        objEPVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:objEPVC animated:YES];
    }
}

@end
