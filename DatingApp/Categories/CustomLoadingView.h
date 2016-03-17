//
//  CustomLoadingView.h
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomLoadingView : UIView
{
    UIActivityIndicatorView *_activity;
    BOOL _hidden;
    
    NSString *_title;
    NSString *_message;
    float radius;
}
@property (copy,nonatomic) NSString *title;
@property (copy,nonatomic) NSString *message;
@property (assign,nonatomic) float radius;

- (id) initWithTitle:(NSString*)title message:(NSString*)message;
- (id) initWithTitle:(NSString*)title;

- (void) startAnimating;
- (void) stopAnimating;

- (void)setCenterForOrientation:(UIInterfaceOrientation)orientation ;
@end
