//
//  ProfileViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMRatingControl.h"
@interface ProfileViewController : UIViewController
{
    IBOutlet UIView *navView;
    
    IBOutlet UILabel *edit_lbl;
    IBOutlet UIButton *editBttn;
    
    
    IBOutlet UIScrollView *ScrollView;
    IBOutlet UIScrollView *profileImg_scrollView;
    
    IBOutlet UIPageControl *pageCtrl;
    
    IBOutlet UILabel *profileName_lbl;
    IBOutlet UILabel *distance_lbl;
    IBOutlet UILabel *school_lbl;
    IBOutlet UILabel *mood_lbl;
    
    IBOutlet UIView *description_contentView;
    IBOutlet UILabel *description_lbl;
    
    IBOutlet UIView *rate_contentView;
    IBOutlet AMRatingControl *charm_rateView;
    IBOutlet AMRatingControl *humor_rateView;
    IBOutlet AMRatingControl *chat_rateView;
    IBOutlet AMRatingControl *beauty_rateView;
    IBOutlet AMRatingControl *horny_rateView;
}
- (IBAction)click_menuBttn:(id)sender;
- (IBAction)click_editBttn:(id)sender;

@property (strong, nonatomic) NSMutableDictionary *profileInfo;
@end
