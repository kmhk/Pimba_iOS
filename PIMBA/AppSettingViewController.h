//
//  AppSettingViewController.h
//  PIMBA
//
//  Created by herocules on 3/1/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppSettingViewController : UIViewController
{
    
    IBOutlet UITableView *TableView;
}
@property (strong, nonatomic) NSDictionary *settingInfo;
@end
