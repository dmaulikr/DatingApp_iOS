//
//  CustomLoadingView.m
//  DinningApp
//
//  Created by jayesh jaiswal on 29/07/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "CustomLoadingView.h"
#import "UIView+Drawing.h"
#define WIDTH_MARGIN 20
#define HEIGHT_MARGIN 20

@interface CustomLoadingView (PrivateMethods)
- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(NSLineBreakMode)lineBreakMode;
@end


@implementation CustomLoadingView
@synthesize radius;

- (id) initWithTitle:(NSString*)ttl message:(NSString*)msg{
	if(!(self = [super initWithFrame:CGRectMake(0, 0, 280, 200)])) return nil;
    
    _title = [ttl copy];
    _message = [msg copy];
    _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [self addSubview:_activity];
    _hidden = YES;
    self.backgroundColor = [UIColor clearColor];
    
	
	return self;
}
- (id) initWithTitle:(NSString*)ttl{
	if(![self initWithTitle:ttl message:nil]) return nil;
	return self;
}

- (void) drawRect:(CGRect)rect {
	
	if(_hidden) return;
	int width, rWidth, rHeight, x;
	
	
	UIFont *titleFont = [UIFont boldSystemFontOfSize:16];
	UIFont *messageFont = [UIFont systemFontOfSize:12];
	
    
	CGSize s1 = [self calculateHeightOfTextFromWidth:_title font:titleFont width:200 linebreak:NSLineBreakByTruncatingTail];
	CGSize s2 = [self calculateHeightOfTextFromWidth:_message font:messageFont width:200 linebreak:NSLineBreakByCharWrapping];
	if(IS_OS_7_OR_LATER)
	{
        s1=CGSizeMake(s1.width+10, s1.height);
        s2=CGSizeMake(s2.width+10, s2.height);
	}
	if([_title length] < 1) s1.height = 0;
	if([_message length] < 1) s2.height = 0;
	
	
	rHeight = (s1.height + s2.height + (HEIGHT_MARGIN*2) + 10 + _activity.frame.size.height);
	rWidth = width = (s2.width > s1.width) ? (int) s2.width : (int) s1.width;
	rWidth += WIDTH_MARGIN * 2;
	x = (280 - rWidth) / 2;
	
	_activity.center = CGPointMake(280/2,HEIGHT_MARGIN + _activity.frame.size.height/2);
	
	
	[[UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:.1] set];
	CGRect r = CGRectMake(x, 0, rWidth,rHeight);
    [[UIColor colorWithRed:246.0/255.0 green:42.0/255.0 blue:69.0/255.0 alpha:1.0] set];
	[UIView drawRoundRectangleInRect:r withRadius:10.0];
	
	// DRAW FIRST TEXT
	[[UIColor whiteColor] set];
	r = CGRectMake(x+WIDTH_MARGIN, _activity.frame.size.height + 10 + HEIGHT_MARGIN, width, s1.height);
	CGSize s = [_title drawInRect:r withFont:titleFont lineBreakMode:NSLineBreakByTruncatingTail alignment:NSTextAlignmentCenter];
	
	// DRAW SECOND TEXT
	r.origin.y += s.height;
	r.size.height = s2.height;
	[_message drawInRect:r withFont:messageFont lineBreakMode:NSLineBreakByCharWrapping alignment:NSTextAlignmentCenter];}

- (void)setCenterForOrientation:(UIInterfaceOrientation)orientation {
    CGPoint center ;
    if(UIInterfaceOrientationIsPortrait(orientation)){
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            center.x = 768.0/2 ;
            center.y = 1024.0/2 ;
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            center.x = 320.0/2;
            center.y = 480.0/2;
        }
    }else {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            center.x = 1024.0/2 ;
            center.y = 768.0/2 ;
        }else if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            center.x = 480.0/2;
            center.y = 320.0/2;
        }
    }
    [self setCenter:center];
}

- (void) setTitle:(NSString*)str{
	_title = nil;
	_title = [str copy];
	//[self updateHeight];
	[self setNeedsDisplay];
}
- (NSString*) title{
	return _title;
}

- (void) setMessage:(NSString*)str{
    _message = nil;
	_message = [str copy];
	[self setNeedsDisplay];
}
- (NSString*) message{
	return _message;
}

- (void) setRadius:(float)f{
	if(f==radius) return;
	
	radius = f;
	[self setNeedsDisplay];
	
}

- (void) startAnimating{
	if(!_hidden) return;
	_hidden = NO;
	[self setNeedsDisplay];
	[_activity startAnimating];
	
}

- (void) stopAnimating{
	if(_hidden) return;
	_hidden = YES;
	[self setNeedsDisplay];
	[_activity stopAnimating];
	
}

- (CGSize) calculateHeightOfTextFromWidth:(NSString*)text font: (UIFont*)withFont width:(float)width linebreak:(NSLineBreakMode)lineBreakMode{
	return [text sizeWithFont:withFont
			constrainedToSize:CGSizeMake(width, FLT_MAX)
				lineBreakMode:lineBreakMode];
}

- (CGSize) heightWithString:(NSString*)str font:(UIFont*)withFont width:(float)width linebreak:(NSLineBreakMode)lineBreakMode{
	
	
	CGSize suggestedSize = [str sizeWithFont:withFont constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
	
	return suggestedSize;
}

- (void) adjustHeight{
	
	CGSize s1 = [self heightWithString:_title font:[UIFont boldSystemFontOfSize:16.0]
								 width:200.0
							 linebreak:NSLineBreakByTruncatingTail];
	
	CGSize s2 = [self heightWithString:_message font:[UIFont systemFontOfSize:12.0]
                                 width:200.0
                             linebreak:NSLineBreakByCharWrapping];
    
	CGRect r = self.frame;
	r.size.height = s1.height + s2.height + 20;
	self.frame = r;
}

- (void) dealloc{
    _activity = nil;
	_title = nil;
	_message = nil;
}

@end
