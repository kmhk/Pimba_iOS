//
//  PlayScore_FirstSightTableViewCell.h
//  PIMBA
//
//  Created by herocules on 3/14/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PieChartView.h"
@interface PlayScore_FirstSightTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet PieChartView *chartView;
@property (strong, nonatomic) IBOutlet UILabel *pimba_lbl;
@property (strong, nonatomic) IBOutlet UILabel *noPimba_lbl;

@end
