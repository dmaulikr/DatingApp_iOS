//
//  UIImage+ResizeCategory.h
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (ResizeCategory)

- (UIImage*)resizedImageToSize:(CGSize)dstSize;
- (UIImage*)resizedImageToFitInSize:(CGSize)boundingSize scaleIfSmaller:(BOOL)scale;

@end
