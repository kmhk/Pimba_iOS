//
//  ChatViewController.m
//  PIMBA
//
//  Created by herocules on 3/16/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "ChatViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
#import <AudioToolbox/AudioServices.h>
#import "ProfileViewController.h"
#import <CRToast/CRToast.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
@interface ChatViewController ()
{
    NSMutableArray *messages;
    JSQMessagesAvatarImage *userPhoto;
    
}
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    messages = [NSMutableArray new];
    
    self.userName = self.userInfo[@"facebook_name"];
    self.userId = self.userInfo[@"facebook_id"];
    
    
    self.title = self.userName;
    [self.navigationController.navigationBar setTintColor:[UIColor darkGrayColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                          target:self
                                                                                          action:@selector(closePressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(didPressAccessoryButton:)];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ChattingNotification" object:nil];
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
  //  userPhoto = [JSQMessagesAvatarImageFactory avatarImageWithImage:self.userImage
  //                                                         diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    self.inputToolbar.contentView.leftBarButtonItem = nil;
    
    self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor ]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleBlueColor]];
    
    [self getMessageList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated{
    [IQKeyboardManager sharedManager].enable = false;
    [IQKeyboardManager sharedManager].enableAutoToolbar = false;
    [userdefault setObject:Yes forKey:kChatWindow];
}
- (void) viewWillDisappear:(BOOL)animated{
    [IQKeyboardManager sharedManager].enable = true;
    [IQKeyboardManager sharedManager].enableAutoToolbar = true;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [userdefault setObject:No forKey:kChatWindow];
}
-(void)pushNotificationReceived:(NSNotification *)anote
{
    NSDictionary *dic = anote.userInfo;
    
    if([dic[@"sender_facebook_id"] isEqual:self.userId]){
                
        
        NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
        
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
        NSString *tmpstr = dic[@"datetime"];
        NSDate *date = [dateFormatter dateFromString:tmpstr];
        
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:dic[@"sender_facebook_id"]
                                                 senderDisplayName:@" "
                                                              date:date
                                                              text:dic[@"message_content"]];
        
        [messages addObject:message];
        [self finishReceivingMessageAnimated:YES];
        [self setMessageRead:dic[@"message_id"]];
    }
    
}

- (void) setMessageRead:(NSString*)messageId{
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"message_id":messageId};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"update_read_message"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
       
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];
}

- (void) closePressed:(UIButton*)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) morePressed:(UIButton*)sender{
    
}
- (void) getMessageList{
    /*get_chat_history	
     
     	facebook_id_mine
     	facebook_id_other
     */
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":self.userId};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_chat_history"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"get_chat_history: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            NSArray *tmpAry = [[NSArray alloc] initWithArray:[responseObject objectForKey:@"result"]];
            for (int i = 0; i < tmpAry.count; i++) {
                NSDateFormatter *dateFormatter= [[NSDateFormatter alloc] init];
                
                [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];

                NSString *tmpstr = tmpAry[i][@"date_time"];
                NSDate *date = [dateFormatter dateFromString:tmpstr];
                
                JSQMessage *message = [[JSQMessage alloc] initWithSenderId:tmpAry[i][@"facebook_id_sender"]
                                                         senderDisplayName:@" "
                                                                      date:date
                                                                      text:tmpAry[i][@"message_content"]];
                
                [messages addObject:message];
            }
            [self finishSendingMessageAnimated:YES];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:[responseObject objectForKey:@"ref_message"]
                                        message:@""
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];

}

- (void) sendMessage:(NSString*)messageStr{
    /*send_chatMessage	
     
     	facebook_id_mine
     	facebook_id_other
     	message_content
     */
    NSString *str = [messageStr stringByReplacingOccurrencesOfString:@"'" withString:@"\'"];
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":self.userId,
                                 @"message_content":str};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"send_chatMessage"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        HideNetworkActivityIndicator();
        NSLog(@"send_chatMessage: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            
        }
        else{
            [[[UIAlertView alloc] initWithTitle:[responseObject objectForKey:@"ref_message"]
                                        message:@""
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];
    
}
#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
      SystemSoundID completeSound;
        NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"message-send" withExtension:@"mp3"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
        AudioServicesPlaySystemSound (completeSound);  
    }
    
    
    [self sendMessage:text];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];
    
    [messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"Show profile", @"Unmatch",nil];
    sheet.delegate = self;
    [sheet showFromToolbar:self.inputToolbar];
}
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    NSLog(@"%ld", (long)buttonIndex);
    NSString *title = [popup buttonTitleAtIndex:buttonIndex];
    if([title  isEqual: @"Cancel"]) return;
    
    if(buttonIndex==0){
        ProfileViewController *sub = [[ProfileViewController alloc] init];
        sub.profileInfo = [[NSMutableDictionary alloc] initWithDictionary:self.userInfo];
        [self presentViewController:sub animated:YES completion:nil];
    }
    else if(buttonIndex == 1){
        [self setUnmatch];
    }
}


#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    return nil;//[[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    
    
    JSQMessage *msg = [messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:@"Custom Action"
                                message:nil
                               delegate:nil
                      cancelButtonTitle:@"OK"
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}

- (void) setUnmatch{
    /*unmatch	
     
     	facebook_id_mine
     	facebook_id_other
     */
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":self.userId
                                 };
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"unmatch"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        HideNetworkActivityIndicator();
        NSLog(@"unmatch: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        else{
            [[[UIAlertView alloc] initWithTitle:[responseObject objectForKey:@"ref_message"]
                                        message:@""
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];

}
@end
