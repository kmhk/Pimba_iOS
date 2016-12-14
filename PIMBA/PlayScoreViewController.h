//
//  PlayScoreViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface PlayScoreViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    
    IBOutlet UIImageView *profileImgView;
    IBOutlet UILabel *userNameAgeLbl;
    
    IBOutlet UITableView *userDetailTableView;
    
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
@end
