//
//  MessageListViewController.h
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface MessageListViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>
{
    IBOutlet UIView *navBarView;
    IBOutlet UITableView *listTableView;
}
@property(nonatomic, weak) ICSDrawerController *drawer;
- (IBAction)click_menuBttn:(id)sender;
@end
