//
//  ServiceManager.m
//  DatingApp
//
//  Created by jayesh jaiswal on 12/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ServiceManager.h"

static ServiceManager *serviceManagerObj = nil;

@implementation ServiceManager

+ (ServiceManager *)sharedManager{
    static dispatch_once_t predicate;
    if(serviceManagerObj == nil){
        dispatch_once(&predicate,^{
            serviceManagerObj = [[ServiceManager alloc] init];
        });
    }
    return serviceManagerObj;
}
- (void)executeServiceWithURL:(NSString*)urlString withUIViewController:(UIViewController *)controller withTitle:(NSString *)title forTask:(TaskType)task withDictionary:(NSDictionary *)dict completionHandler:(void (^)(id response, NSError *error, TaskType task))completionBlock;
{
    
    NSURL *url = [NSURL URLWithString:urlString];
    __unsafe_unretained ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
	__block id jsonData;
	if([appSharedData isUploadMedia])
	{
        for(NSString *key in dict)
        {
            NSString *value = [dict valueForKey: key];
            [request addPostValue:value forKey:key];
        }
        [request addRequestHeader:@"multipart/form-data" value:@"Content-Type"];
        NSString *str=[NSString stringWithFormat:@"upload%@",appSharedData.strFileExtension];
		[request addData:[appSharedData pickerImageData] withFileName:str andContentType:appSharedData.strFileExtension forKey:@"file"];
        [request addRequestHeader:@"accept" value:@"application/json"];
        [appSharedData setIsUploadMedia:NO];
    }
    else
	{
        for(NSString *key in dict)
        {
            NSString *value = [dict valueForKey: key];
            [request addPostValue:value forKey:key];
        }
        [request addRequestHeader:@"multipart/form-data" value:@"Content-Type"];
		[request addRequestHeader:@"accept" value:@"application/json"];
	}
	[request setRequestMethod:@"POST"];
    [request setTimeOutSeconds:60];
    [request setCompletionBlock:^(){
        NSError *error = nil;
        NSString *responseString = (request.responseString.length)?request.responseString:@"";
        NSLog(@"responseString =%@",responseString);
        NSData *responseData = [responseString dataUsingEncoding:NSUTF8StringEncoding];
        jsonData = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:&error];
        if(error)
		{
			[appSharedData setIsErrorOrFailResponse:YES];
            completionBlock(nil, error, task);
			NSString *errorDes=[error localizedDescription];
			[appSharedData removeLoadingView];
			[appSharedData showAlertView:@"Alert" withMessage:errorDes withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
		}
        else
		{
            [appSharedData removeLoadingView];
            completionBlock(jsonData, error, task);
		}
    }];
    
    [request setFailedBlock:^{
		[appSharedData setIsErrorOrFailResponse:YES];
        completionBlock(nil, request.error, task);
        [appSharedData removeLoadingView];
		NSString *errorDes=[request.error localizedDescription];
		[appSharedData showAlertView:@"Alert" withMessage:errorDes withDelegate:nil withCancelBtnTitle:@"OK" withOtherButton:nil];
    }];
    NSString *message = @"Please wait...";
	[appSharedData showCustomLoaderWithTitle:title message:message onView:controller.view];
    [request startAsynchronous];
}

@end
