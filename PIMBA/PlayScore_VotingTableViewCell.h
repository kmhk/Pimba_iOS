//
//  PlayScore_VotingTableViewCell.h
//  PIMBA
//
//  Created by herocules on 3/14/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AMRatingControl.h"
@interface PlayScore_VotingTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *note_lbl;
@property (strong, nonatomic) IBOutlet AMRatingControl *charm_rateCtrl;
@property (strong, nonatomic) IBOutlet AMRatingControl *humor_rateCtrl;
@property (strong, nonatomic) IBOutlet AMRatingControl *chat_rateCtrl;
@property (strong, nonatomic) IBOutlet AMRatingControl *beauty_rateCtrl;
@property (strong, nonatomic) IBOutlet AMRatingControl *horny_rateCtrl;
@end
