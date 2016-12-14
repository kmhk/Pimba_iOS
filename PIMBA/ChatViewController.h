//
//  ChatViewController.h
//  PIMBA
//
//  Created by herocules on 3/16/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <JSQMessagesViewController/JSQMessages.h>

@class ChatViewController;
@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatViewController *)vc;

@end


@interface ChatViewController : JSQMessagesViewController<UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate>

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSDictionary *userInfo;



@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;


@end
