//
//  CheckInViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface CheckInViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    IBOutlet UITableView *TableView;
    
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;

- (IBAction)click_checkinBttn:(id)sender;
- (IBAction)click_findpeopleBttn:(id)sender;

@end
