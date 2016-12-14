//
//  UserMatchViewController.h
//  PIMBA
//
//  Created by herocules on 3/1/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserMatchViewController : UIViewController
{
    
    IBOutlet UILabel *note_lbl;
    IBOutlet UIImageView *mePhoto_imgview;
    IBOutlet UIImageView *otherPhoto_imgview;
    IBOutlet UIButton *talk_bttn;
}

@property (strong, nonatomic) NSDictionary *userInfo;

- (IBAction)click_talkBttn:(id)sender;
- (IBAction)click_continueBttn:(id)sender;
@end
