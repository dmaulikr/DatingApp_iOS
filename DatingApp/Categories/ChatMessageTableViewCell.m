//
//  ChatMessageTableViewCell.m
//  sample-chat
//
//  Created by Igor Khomenko on 10/19/13.
//  Copyright (c) 2013 Igor Khomenko. All rights reserved.
//

#import "ChatMessageTableViewCell.h"
#import "LocalStorageService.h"
#import "AsyncImageView.h"
#import "UIImageView+AFNetworking.h"
#import "CommonUtils.h"

#define padding 20
#define recipientImageSize 36

@implementation ChatMessageTableViewCell

static NSDateFormatter *messageDateFormatter;
static UIImage *orangeBubble;
static UIImage *aquaBubble;

+ (void)initialize{
    [super initialize];
    
    // init bubbles
    orangeBubble = [[UIImage imageNamed:@"orangeBubble"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
    aquaBubble = [[UIImage imageNamed:@"aquaBubble"] stretchableImageWithLeftCapWidth:24  topCapHeight:15];
}

+ (CGFloat)heightForCellWithMessage:(QBChatAbstractMessage *)message {
    
    NSString *text = message.text;
	CGSize textSize = {210.0, 10000.0};
	CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:13]
                   constrainedToSize:textSize
                       lineBreakMode:NSLineBreakByWordWrapping];
	size.height += 45.0 + recipientImageSize / 2;
	return size.height;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.dateLabel = [[UILabel alloc] init];
        [self.dateLabel setFrame:CGRectMake(10, 0, 300, 20)];
        [self.dateLabel setFont:[UIFont systemFontOfSize:11.0]];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        [self.dateLabel setTextColor:[UIColor whiteColor]];
        [self.contentView addSubview:self.dateLabel];
        
        self.backgroundImageView = [[UIImageView alloc] init];
        [self.backgroundImageView setFrame:CGRectZero];
		[self.contentView addSubview:self.backgroundImageView];
        
        self.recipientImage = [[UIImageView alloc] init];
        [self.recipientImage setFrame:CGRectZero];
        [self.contentView addSubview:self.recipientImage];
        
		self.messageTextView = [[UITextView alloc] init];
        [self.messageTextView setFont:[UIFont fontWithName:@"Symbol" size:15]];
        [self.messageTextView setBackgroundColor:[UIColor clearColor]];
        [self.messageTextView setEditable:NO];
        [self.messageTextView setScrollEnabled:NO];
		[self.messageTextView sizeToFit];
		[self.contentView addSubview:self.messageTextView];
    }
    return self;
}

- (void)configureCellWithMessage:(QBChatAbstractMessage *)message recipientImageUrl:(NSString *)imageUrl {
    
    self.messageTextView.text = message.text;
    
    CGSize textSize = { 210.0, 10000.0 };
    
	CGSize size = [self.messageTextView.text sizeWithFont:[UIFont boldSystemFontOfSize:15]
                                        constrainedToSize:textSize
                                            lineBreakMode:NSLineBreakByWordWrapping];
    size.width += 10;
    
    // Left/Right bubble
    if ([[[LocalStorageService shared] getSavedAuthUserInfo] getQuickbloxUserID] != message.senderID) {
        // Left Bubble - recipient
        //
        // Place recipient message
        [self.messageTextView setFrame:CGRectMake(padding + recipientImageSize, padding+5, size.width, size.height+padding)];
        [self.messageTextView sizeToFit];
        self.messageTextView.textColor = [UIColor blackColor];
        
        // Place recipient image
        [self.recipientImage setFrame:CGRectMake(padding/2, padding + self.messageTextView.bounds.size.height - recipientImageSize / 2, recipientImageSize, recipientImageSize)];
        self.recipientImage.hidden = NO;
        self.recipientImage.layer.cornerRadius = recipientImageSize / 2;
        self.recipientImage.layer.masksToBounds = YES;
        self.recipientImage.contentMode = UIViewContentModeScaleAspectFill;
        [self.recipientImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"no_image_available.png"]];
        
        [self.backgroundImageView setFrame:CGRectMake(padding/2 + recipientImageSize, padding+5,
                                                      self.messageTextView.frame.size.width+padding/2, self.messageTextView.frame.size.height+5)];
        self.backgroundImageView.image = orangeBubble;
    } else {
        self.recipientImage.hidden = YES;
        // Right Bubble - user - sender
        [self.messageTextView setFrame:CGRectMake(320 - size.width - 10, padding+5, size.width, size.height+padding)];
        [self.messageTextView sizeToFit];
        self.messageTextView.textColor = [UIColor whiteColor];
        
        [self.backgroundImageView setFrame:CGRectMake(320 - size.width - 15, padding+5,
                                                      self.messageTextView.frame.size.width+15, self.messageTextView.frame.size.height+5)];
        self.backgroundImageView.image = aquaBubble;
    }
    
    // show message time
    self.dateLabel.text = [NSString stringWithFormat:@"%@", [[CommonUtils shared] convertDateToString:message.datetime withFormat:@"MM/dd/yyyy, h:mm a"]];
    if (self.isLastMessage) {
        if ([[[LocalStorageService shared] getSavedAuthUserInfo] getQuickbloxUserID] != message.senderID) {
            self.dateLabel.textAlignment = NSTextAlignmentLeft;
        } else {
            self.dateLabel.textAlignment = NSTextAlignmentRight;
        }
        self.dateLabel.hidden = NO;
    } else {
        self.dateLabel.hidden = YES;
    }
}

@end
