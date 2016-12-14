//
//  SettingViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface SettingViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    IBOutlet UITableView *TableView;
    
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
@end
