//
//  DestinyViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface DestinyViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    IBOutlet UICollectionView *CollectionView;
    
    IBOutlet UIView *userDetail_ContentView;
    
    IBOutlet UIScrollView *userDetail_scrollView;
    IBOutlet UIImageView *userDetail_imgView;
    
    IBOutlet UIButton *userDetail_cancelBttn;
    
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
- (IBAction)click_actBttn:(UIButton*)sender;
- (IBAction)click_detailCancelBttn:(id)sender;
@end
