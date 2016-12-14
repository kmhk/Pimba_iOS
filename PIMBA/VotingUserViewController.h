//
//  VotingUserViewController.h
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMRatingControl.h"
@interface VotingUserViewController : UIViewController
{
    IBOutlet UIImageView *userProfile_imgView;
    IBOutlet UILabel *userName_lbl;
    IBOutlet AMRatingControl *charm_rateCtrl;
    IBOutlet AMRatingControl *humor_rateCtrl;
    IBOutlet AMRatingControl *chat_rateCtrl;
    IBOutlet AMRatingControl *beauty_rateCtrl;
    IBOutlet AMRatingControl *horny_rateCtrl;
}
@property (strong, nonatomic) NSDictionary *userInfo;
@property (strong, nonatomic) NSString *voteType;
- (IBAction)click_actionBttn:(UIButton *)sender;
@end
