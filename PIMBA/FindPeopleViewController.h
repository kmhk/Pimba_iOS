//
//  FindPeopleViewController.h
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ICSDrawerController.h"
#import "ChoosePersonView.h"

@interface FindPeopleViewController : UIViewController<ICSDrawerControllerChild, ICSDrawerControllerPresenting, MDCSwipeToChooseDelegate>

{
    IBOutlet UIView *navBarView;
    IBOutlet UIImageView *fire_imgView;
    IBOutlet UIButton *fire_bttn;
    
    
    IBOutlet UIView *imgContentView;
    IBOutlet UIImageView *imgView;
    
    
    IBOutlet UIView *actionContentView;
    
    IBOutlet UIView *userDetailContentView;
    IBOutlet UIScrollView *userDetailScrollView;
    IBOutlet UIImageView *userDetailImgView;
    IBOutlet UIButton *userDetailCancel_bttn;
    
    
}

@property (strong, nonatomic) NSDictionary *pushInfo;

@property(nonatomic, weak) ICSDrawerController *drawer;

@property (nonatomic, strong) Person *currentPerson;
@property (nonatomic, strong) ChoosePersonView *frontCardView;
@property (nonatomic, strong) ChoosePersonView *backCardView;
- (IBAction)img_bttnDown:(id)sender;
- (IBAction)img_bttnUpInside:(id)sender;
- (IBAction)img_bttnUpOutside:(id)sender;


- (IBAction)click_actionBttn:(UIButton *)sender;
- (IBAction)click_fireBttn:(id)sender;
- (IBAction)click_detailCancelBttn:(id)sender;

- (IBAction)click_menuBttn:(id)sender;
@end
