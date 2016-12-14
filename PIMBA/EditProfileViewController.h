//
//  EditProfileViewController.h
//  PIMBA
//
//  Created by herocules on 3/23/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditProfileViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate,UIActionSheetDelegate>
{
    
    IBOutlet UITableView *UserTableView;
}
@property (strong, nonatomic) NSMutableDictionary *profileInfo;
- (IBAction)click_doneBttn:(id)sender;
@end
