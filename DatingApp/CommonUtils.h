//
//  CommonUtils.h
//  DatingApp
//
//  Created by HongChengMin on 11/18/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CommonUtils : NSObject {
    UIActivityIndicatorView *activityIndicator;
}

+ (instancetype)shared;
- (NSDate *)convertStringToDate:(NSString *)dateStr withFormat:(NSString *)formatStr;
- (NSString *)convertDateToString:(NSDate *)date withFormat:(NSString *)formatStr;
- (BOOL)isToday:(NSDate *)date;
- (UIImage *)cropImage:(UIImage *)image scaledToSize:(CGSize)newSize;
- (NSString *)getContentTypeForImageData:(NSData *)data;
- (NSString*)base64forData:(NSData*)theData;
- (void)showActivityIndicator:(UIView *)inView;
- (void)hideActivityIndicator;

@end
