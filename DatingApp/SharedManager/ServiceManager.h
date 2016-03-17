//
//  ServiceManager.h
//  DatingApp
//
//  Created by jayesh jaiswal on 12/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"

@interface ServiceManager : NSObject
{
	
}
+ (ServiceManager *)sharedManager;
- (void)executeServiceWithURL:(NSString*)urlString withUIViewController:(UIViewController *)controller withTitle:(NSString *)title forTask:(TaskType)task withDictionary:(NSDictionary *)dict  completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock;
@end
