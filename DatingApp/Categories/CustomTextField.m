//
//  CustomTextField.m
//  DinningApp
//
//  Created by jayesh jaiswal on 28/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "CustomTextField.h"

#define TEXTFIELD_PADDING 10.0

@implementation CustomTextField

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    
    return [self textRectForBounds:bounds];
}

- (void)drawPlaceholderInRect:(CGRect)rect {
  
    [[UIColor lightGrayColor] setFill];
    CGRect placerholderRect = CGRectMake(rect.origin.x, (rect.size.height - self.font.pointSize) / 2, rect.size.width, self.font.pointSize);
    [[self placeholder] drawInRect:placerholderRect withFont:self.font lineBreakMode:NSLineBreakByWordWrapping alignment:NSTextAlignmentCenter];
}

@end
