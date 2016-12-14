//
// ChoosePersonView.m
//
// Copyright (c) 2014 to present, Brian Gesiak @modocache
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "ChoosePersonView.h"
#import "ImageLabelView.h"
#import "Person.h"
#import "Constant.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "AMRatingControl.h"
static const CGFloat ChoosePersonViewImageLabelWidth = 42.f;

@interface ChoosePersonView ()
@property (nonatomic, strong) UIImageView *profileImgView;
@property (nonatomic, strong) UIView *informationView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) ImageLabelView *cameraImageLabelView;
@property (nonatomic, strong) ImageLabelView *interestsImageLabelView;
@property (nonatomic, strong) ImageLabelView *friendsImageLabelView;
@end

@implementation ChoosePersonView

#pragma mark - Object Lifecycle

- (instancetype)initWithFrame:(CGRect)frame
                       person:(Person *)person
                      options:(MDCSwipeToChooseViewOptions *)options {
    self = [super initWithFrame:frame options:options];
    if (self) {
        _person = person;
        
        [self constructInformationView];
    }
    return self;
}

#pragma mark - Internal Methods

- (void)constructInformationView {
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self.imageView setImageWithURL:[NSURL URLWithString:_person.userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default] ;
    
    self.autoresizingMask = UIViewAutoresizingFlexibleHeight |
    UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleBottomMargin;
    self.imageView.autoresizingMask = self.autoresizingMask;
    
    
    CGFloat bottomHeight = CGRectGetHeight(self.bounds) - self.imageView.bounds.size.height;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(self.bounds) - 150,
                                    CGRectGetWidth(self.bounds),
                                    150);
    _informationView = [[UIView alloc] initWithFrame:bottomFrame];
    _informationView.backgroundColor = [UIColor whiteColor];
    _informationView.clipsToBounds = YES;
    _informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
                                        UIViewAutoresizingFlexibleTopMargin;
    
    if([_person.userInfo[@"on_fire"] integerValue] == 1 && [_person.userInfo[@"sex"] integerValue] == 2) {
        _informationView.backgroundColor = [UIColor colorWithRed:244.f/255 green:204.f/255 blue:204.f/255 alpha:1.0];
    }
    [self addSubview:_informationView];

    [self constructNameLabel];
  //  [self constructCameraImageLabelView];
  //  [self constructInterestsImageLabelView];
  //  [self constructFriendsImageLabelView];
}

- (void)constructNameLabel {
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 6.f;
    CGRect nameframe = CGRectMake(leftPadding,
                              topPadding,
                              floorf(CGRectGetWidth(_informationView.frame)/2),
                              24);
    _nameLabel = [[UILabel alloc] initWithFrame:nameframe];
    _nameLabel.text = [NSString stringWithFormat:@"%@, %@", _person.userInfo[@"facebook_name"], _person.userInfo[@"age"]];
    _nameLabel.font = [UIFont systemFontOfSize:17];
    [_informationView addSubview:_nameLabel];
    
    CGRect distanceframe = CGRectMake(floorf(CGRectGetWidth(_informationView.frame)/2) ,
                                  topPadding,
                                  floorf(CGRectGetWidth(_informationView.frame)/2) - leftPadding ,
                                  24);
    UILabel *distanceLbl = [[UILabel alloc] initWithFrame:distanceframe];
    distanceLbl.text = [NSString stringWithFormat:@"%.fKm", [_person.userInfo[@"distance_to_user"] floatValue]];
    distanceLbl.textAlignment = NSTextAlignmentRight;
    distanceLbl.textColor = [UIColor lightGrayColor];
    distanceLbl.font = [UIFont systemFontOfSize:13];
    [_informationView addSubview:distanceLbl];
    
    topPadding = 32;
    CGRect schoolFrm = CGRectMake(leftPadding,
                                  topPadding,
                                  floorf(CGRectGetWidth(_informationView.frame) - leftPadding*2),
                                  20);
    UILabel *schoolLbl = [[UILabel alloc] initWithFrame:schoolFrm];
    schoolLbl.text = _person.userInfo[@"studies_in"];
    schoolLbl.textColor = [UIColor lightGrayColor];
    schoolLbl.font = [UIFont systemFontOfSize:13];
    [_informationView addSubview:schoolLbl];
    
    topPadding = 50;
    CGRect moodFrm = CGRectMake(leftPadding,
                                  topPadding,
                                  floorf(CGRectGetWidth(_informationView.frame) - leftPadding*2),
                                  30);
    UILabel *moodLbl = [[UILabel alloc] initWithFrame:moodFrm];
    NSString *tmpStr = _person.userInfo[@"mood_today"];
    moodLbl.text =  [moodArray objectAtIndex:tmpStr.integerValue-1];
    moodLbl.textColor = [UIColor colorWithRed:224.f/255 green:33.f/255 blue:138.f/255 alpha:1.0];
    moodLbl.font = [UIFont systemFontOfSize:17];
    [_informationView addSubview:moodLbl];

    topPadding = 78;
    CGRect voteFrm = CGRectMake(leftPadding,
                                topPadding,
                                floorf(CGRectGetWidth(_informationView.frame) - leftPadding*2),
                                30);
    UILabel *voteLbl = [[UILabel alloc] initWithFrame:voteFrm];
    voteLbl.text = @"Votes of the public";
    [_informationView addSubview:voteLbl];
    
    
    UIImage *dot = [UIImage imageNamed:@"star_empty.png"];
    UIImage *star = [UIImage imageNamed:@"star_gold.png"];
    AMRatingControl *imagesRatingControl = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding, 108)
                                                                          emptyImage:dot
                                                                          solidImage:star
                                                                        andMaxRating:5];
    [imagesRatingControl setEnabled:false];
    NSString *rate = _person.userInfo[@"ave_vote"];
    [imagesRatingControl setRating:rate.integerValue];
    [_informationView addSubview:imagesRatingControl];
    
    CGFloat infoBttnWH = 32;
    UIButton *infoBttn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(_informationView.frame)-leftPadding-infoBttnWH, 106, infoBttnWH, infoBttnWH)];
    [infoBttn setImage:[UIImage imageNamed:@"info"] forState:UIControlStateNormal];
    [infoBttn addTarget:self action:@selector(click_userInfoBttn) forControlEvents:UIControlEventTouchUpInside];
    [_informationView addSubview:infoBttn];
    
}
- (void) click_userInfoBttn{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"clickUserDetail" object:self userInfo:nil];
}

- (ImageLabelView *)buildImageLabelViewLeftOf:(CGFloat)x image:(UIImage *)image text:(NSString *)text {
    CGRect frame = CGRectMake(x - ChoosePersonViewImageLabelWidth,
                              0,
                              ChoosePersonViewImageLabelWidth,
                              CGRectGetHeight(_informationView.bounds));
    ImageLabelView *view = [[ImageLabelView alloc] initWithFrame:frame
                                                           image:image
                                                            text:text];
    view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    return view;
}

@end
