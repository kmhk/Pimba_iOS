//
//  MenuViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
@interface MenuViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak) ICSDrawerController *drawer;

@end
