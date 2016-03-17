//
//  EventComment.h
//  DatingApp
//
//  Created by jayesh jaiswal on 08/10/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventComment : NSObject

@property (strong, nonatomic) NSString *strId;
@property (strong, nonatomic) NSString *strUserId;
@property (strong, nonatomic) NSString *strEventId;
@property (strong, nonatomic) NSString *strComment;
@property (strong, nonatomic) NSString *strUserName;
@property (strong, nonatomic) NSString *strUserPicture;
@property (strong, nonatomic) NSString *strCommentDateTime;

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)toDictionary;

@end
