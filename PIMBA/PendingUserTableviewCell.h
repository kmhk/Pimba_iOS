//
//  PendingUserTableviewCell.h
//  PIMBA
//
//  Created by herocules on 3/21/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingUserTableviewCell : UIView
@property (strong, nonatomic) IBOutlet UIView *cellView;
@property (strong, nonatomic) IBOutlet UIImageView *userProfile_ImgView;
@property (strong, nonatomic) IBOutlet UILabel *userName_lbl;

@end
