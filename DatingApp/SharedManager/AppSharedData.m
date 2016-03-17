//
//  AppSharedData.m
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "AppSharedData.h"
#import "CustomLoadingView.h"

static AppSharedData *appSharedData_;

@interface AppSharedData () <CLLocationManagerDelegate> {
    GameStatus gameStatus;
}

@property (nonatomic, strong) CustomLoadingView *loadingView;

@end

@implementation AppSharedData

+ (AppSharedData *)sharedInstance{
    static dispatch_once_t predicate;
    if(appSharedData_ == nil) {
        dispatch_once(&predicate,^{
            appSharedData_ = [[AppSharedData alloc] init];
            appSharedData_.dictCatchedImages=[[NSMutableDictionary alloc]init];
            appSharedData_.viewToast=[[UIView alloc]init];
            appSharedData_.view_Overlay=[[UIView alloc]init];
            appSharedData_.lblToastMessage =[[UILabel alloc] init];
            appSharedData_.arrUserProfileInfo=[[NSMutableArray alloc]init];
            appSharedData_.arrProfileDetails=[[NSMutableArray alloc]init];
            appSharedData_.arrEventList=[[NSMutableArray alloc] init];
            appSharedData_.arrUserProfilePics=[[NSMutableArray alloc] init];
            appSharedData_.arrEventPics=[[NSMutableArray alloc]init];
            appSharedData_.arrSearchUsers=[[NSMutableArray alloc] init];
            appSharedData_.arrUserAllProfilePicture=[[NSMutableArray alloc]init];
            appSharedData_.arrUserProfileData=[[NSMutableArray alloc]init];
            appSharedData_.arrComments=[[NSMutableArray alloc] init];
            appSharedData_.allMessages = [[NSMutableDictionary alloc] init];
            appSharedData_.arrDialogs = [[NSMutableArray alloc] init];
            
            appSharedData_.isDialogsUpdated = YES;
            appSharedData_.newEventCount = 0;
            appSharedData_.newMessageCount = 0;
            [appSharedData_ checkAndStartLocationUpdate];
        });
    }
    return appSharedData_;
}

// Check if gps updating is started and start if it's not running
- (void)checkAndStartLocationUpdate {
    if(self.locationManager == nil){
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.distanceFilter = kCLDistanceFilterNone;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
        self.locationManager.pausesLocationUpdatesAutomatically = NO;
        if ([self.locationManager respondsToSelector:@selector(requestAlwaysAuthorization)]) {
            [self.locationManager requestAlwaysAuthorization];
        }
        [self.locationManager startUpdatingLocation];
    }
}

#pragma mark - CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation * newLocation = [locations lastObject];
    
    double latitude = newLocation.coordinate.latitude;
    double longitude = newLocation.coordinate.longitude;
    double altitude = newLocation.altitude;
    [appSharedData setUserCurrentLattitude:latitude];
    [appSharedData setUserCurrentLongitude:longitude];
    [appSharedData setUserCurrentAltitude:altitude];
    
    [Flurry setLatitude:latitude longitude:longitude horizontalAccuracy:newLocation.horizontalAccuracy verticalAccuracy:newLocation.verticalAccuracy];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    if(error.code==kCLErrorDenied){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Location Service Disabled" message:@"To re-enable, please go to Settings and turn on Location Service for this app." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        alert=nil;
    }
}
- (void)showCustomLoaderWithTitle:(NSString*)title message:(NSString*)message onView:(UIView*)parentView{
    UIView *rootView = [[[appDelegate window] rootViewController] view];
    if(self.loadingView){
        [self removeLoadingView];
    }
    if(parentView==nil){
        parentView = rootView;
    }
    self.loadingView = [[CustomLoadingView alloc] initWithTitle:title message:message];
    [self.loadingView setCenter:[rootView center]];
    if(parentView)
        [self.loadingView setCenter:[parentView center]];
    [parentView addSubview:self.loadingView];
    [parentView setUserInteractionEnabled:NO];
    [rootView setUserInteractionEnabled:NO];
    [self.loadingView startAnimating];
}

- (void)removeLoadingView{
    UIView *rootView = [[[appDelegate window] rootViewController] view];
    [rootView setUserInteractionEnabled:YES];
    [self.loadingView.superview setUserInteractionEnabled:YES];
    [self.loadingView removeFromSuperview];
    self.loadingView = nil;
}
- (NSData *)base64DataFromString: (NSString *)string
{
	unsigned long ixtext, lentext;
	unsigned char ch, inbuf[4], outbuf[3];
	short i, ixinbuf;
	Boolean flignore, flendtext = false;
	const unsigned char *tempcstring;
	NSMutableData *theData;
	
	if (string == nil)
	{
		return [NSData data];
	}
	
	ixtext = 0;
	
	tempcstring = (const unsigned char *)[string UTF8String];
	
	lentext = [string length];
	
	theData = [NSMutableData dataWithCapacity: lentext];
	
	ixinbuf = 0;
	
	while (true)
	{
		if (ixtext >= lentext)
		{
			break;
		}
		
		ch = tempcstring [ixtext++];
		
		flignore = false;
		
		if ((ch >= 'A') && (ch <= 'Z'))
		{
			ch = ch - 'A';
		}
		else if ((ch >= 'a') && (ch <= 'z'))
		{
			ch = ch - 'a' + 26;
		}
		else if ((ch >= '0') && (ch <= '9'))
		{
			ch = ch - '0' + 52;
		}
		else if (ch == '+')
		{
			ch = 62;
		}
		else if (ch == '=')
		{
			flendtext = true;
		}
		else if (ch == '/')
		{
			ch = 63;
		}
		else
		{
			flignore = true;
		}
		
		if (!flignore)
		{
			short ctcharsinbuf = 3;
			Boolean flbreak = false;
			
			if (flendtext)
			{
				if (ixinbuf == 0)
				{
					break;
				}
				
				if ((ixinbuf == 1) || (ixinbuf == 2))
				{
					ctcharsinbuf = 1;
				}
				else
				{
					ctcharsinbuf = 2;
				}
				
				ixinbuf = 3;
				
				flbreak = true;
			}
			
			inbuf [ixinbuf++] = ch;
			
			if (ixinbuf == 4)
			{
				ixinbuf = 0;
				
				outbuf[0] = (inbuf[0] << 2) | ((inbuf[1] & 0x30) >> 4);
				outbuf[1] = ((inbuf[1] & 0x0F) << 4) | ((inbuf[2] & 0x3C) >> 2);
				outbuf[2] = ((inbuf[2] & 0x03) << 6) | (inbuf[3] & 0x3F);
				
				for (i = 0; i < ctcharsinbuf; i++)
				{
					[theData appendBytes: &outbuf[i] length: 1];
				}
			}
			
			if (flbreak)
			{
				break;
			}
		}
	}
	
	return theData;
}
-(void) showAlertView:(NSString *)alertTitle withMessage:(NSString *)alertMessage withDelegate:(id)delegate withCancelBtnTitle:(NSString *)buttonCancelTitle withOtherButton:(NSString *)otherButtonTitle
{
	UIAlertView *alertView=[[UIAlertView alloc]initWithTitle:alertTitle message:alertMessage delegate:delegate cancelButtonTitle:buttonCancelTitle otherButtonTitles:otherButtonTitle, nil];
	[alertView show];
	alertView=nil;
}
-(NSString *)convertGMTtoLocal:(NSString *)gmtDateStr
{
	
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSTimeZone *gmt = [NSTimeZone systemTimeZone];
    [formatter setTimeZone:gmt];
    NSDate *localDate = [formatter dateFromString:gmtDateStr]; // get the date
    NSTimeInterval timeZoneOffset = [[NSTimeZone systemTimeZone] secondsFromGMT]; // You could also use the systemTimeZone method
    NSTimeInterval localTimeInterval = [localDate timeIntervalSinceReferenceDate] + timeZoneOffset;
    NSDate *localCurrentDate = [NSDate dateWithTimeIntervalSinceReferenceDate:localTimeInterval];
    formatter=nil;
    
	NSDateFormatter *newDF = [[NSDateFormatter alloc] init];
	[newDF setDateFormat:@"dd MMM EEE"];
	NSString *strDate = [newDF stringFromDate:localCurrentDate];
	
	NSDateFormatter *newDF1 = [[NSDateFormatter alloc] init];
	[newDF1 setDateFormat:@"HH:mm"];
	NSString *strDate1 = [newDF1 stringFromDate:localCurrentDate];
	NSString *finalString=[NSString stringWithFormat:@"%@, at %@",strDate,strDate1];
	newDF=nil;newDF1=nil;
	return finalString;
	
}
-(void)timerFired
{
	[UIView transitionWithView:self.viewToast duration:0.3 options:UIViewAnimationOptionCurveEaseInOut animations:NULL completion:NULL];
	[self.viewToast setHidden:YES];
	[self.viewToast removeFromSuperview];
}
-(void) showToastMessage:(NSString *) message onView:(UIView *)onView
{
	
	CGSize size = [message sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(9999, 21) lineBreakMode:NSLineBreakByWordWrapping];//NSLineBreakByWordWrapping
	if(size.width>300)
	{
		CGSize size1 = [message sizeWithFont:[UIFont boldSystemFontOfSize:15] constrainedToSize:CGSizeMake(300, 9999) lineBreakMode:NSLineBreakByWordWrapping];
		size1.height=size1.height+2;
		CGRect screenBound = [[UIScreen mainScreen] bounds];
		CGFloat yOffset=(screenBound.size.height-size.height)/2.0;
		[self.viewToast setHidden:NO];
		[self.viewToast setFrame:CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height)];
		[self.viewToast setBackgroundColor:[UIColor clearColor]];
		[self.lblToastMessage setNumberOfLines:0];
		[self.lblToastMessage setFrame:CGRectMake(10, yOffset-40, 300, size1.height)];
		[self.lblToastMessage setText:message];
		[self.lblToastMessage setFont:[UIFont boldSystemFontOfSize:15]];
		[self.lblToastMessage setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:42.0/255.0 blue:69.0/255.0 alpha:1.0]];
		[self.lblToastMessage setTextColor:[UIColor whiteColor]];
		[self.lblToastMessage setTextAlignment:NSTextAlignmentCenter];
		
		[self.viewToast addSubview:self.lblToastMessage];
		[onView addSubview:self.viewToast];
		[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired) userInfo:nil repeats: NO];
	}
	else
	{
		CGFloat xOffSet=(320-size.width)/2.0;
		CGRect screenBound = [[UIScreen mainScreen] bounds];
		CGFloat yOffset=(screenBound.size.height-size.height)/2.0;
		size.width=size.width+10;
		[self.viewToast setHidden:NO];
		[self.viewToast setFrame:CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height)];
		[self.viewToast setBackgroundColor:[UIColor clearColor]];
		[self.lblToastMessage setFrame:CGRectMake(xOffSet, yOffset-20, size.width, 30)];
		[self.lblToastMessage setText:message];
		[self.lblToastMessage setFont:[UIFont boldSystemFontOfSize:15]];
		[self.lblToastMessage setBackgroundColor:[UIColor colorWithRed:246.0/255.0 green:42.0/255.0 blue:69.0/255.0 alpha:1.0]];
		[self.lblToastMessage setTextColor:[UIColor whiteColor]];
		[self.lblToastMessage setTextAlignment:NSTextAlignmentCenter];
		[self.viewToast addSubview:self.lblToastMessage];
		[onView addSubview:self.viewToast];
		[NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(timerFired) userInfo:nil repeats: NO];
	}
}

- (void)showViewOverLay:(UIView *)onView withClass:(NSString *)className {
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    [self.view_Overlay setFrame:CGRectMake(screenBound.origin.x, screenBound.origin.y, screenBound.size.width, screenBound.size.height)];
    [self.view_Overlay setBackgroundColor:[UIColor blackColor]];
    [self.view_Overlay setAlpha:.61];
    [self.view_Overlay setHidden:NO];
    [onView addSubview:self.view_Overlay];
}

- (void)hideViewOverLay {
    
	[self.view_Overlay setHidden:YES];
	[self.view_Overlay removeFromSuperview];
}

- (long)getAgeFromBirthday:(NSString *)birthday {
    NSString *strBirthday = [NSString stringWithFormat:@"%@", birthday];
    NSArray *arr = [strBirthday componentsSeparatedByString:@"/"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    if (arr.count > 1)
        [dateFormatter setDateFormat:@"dd/MM/yyyy"];
    else
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *fromDate = [[NSDate alloc] init];
    fromDate = [dateFormatter dateFromString:strBirthday];
    long  years=18;
    if(fromDate)
    {
        NSDate *endDate=[NSDate date];
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        unsigned int unitFlags = NSYearCalendarUnit;
        NSDateComponents *components = [gregorian components:unitFlags fromDate:fromDate toDate:endDate options:0];
        years = [components year];
    }
    return years;
}

- (QBChatDialog *)getSessionDailogFromArray:(NSUInteger)sessionID {
    if ([self.arrDialogs count] > 0) {
        for (QBChatDialog *dialog in self.arrDialogs) {
            if (dialog.type == QBChatDialogTypePrivate) {
                if (dialog.recipientID == sessionID) {
                    return dialog;
                }
            }
        }
    }
    return nil;
}

- (ProfileDetails *)getUserFromSessionID:(NSUInteger)sessionID {
    if ([self.arrAllUsers count] > 0) {
        for (ProfileDetails *user in self.arrAllUsers) {
            if ([user.quickbloxUserID isEqualToString:[NSString stringWithFormat:@"%tu", sessionID]]) {
                return user;
            }
        }
    }
    return nil;
}

- (GameStatus)getGameStatus {
    return gameStatus;
}

- (void)setGameStatus:(GameStatus)status {
    gameStatus = status;
}

@end
