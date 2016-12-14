//
//  ProfileImageTableViewCell.h
//  PIMBA
//
//  Created by herocules on 3/23/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIView *img1_contentView;
@property (strong, nonatomic) IBOutlet UIImageView *img1_view;
@property (strong, nonatomic) IBOutlet UILabel *idx1_lbl;
@property (strong, nonatomic) IBOutlet UIButton *cancel1_bttn;

@property (strong, nonatomic) IBOutlet UIView *img2_contentView;
@property (strong, nonatomic) IBOutlet UIImageView *img2_view;
@property (strong, nonatomic) IBOutlet UILabel *idx2_lbl;
@property (strong, nonatomic) IBOutlet UIButton *cancel2_bttn;

@property (strong, nonatomic) IBOutlet UIView *img3_contentView;
@property (strong, nonatomic) IBOutlet UIImageView *img3_view;
@property (strong, nonatomic) IBOutlet UILabel *idx3_lbl;
@property (strong, nonatomic) IBOutlet UIButton *cancel3_bttn;

@property (strong, nonatomic) IBOutlet UIView *img4_contentView;
@property (strong, nonatomic) IBOutlet UIImageView *img4_view;
@property (strong, nonatomic) IBOutlet UILabel *idx4_lbl;
@property (strong, nonatomic) IBOutlet UIButton *cancel4_bttn;
@end
