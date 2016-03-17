//
//  ChatService.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/21/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "ChatService.h"

typedef void(^CompletionBlock)();
typedef void(^JoinRoomCompletionBlock)(QBChatRoom *);
typedef void(^CompletionBlockWithResult)(NSArray *);

@interface ChatService () <QBChatDelegate>

@property (copy) QBUUser *currentUser;
@property (retain) NSTimer *presenceTimer;

@property (copy) CompletionBlock loginCompletionBlock;
@property (copy) JoinRoomCompletionBlock joinRoomCompletionBlock;
@property (copy) CompletionBlockWithResult requestRoomsCompletionBlock;

@end


@implementation ChatService

+ (instancetype)instance{
    static id instance_ = nil;
	
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance_ = [[self alloc] init];
	});
	
	return instance_;
}

- (id)init{
    self = [super init];
    if(self){
        [QBChat instance].delegate = self;
    }
    return self;
}

- (void)loginWithUser:(QBUUser *)user completionBlock:(void(^)())completionBlock{
    self.loginCompletionBlock = completionBlock;
    
    self.currentUser = user;
    
    [[QBChat instance] loginWithUser:user];
}

- (void)sendMessage:(QBChatMessage *)message{
    [[QBChat instance] sendMessage:message];
}

- (void)sendMessage:(QBChatMessage *)message toRoom:(QBChatRoom *)chatRoom{
    [[QBChat instance] sendChatMessage:message toRoom:chatRoom];
}

- (void)createOrJoinRoomWithName:(NSString *)roomName completionBlock:(void(^)(QBChatRoom *))completionBlock{
    self.joinRoomCompletionBlock = completionBlock;
    
    [[QBChat instance] createOrJoinRoomWithName:roomName membersOnly:NO persistent:YES];
}

- (void)joinRoom:(QBChatRoom *)room completionBlock:(void(^)(QBChatRoom *))completionBlock{
    self.joinRoomCompletionBlock = completionBlock;
    
    [room joinRoomWithHistoryAttribute:@{@"maxstanzas": @"0"}];
}

- (void)leaveRoom:(QBChatRoom *)room{
    [[QBChat instance] leaveRoom:room];
}

- (void)requestRoomsWithCompletionBlock:(void(^)(NSArray *))completionBlock{
    self.requestRoomsCompletionBlock = completionBlock;
    
    [[QBChat instance]  requestAllRooms];
}

#pragma mark
#pragma mark QBChatDelegate

- (void)chatDidLogin{
    // Start sending presences
    [self.presenceTimer invalidate];
    self.presenceTimer = [NSTimer scheduledTimerWithTimeInterval:30
                                     target:[QBChat instance] selector:@selector(sendPresence)
                                   userInfo:nil repeats:YES];
    
    if (self.loginCompletionBlock != nil) {
        self.loginCompletionBlock();
        self.loginCompletionBlock = nil;
    }
}

- (void)chatDidFailWithError:(NSInteger)code{
    // relogin here
    [[QBChat instance] loginWithUser:self.currentUser];
}

- (void)chatRoomDidEnter:(QBChatRoom *)room{
    self.joinRoomCompletionBlock(room);
    self.joinRoomCompletionBlock = nil;
}

- (void)chatDidReceiveListOfRooms:(NSArray *)rooms{
    self.requestRoomsCompletionBlock(rooms);
    self.requestRoomsCompletionBlock = nil;
}

- (void)chatDidReceiveMessage:(QBChatMessage *)message{
    // play sound notification
    // [self playNotificationSound];
    
    // notify observers
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveNewMessage
                                                        object:nil userInfo:@{kMessage: message}];
}

- (void)chatRoomDidReceiveMessage:(QBChatMessage *)message fromRoomJID:(NSString *)roomJID{
    // play sound notification
    [self playNotificationSound];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationDidReceiveNewMessageFromRoom
                                                        object:nil userInfo:@{kMessage: message, kRoomJID: roomJID}];
}

- (void)sendPushMessage:(NSMutableDictionary *)pushBody toUsers:(NSString *)users successBlock:(void (^)())successBlock errorBlock:(void (^)())errorBlock {
    
    NSMutableDictionary *payload = [NSMutableDictionary dictionary];
    NSMutableDictionary *aps = [NSMutableDictionary dictionary];
    [aps setObject:@"default" forKey:QBMPushMessageSoundKey];
    [aps setObject:pushBody forKey:QBMPushMessageAlertKey];
    [payload setObject:aps forKey:QBMPushMessageApsKey];
    
    QBMPushMessage *pushMessage = [[QBMPushMessage alloc] initWithPayload:payload];
    
    // Send push message to users
    [QBRequest sendPush:pushMessage toUsers:users successBlock:successBlock errorBlock:errorBlock];
}

#pragma mark
#pragma mark Additional

static SystemSoundID soundID;
- (void)playNotificationSound
{
    if(soundID == 0){
        NSString *path = [NSString stringWithFormat: @"%@/sound.mp3", [[NSBundle mainBundle] resourcePath]];
        NSURL *filePath = [NSURL fileURLWithPath: path isDirectory: NO];

        AudioServicesCreateSystemSoundID((__bridge CFURLRef)filePath, &soundID);
    }
    
    AudioServicesPlaySystemSound(soundID);
}

- (void)sortDialogsArrayByDate:(NSMutableArray *)dialogs {
    
    for (int i = 0; i < [dialogs count]; i++) {
        QBChatDialog *date1 = [dialogs objectAtIndex:i];
        for (int j = i + 1; j < [dialogs count]; j++) {
            QBChatDialog *date2 = [dialogs objectAtIndex:j];
            if ([date1.lastMessageDate compare:date2.lastMessageDate] == NSOrderedAscending) {
                [dialogs exchangeObjectAtIndex:i withObjectAtIndex:j];
            }
        }
    }
}

@end
