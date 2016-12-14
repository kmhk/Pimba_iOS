//
//  PendingUserTableviewCell.m
//  PIMBA
//
//  Created by herocules on 3/21/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "PendingUserTableviewCell.h"

@implementation PendingUserTableviewCell

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        NSString *className = @"PendingUserTableviewCell";
        [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] ;
        
        [self addSubview:self.cellView];
    }
    return  self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSString *className = @"PendingUserTableviewCell";
        [[NSBundle mainBundle] loadNibNamed:className owner:self options:nil] ;
        
        [self addSubview:self.cellView];
        
    }
    return self;
}

@end
