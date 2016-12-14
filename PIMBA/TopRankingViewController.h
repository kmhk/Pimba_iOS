//
//  TopRankingViewController.h
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface TopRankingViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    
    IBOutlet UIView *navBarView;
    IBOutlet UILabel *country_lbl;
    IBOutlet UITableView *listTableView;
    IBOutlet UIButton *gender_womanBttn;
    IBOutlet UIButton *gender_manBttn;
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
- (IBAction)click_genderBttn:(UIButton *)sender;
@end
