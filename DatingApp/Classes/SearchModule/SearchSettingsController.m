//
//  SearchSettingsController.m
//  DatingApp
//
//  Created by WongFeiHong on 11/23/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "SearchSettingsController.h"

@implementation SearchSettingsController

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    [distanceLabel setText:[NSString stringWithFormat:@"%d", defaultDistance]];
    [distanceSlider setValue:(float)defaultDistance];
    [ageLabel setText:[NSString stringWithFormat:@"%d", defaultAge]];
    [ageSlider setValue:(float)defaultAge];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    
    if (sender == distanceSlider) {
        [distanceLabel setText:[NSString stringWithFormat:@"%d", (int)distanceSlider.value]];
    } else if (sender == ageSlider) {
        [ageLabel setText:[NSString stringWithFormat:@"%d", (int)ageSlider.value]];
    }
}

- (IBAction)didTapBackButton:(id)sender {
    
    [self.delegate didChangeSearchDistanceWithAge:[distanceLabel.text intValue] age:[ageLabel.text intValue]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setDefaultDistanceWithAge:(int)distance age:(int)age {
    
    defaultDistance = distance;
    if (age == -1) {
        age = 22;
    }
    defaultAge = age;
}

@end
