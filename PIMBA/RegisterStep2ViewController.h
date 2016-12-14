//
//  RegisterStep2ViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegisterStep2ViewController : UIViewController
{
    IBOutlet UILabel *welcome_lbl;
    
    IBOutlet UILabel *name_lbl;
    IBOutlet UILabel *mood_lbl;
    IBOutlet UITextField *school_txtfld;
    IBOutlet UITextField *description_txtfld;
    
}
@property (strong, nonatomic) NSArray *imgArray;
@property (strong, nonatomic) NSDictionary *userInfo;
- (IBAction)click_doneBttn:(UIButton *)sender;
- (IBAction)click_selectMoodBttn:(id)sender;

@end
