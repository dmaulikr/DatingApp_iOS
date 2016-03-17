//
//  SearchSettingsController.h
//  DatingApp
//
//  Created by WongFeiHong on 11/23/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchSettingsControllerDelegate <NSObject>

- (void)didChangeSearchDistanceWithAge:(int)distance age:(int)age;

@end

@interface SearchSettingsController : UIViewController {
    IBOutlet UISlider *distanceSlider;
    IBOutlet UISlider *ageSlider;
    IBOutlet UILabel *distanceLabel;
    IBOutlet UILabel *ageLabel;
    int defaultDistance;
    int defaultAge;
}

@property (weak, nonatomic) NSObject<SearchSettingsControllerDelegate> *delegate;
- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)didTapBackButton:(id)sender;
- (void)setDefaultDistanceWithAge:(int)distance age:(int)age;

@end
