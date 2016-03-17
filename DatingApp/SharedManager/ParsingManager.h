//
//  ParsingManager.h
//  DatingApp
//
//  Created by jayesh jaiswal on 12/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParsingManager : NSObject
+ (ParsingManager*)sharedManager;
- (id)parseResponse:(id)response forTask:(TaskType)task;
@end
