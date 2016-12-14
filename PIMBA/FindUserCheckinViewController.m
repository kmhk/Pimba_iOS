//
//  FindUserCheckinViewController.m
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "FindUserCheckinViewController.h"
#import "Person.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

#import "Constant.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

#import "AMRatingControl.h"

@interface FindUserCheckinViewController ()
{
    BOOL showUserDetail;
    
    
    BOOL lastCardFlg;
    NSString *actionStr;
    NSString *fbOtherId;
}
@end

@implementation FindUserCheckinViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewSetting];
    actionStr = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserDetail) name:@"clickUserDetail" object:nil];
    [self displayMatchedUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navBarView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navBarView addSubview:lineV];
    
    place_lbl.text = self.placeStr;
}
- (void)displayMatchedUsers{
    
    [self.frontCardView removeFromSuperview];
    [self.backCardView removeFromSuperview];
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [self.view addSubview:self.frontCardView];
                        
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
                        actionContentView.hidden = false;
                       
                    }];
    
}
#pragma mark - MDCSwipeToChooseDelegate Protocol Methods

// This is called when a user didn't fully swipe left or right.
- (void)viewDidCancelSwipe:(UIView *)view {
    NSLog(@"You couldn't decide on %@.", self.currentPerson.name);
}

// This is called then a user swipes the view fully left or right.
- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
    
    if (direction == MDCSwipeDirectionLeft) {
        NSLog(@"You noped %@.", self.currentPerson.name);
        if([actionStr  isEqual: @""] && showUserDetail == NO)
            [self actionLikeDislike:action_dislike fbId:self.currentPerson.userInfo[@"facebook_id"]];
        
    } else {
        NSLog(@"You liked %@.", self.currentPerson.name);
        if([actionStr  isEqual: @""]&& showUserDetail == NO)
            [self actionLikeDislike:action_like fbId:self.currentPerson.userInfo[@"facebook_id"]];
    }
    actionStr = @"";
    
    
    self.frontCardView = self.backCardView;
    if(!self.frontCardView){
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    if ((self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]])) {
        
        self.backCardView.alpha = 0.f;
        [self.view insertSubview:self.backCardView belowSubview:self.frontCardView];
        [UIView animateWithDuration:0.5
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             self.backCardView.alpha = 1.f;
                         } completion:nil];
    }
    else{
        lastCardFlg = YES;
    }
}

#pragma mark - Internal Methods

- (void)setFrontCardView:(ChoosePersonView *)frontCardView {
    _frontCardView = frontCardView;
    self.currentPerson = frontCardView.person;
}

- (ChoosePersonView *)popPersonViewWithFrame:(CGRect)frame {
    if ([self.people count] == 0) {
        
        return nil;
    }
    
    MDCSwipeToChooseViewOptions *options = [MDCSwipeToChooseViewOptions new];
    options.delegate = self;
    options.threshold = 160.f;
    options.onPan = ^(MDCPanState *state){
        CGRect frame = [self backCardViewFrame];
        self.backCardView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y ,
                                             CGRectGetWidth(frame),
                                             CGRectGetHeight(frame));
    };
    
    
    ChoosePersonView *personView = [[ChoosePersonView alloc] initWithFrame:frame
                                                                    person:self.people[0]
                                                                   options:options];
    [self.people removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 16.f;
    CGFloat topPadding = 120.f;
    CGFloat bottomPadding = 80.f;
    return CGRectMake(horizontalPadding,
                      topPadding,
                      CGRectGetWidth(self.view.frame) - (horizontalPadding * 2),
                      CGRectGetHeight(self.view.frame) - bottomPadding-topPadding);
}

- (CGRect)backCardViewFrame {
    CGRect frontFrame = [self frontCardViewFrame];
    return CGRectMake(frontFrame.origin.x,
                      frontFrame.origin.y,
                      CGRectGetWidth(frontFrame),
                      CGRectGetHeight(frontFrame));
}
#pragma mark Control Events

// Programmatically "nopes" the front card view.
- (void)nopeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
}

// Programmatically "likes" the front card view.
- (void)likeFrontCardView {
    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}

////// action for like or dislike
- (void) actionLikeDislike:(NSString*)actionType fbId:(NSString*)otherFBId{
    /*like_superlike_dislike
     
     •	facebook_id_mine
     •	facebook_id_other
     •	like_superlike_dislike ( 1-refresh, 2-dislike, 3-like,4-superlike)*/
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":otherFBId,
                                 @"like_superlike_dislike":actionType};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"like_superlike_dislike"];
    NSLog(@"like_superlike_dislike :%@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"like_superlike_dislike: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            
        }
        else{
            [[[UIAlertView alloc] initWithTitle:[responseObject objectForKey:@"ref_message"]
                                        message:@""
                                       delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
            
        }
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];
    
}

- (void)displayUserDetail{
    
    
    
    [userDetailImgView setImageWithURL:[NSURL URLWithString:self.currentPerson.userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    CGFloat bottomHeight = CGRectGetHeight(userDetailScrollView.bounds) - userDetailImgView.bounds.size.height;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(userDetailScrollView.bounds) - bottomHeight,
                                    CGRectGetWidth(userDetailScrollView.bounds),
                                    bottomHeight+100);
    UIView *informationView = [[UIView alloc] initWithFrame:bottomFrame];
    informationView.backgroundColor = [UIColor whiteColor];
    informationView.clipsToBounds = YES;
    informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [userDetailScrollView addSubview:informationView];
    
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 6.f;
    CGRect nameframe = CGRectMake(leftPadding,
                                  topPadding,
                                  floorf(CGRectGetWidth(informationView.frame)/2),
                                  30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameframe];
    nameLabel.text = [NSString stringWithFormat:@"%@, %@", self.currentPerson.userInfo[@"facebook_name"], self.currentPerson.userInfo[@"age"]];
    nameLabel.font = [UIFont systemFontOfSize:17];
    [informationView addSubview:nameLabel];
    
    CGRect distanceframe = CGRectMake(floorf(CGRectGetWidth(informationView.frame)/2) ,
                                      topPadding,
                                      floorf(CGRectGetWidth(informationView.frame)/2) - leftPadding ,
                                      30);
    UILabel *distanceLbl = [[UILabel alloc] initWithFrame:distanceframe];
    distanceLbl.text = [NSString stringWithFormat:@"%.fKm",[self.currentPerson.userInfo[@"distance_to_user"] floatValue]];
    distanceLbl.textAlignment = NSTextAlignmentRight;
    distanceLbl.textColor = [UIColor lightGrayColor];
    distanceLbl.font = [UIFont systemFontOfSize:13];
    [informationView addSubview:distanceLbl];
    
    topPadding += 26;
    CGRect schoolFrm = CGRectMake(leftPadding,
                                  topPadding,
                                  floorf(CGRectGetWidth(informationView.frame) - leftPadding*2),
                                  30);
    UILabel *schoolLbl = [[UILabel alloc] initWithFrame:schoolFrm];
    schoolLbl.text = self.currentPerson.userInfo[@"studies_in"];
    schoolLbl.textColor = [UIColor lightGrayColor];
    schoolLbl.font = [UIFont systemFontOfSize:13];
    [informationView addSubview:schoolLbl];
    
    topPadding += 26;
    CGRect moodFrm = CGRectMake(leftPadding,
                                topPadding,
                                floorf(CGRectGetWidth(informationView.frame) - leftPadding*2),
                                30);
    UILabel *moodLbl = [[UILabel alloc] initWithFrame:moodFrm];
    NSString *tmpStr = self.currentPerson.userInfo[@"mood_today"];
    moodLbl.text =  [moodArray objectAtIndex:tmpStr.integerValue-1];
    moodLbl.textColor = [UIColor colorWithRed:224.f/255 green:33.f/255 blue:138.f/255 alpha:1.0];
    moodLbl.font = [UIFont systemFontOfSize:17];
    moodLbl.numberOfLines = 0;
    [moodLbl sizeToFit];
    [informationView addSubview:moodLbl];
    
    topPadding = moodLbl.frame.size.height + topPadding;
    CGRect voteFrm = CGRectMake(leftPadding,
                                topPadding,
                                floorf(CGRectGetWidth(informationView.frame) - leftPadding*2),
                                30);
    UILabel *voteLbl = [[UILabel alloc] initWithFrame:voteFrm];
    voteLbl.text = @"Votes of the public";
    [informationView addSubview:voteLbl];
    
    //////
    topPadding += 30;
    UILabel *charmLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 10, topPadding, 80, 30)];
    charmLbl.text = @"Charm";
    charmLbl.textColor = [UIColor lightGrayColor];
    charmLbl.font = [UIFont systemFontOfSize:14];
    [informationView addSubview:charmLbl];
    
    UIImage *dot = [UIImage imageNamed:@"star_empty.png"];
    UIImage *star = [UIImage imageNamed:@"star_gold.png"];
    AMRatingControl *RatingControl1 = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding + 80, topPadding)
                                                                     emptyImage:dot
                                                                     solidImage:star
                                                                   andMaxRating:5];
    [RatingControl1 setEnabled:false];
    NSString *rate = self.currentPerson.userInfo[@"charm"];
    [RatingControl1 setRating:rate.integerValue];
    [informationView addSubview:RatingControl1];
    
    ///////
    topPadding += 30;
    UILabel *humorLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 10, topPadding, 80, 30)];
    humorLbl.text = @"Humor";
    humorLbl.textColor = [UIColor lightGrayColor];
    humorLbl.font = [UIFont systemFontOfSize:14];
    [informationView addSubview:humorLbl];
    
    AMRatingControl *RatingControl2 = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding + 80, topPadding)
                                                                     emptyImage:dot
                                                                     solidImage:star
                                                                   andMaxRating:5];
    [RatingControl2 setEnabled:false];
    rate = self.currentPerson.userInfo[@"humor"];
    [RatingControl2 setRating:rate.integerValue];
    [informationView addSubview:RatingControl2];
    //////
    
    topPadding += 30;
    UILabel *chatLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 10, topPadding, 80, 30)];
    chatLbl.text = @"Chat";
    chatLbl.textColor = [UIColor lightGrayColor];
    chatLbl.font = [UIFont systemFontOfSize:14];
    [informationView addSubview:chatLbl];
    
    AMRatingControl *RatingControl3 = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding + 80, topPadding)
                                                                     emptyImage:dot
                                                                     solidImage:star
                                                                   andMaxRating:5];
    [RatingControl3 setEnabled:false];
    rate = self.currentPerson.userInfo[@"chat"];
    [RatingControl3 setRating:rate.integerValue];
    [informationView addSubview:RatingControl3];
    /////////
    topPadding += 30;
    UILabel *beautyLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 10, topPadding, 80, 30)];
    beautyLbl.text = @"Beauty";
    beautyLbl.textColor = [UIColor lightGrayColor];
    beautyLbl.font = [UIFont systemFontOfSize:14];
    [informationView addSubview:beautyLbl];
    
    AMRatingControl *RatingControl4 = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding + 80, topPadding)
                                                                     emptyImage:dot
                                                                     solidImage:star
                                                                   andMaxRating:5];
    [RatingControl4 setEnabled:false];
    rate = self.currentPerson.userInfo[@"beauty"];
    [RatingControl4 setRating:rate.integerValue];
    [informationView addSubview:RatingControl4];
    ////////
    topPadding += 30;
    UILabel *hornyLbl = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding + 10, topPadding, 80, 30)];
    hornyLbl.text = @"Horny";
    hornyLbl.textColor = [UIColor lightGrayColor];
    hornyLbl.font = [UIFont systemFontOfSize:14];
    [informationView addSubview:hornyLbl];
    
    AMRatingControl *RatingControl5 = [[AMRatingControl alloc] initWithLocation:CGPointMake(leftPadding + 80, topPadding)
                                                                     emptyImage:dot
                                                                     solidImage:star
                                                                   andMaxRating:5];
    [RatingControl5 setEnabled:false];
    rate = self.currentPerson.userInfo[@"horny"];
    [RatingControl5 setRating:rate.integerValue];
    [informationView addSubview:RatingControl5];
    
    [userDetailScrollView setContentSize:CGSizeMake(320, 550)];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [userDetailContentView setHidden:NO];
                        [self.view bringSubviewToFront:userDetailContentView];
                        
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        showUserDetail = YES;
                        fbOtherId = self.currentPerson.userInfo[@"facebook_id"];
                        [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
                    }];
    
}

- (IBAction)click_actionBttn:(UIButton *)sender {
    if(showUserDetail){
        if(sender.tag == 201){//refresh
            [self actionLikeDislike:action_refresh fbId:fbOtherId];
        }
        else if (sender.tag == 202){//dislike
            [self actionLikeDislike:action_dislike fbId:fbOtherId];
        }
        else if (sender.tag == 203){//like
            [self actionLikeDislike:action_like fbId:fbOtherId];
        }
        else{//super like
            [self actionLikeDislike:action_SP fbId:fbOtherId];
        }
        
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            [userDetailContentView setHidden:YES];
                            
                            [UIView setAnimationsEnabled:oldState];
                        } completion:^(BOOL finish){
                            [userDetailScrollView setContentOffset:CGPointMake(0, 0)];
                            showUserDetail = NO;
                        }];
        
    }
    else{
        if(sender.tag == 201){//refresh
            actionStr =action_refresh;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
            
        }
        else if (sender.tag == 202){//dislike
            actionStr =action_dislike;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
        }
        else if (sender.tag == 203){//like
            actionStr =action_like;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
        }
        else{//super like
            actionStr =action_SP;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
            
        }
        [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
    }
}

- (IBAction)click_cancelBttn:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
