//
//  EditProfileCell.m
//  DatingApp
//
//  Created by jayesh jaiswal on 02/09/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "EditProfileCell.h"

@implementation EditProfileCell

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.picture = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 50 , 50)];
        self.picture.image=[UIImage imageNamed:@"no_image_available.png"];
        [self.contentView addSubview:self.picture];
        self.picture.transform = CGAffineTransformRotate(self.picture.transform, M_PI/2);
    }
    return self;
}
@end
