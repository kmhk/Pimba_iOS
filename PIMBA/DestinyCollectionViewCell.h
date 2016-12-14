//
//  DestinyCollectionViewCell.h
//  PIMBA
//
//  Created by herocules on 3/3/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DestinyCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) IBOutlet UIImageView *userImgView;
@property (strong, nonatomic) IBOutlet UILabel *userNameLbl;
@property (strong, nonatomic) IBOutlet UILabel *timePlaceLbl;
@property (strong, nonatomic) IBOutlet UIButton *dislikeBttn;
@property (strong, nonatomic) IBOutlet UIButton *likeBttn;
@end
