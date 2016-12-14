//
//  FindUserCheckinViewController.h
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChoosePersonView.h"
@interface FindUserCheckinViewController : UIViewController<MDCSwipeToChooseDelegate>
{
    IBOutlet UIView *navBarView;
    IBOutlet UIView *actionContentView;
    IBOutlet UILabel *place_lbl;
    
    IBOutlet UIView *userDetailContentView;
    IBOutlet UIScrollView *userDetailScrollView;
    IBOutlet UIImageView *userDetailImgView;
}
@property (nonatomic, strong) Person *currentPerson;
@property (nonatomic, strong) ChoosePersonView *frontCardView;
@property (nonatomic, strong) ChoosePersonView *backCardView;

@property (strong, nonatomic) NSMutableArray *people;
@property (strong, nonatomic) NSString *placeStr;
- (IBAction)click_actionBttn:(UIButton *)sender;
- (IBAction)click_cancelBttn:(id)sender;

@end
