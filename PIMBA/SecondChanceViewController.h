//
//  SecondChanceViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface SecondChanceViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    
    IBOutlet UICollectionView *CollectionView;
    
    IBOutlet UIView *detail_contentView;
    IBOutlet UIScrollView *detail_scrollView;
    IBOutlet UIImageView *detail_userPhotoView;
    
    IBOutlet UIButton *detail_cancelBttn;
    
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
- (IBAction)click_actBttn:(UIButton*)sender;
- (IBAction)click_detailCancelBttn:(id)sender;
@end
