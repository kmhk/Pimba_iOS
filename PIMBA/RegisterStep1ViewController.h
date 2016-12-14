//
//  RegisterStep1ViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStep1ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

{
    IBOutlet UILabel *welcome_lbl;
    
    IBOutlet UIImageView *profileImg_1;
    IBOutlet UIImageView *profileImg_2;
    IBOutlet UIImageView *profileImg_3;
    IBOutlet UIImageView *profileImg_4;
    
}
- (IBAction)click_addImgBttn:(UIButton *)sender;

- (IBAction)click_nextBttn:(id)sender;
@property (strong, nonatomic) NSDictionary *userInfo;
@end
