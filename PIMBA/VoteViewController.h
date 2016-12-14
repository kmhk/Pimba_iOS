//
//  VoteViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface VoteViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    
    IBOutlet UICollectionView *CollectionView;
    IBOutlet UIView *navBarView;
    
    IBOutlet UIView *confirmContentView;
    IBOutlet UIImageView *confirm_userImgView;
    IBOutlet UILabel *confirm_noteLbl;
    
    IBOutlet UIScrollView *pendingUser_scrollview;
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
- (IBAction)click_actionBttn:(UIButton *)sender;

@end
