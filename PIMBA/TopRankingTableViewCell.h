//
//  TopRankingTableViewCell.h
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TopRankingTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *user_imgview;
@property (strong, nonatomic) IBOutlet UILabel *username_lbl;
@property (strong, nonatomic) IBOutlet UILabel *index_lbl;
@property (strong, nonatomic) IBOutlet UILabel *score_lbl;
@end
