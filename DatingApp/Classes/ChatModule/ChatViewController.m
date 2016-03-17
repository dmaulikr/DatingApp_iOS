//
//  ChatViewController.m
//  DatingApp
//
//  Created by jayesh jaiswal on 08/08/14.
//  Copyright (c) 2014 KytesCorporation. All rights reserved.
//

#import "ChatViewController.h"
#import "SideBarViewController.h"
#import "AsyncImageView.h"
#import "ChatService.h"
#import "LocalStorageService.h"
#import "ChatMessageTableViewCell.h"
#import "ChatHistoryViewController.h"
#import "UIImageView+AFNetworking.h"
#import "ProfileViewController.h"
#import "CommonUtils.h"

@interface ChatViewController () <UITableViewDelegate, UITableViewDataSource, QBActionStatusDelegate> {
    
    ProfileDetails *currentRecipient;
    NSUInteger offset;
}

@property (strong, nonatomic) SideBarViewController *objSBVC;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) QBChatRoom *chatRoom;

@end

@implementation ChatViewController

static ChatViewController *instance;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLoad {
    
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:NO];
    
    instance = self;
    
    // Set keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
    // Set chat notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDidReceiveProcessedMessageNotification:)
                                                 name:kNotificationDidReceiveProcessedMessage object:nil];
    
    // Initialize view elements and class members
    [self initViewAndClassMembers];
}

- (void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    instance = nil;
    
    // unregister for keyboard notifications
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

// Initialize view elements and class members
- (void) initViewAndClassMembers {
    
    self.messageTextField.delegate = self;
    currentRecipient = appSharedData.selectedRecipient;
    self.dialog = appSharedData.createdDialog;
    
    // display recipient name on top bar
    NSString *dialogName = currentRecipient.strName;
    if (dialogName == nil || [dialogName isEqualToString:KNullValue]) {
        self.recipientName.text = @"no recipient";
    } else {
        self.recipientName.text = dialogName;
    }
    
    self.messages = [[NSMutableArray alloc] init];
    self.messagesTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    if (self.dialog != nil) {
        [[CommonUtils shared] showActivityIndicator:self.view];
        [QBChat messagesWithDialogID:self.dialog.ID extendedRequest:nil delegate:self];
    }
}

- (void) didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    
    return UIStatusBarStyleLightContent;
}

+ (ChatViewController *)sharedInstance {
    
    return instance;
}

#pragma mark
#pragma mark Keyboard notifications
- (void)keyboardWillShow:(NSNotification *)note {
    
    // [self.messageScrollView setContentOffset:CGPointMake(0, 205) animated:YES];
    
    NSDictionary *userInfo = [note userInfo];
    CGSize size = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    offset = size.height - self.tabBarController.tabBar.frame.size.height;
    
    CGRect frame = CGRectMake(self.messagesTableView.frame.origin.x,
                              self.messagesTableView.frame.origin.y,
                              self.messagesTableView.frame.size.width,
                              self.messagesTableView.frame.size.height-offset);
    messageInputBox.frame = CGRectMake(messageInputBox.frame.origin.x, messageInputBox.frame.origin.y - offset, messageInputBox.frame.size.width, messageInputBox.frame.size.height);
    self.messagesTableView.frame = frame;
}

- (void)keyboardWillHide:(NSNotification *)note {
    
//    [self.messageScrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    
    CGRect frame = CGRectMake(self.messagesTableView.frame.origin.x,
                              self.messagesTableView.frame.origin.y,
                              self.messagesTableView.frame.size.width,
                              self.messagesTableView.frame.size.height+offset);
    messageInputBox.frame = CGRectMake(messageInputBox.frame.origin.x, messageInputBox.frame.origin.y + offset, messageInputBox.frame.size.width, messageInputBox.frame.size.height);
    self.messagesTableView.frame = frame;
}

#pragma mark
#pragma mark UITableViewDelegate & UITableViewDataSource
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ChatMessageCellIdentifier = @"ChatMessageCellIdentifier";
    
    ChatMessageTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ChatMessageCellIdentifier];
    if(cell == nil){
        cell = [[ChatMessageTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ChatMessageCellIdentifier];
    }
    
    cell.backgroundColor = [UIColor colorWithRed:8 / 255.0 green:15 / 255.0 blue:21 / 255.0 alpha:1];
    
    QBChatAbstractMessage *message = self.messages[indexPath.row];
    //
    if (indexPath.row == [self.messages count] - 1) {
        cell.isLastMessage = YES;
    } else {
        cell.isLastMessage = NO;
    }
    [cell configureCellWithMessage:message recipientImageUrl:currentRecipient.strProfilePicture];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    QBChatAbstractMessage *chatMessage = [self.messages objectAtIndex:indexPath.row];
    CGFloat cellHeight = [ChatMessageTableViewCell heightForCellWithMessage:chatMessage];
    return cellHeight;
}

#pragma mark
#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)didTapSendButton:(UIButton *)sender {
    
    [self sendMessage];
}

- (IBAction)didTapBackButton:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)didTapMoreButton:(UIButton *)sender {
    
    NSString *other1 = [NSString stringWithFormat:@"Show %@'s Profile", currentRecipient.strName];
    NSString *cancelTitle = @"Cancel";
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelTitle destructiveButtonTitle:nil otherButtonTitles:other1, nil];
    [actionSheet showInView:self.messageScrollView];
    actionSheet = nil;
}

#pragma mark
#pragma mark Chat Notifications
- (void)chatDidReceiveProcessedMessageNotification:(NSNotification *)notification{
    
    QBChatMessage *message = notification.object[kMessage];
    NSUInteger recipientID = [currentRecipient getQuickbloxUserID];
    
    if(message.senderID != recipientID){
        return;
    }
    
    [self.messages addObject:message];
    // Reload table
    [self.messagesTableView reloadData];
    if (self.messages.count > 0) {
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                      atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark
#pragma mark Actions

- (void)sendMessage {
    
    if (self.messageTextField.text.length == 0) {
        return;
    }
    
    // create a message
    QBChatMessage *message = [[QBChatMessage alloc] init];
    message.text = self.messageTextField.text;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"save_to_history"] = @YES;
    [message setCustomParameters:params];
    
    // 1-1 Chat
    if (self.dialog.type == QBChatDialogTypePrivate){
        // send message
        message.recipientID = [self.dialog recipientID];
        message.senderID = [[[LocalStorageService shared] getSavedAuthUserInfo] getQuickbloxUserID];
        
        [[ChatService instance] sendMessage:message];
        
        // save message
        [self.messages addObject:message];
    } else {
        [[ChatService instance] sendMessage:message toRoom:self.chatRoom];
    }
    
    appSharedData.isDialogsUpdated = YES;
    
    // Reload table
    [self.messagesTableView reloadData];
    if (self.messages.count > 0){
        [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count] - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
    
    // Clean text field
    [self.messageTextField setText:nil];
}

#pragma mark -
#pragma mark QBActionStatusDelegate

- (void)completedWithResult:(Result *)result {
    
    [[CommonUtils shared] hideActivityIndicator];
    if (result.success && [result isKindOfClass:QBChatHistoryMessageResult.class]) {
        QBChatHistoryMessageResult *res = (QBChatHistoryMessageResult *)result;
        NSArray *messages = res.messages;
        self.messages = [[NSMutableArray alloc] init];
        [self.messages addObjectsFromArray:[messages mutableCopy]];
        //
        [self.messagesTableView reloadData];
        if ([self.messages count] > 0){
            [self.messagesTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[self.messages count]-1 inSection:0]
                                          atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }
    }
}

#pragma mark - UIActionSheet delegate Method
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {

    if (buttonIndex == 0) {
        ProfileViewController * objPVC =
        (ProfileViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"ProfileViewController"];
        objPVC.userProfile = currentRecipient;
        objPVC.fromChatSession = YES;
        objPVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [self.navigationController pushViewController:objPVC animated:YES];
    }
}

@end
