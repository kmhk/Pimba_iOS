//
//  FindPeopleViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "FindPeopleViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioServices.h>
#import "Person.h"
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

#import "Constant.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>

#import "AMRatingControl.h"
#import "UserMatchViewController.h"
#import "ChatViewController.h"
@interface FindPeopleViewController ()
{
    
    BOOL inAnimation;
    BOOL showUserDetail;
    NSMutableArray *people;
    
    BOOL lastCardFlg;
    NSString *actionStr;
    NSString *fbOtherId;
    NSTimer *getUser_timer;
    UserMatchViewController *matchViewController;
}
@end

@implementation FindPeopleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    people = [[NSMutableArray alloc] init];
    [self initViewSetting];
    
    [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(startAnimation) userInfo:nil repeats:YES];
    
   
    actionStr = @"";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayUserDetail) name:@"clickUserDetail" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"MatchNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actPIMBADA:) name:@"PIMBADANotification" object:nil];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated{
    NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
    [imgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
}
- (void) viewDidAppear:(BOOL)animated{
    
    [self findAroundUsers];
    
    [userdefault setObject:Yes forKey:kFindPeopleWindow];
    
    
    if([[userdefault objectForKey:@"on_fire"] integerValue] == 1){
        
        fire_imgView.image = [UIImage imageNamed:@"fire-home"];
    }
    else{
        
        fire_imgView.image = [UIImage imageNamed:@"top-message"];
    }
    
    if(self.frontCardView == nil) inAnimation = NO;
    
    if(self.pushInfo) [self displayPushForChat];
    
    [self becomeFirstResponder];
}
- (void) viewDidDisappear:(BOOL)animated{
    inAnimation = YES;
    people = [[NSMutableArray alloc] init];
    [self.frontCardView removeFromSuperview];
    [self.backCardView removeFromSuperview];
    self.frontCardView = nil;
    self.backCardView = nil;
    
    [actionContentView setHidden:YES];
    [userDetailContentView setHidden:YES];
    [userDetailCancel_bttn setHidden:YES];
    
    [userDetailScrollView setContentOffset:CGPointMake(0, 0)];
    showUserDetail = NO;
    [userdefault setObject:No forKey:kFindPeopleWindow];
    
    [self stopFindPeople];
}

-(void) displayPushForChat{
    
    ChatViewController *sub = [[ChatViewController alloc] init];
    sub.userInfo = self.pushInfo[@"profile_info"];
   // sub.userName = @"sender_facebook_name";//userInfo[@"aps"][@"facebook_name"];
    
    sub.senderId = [userdefault objectForKey:@"pimba_fbId"];
    sub.senderDisplayName = @" ";
    
    self.pushInfo = nil;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
    
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)pushNotificationReceived:(NSNotification*)noti{
    
    
    NSDictionary *dic = noti.userInfo;
    
    
    
    matchViewController = [[UserMatchViewController alloc] init];
    matchViewController.userInfo = dic;
    
    [self addChildViewController:matchViewController];
    matchViewController.view.frame = self.view.bounds;
    [self.view addSubview:matchViewController.view];
    [matchViewController didMoveToParentViewController:self];
    if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
        SystemSoundID completeSound;
        NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"PIMBADA" withExtension:@"wav"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
        AudioServicesPlaySystemSound (completeSound);
    }
    
}
- (void)actPIMBADA:(NSNotification*)noti{
    
    [matchViewController willMoveToParentViewController:nil];  // 1
    [matchViewController.view removeFromSuperview];            // 2
    [matchViewController removeFromParentViewController];
    
    NSDictionary *dic = noti.userInfo;
    if([dic[@"type"] integerValue] == 1){
        ChatViewController *sub = [[ChatViewController alloc] init];
        
        sub.userInfo = dic[@"userInfo"];
            
        sub.senderId = [userdefault objectForKey:@"pimba_fbId"];
        sub.senderDisplayName = @" ";
        
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
        [self presentViewController:nav
                           animated:YES
                         completion:nil];
    }
}
- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navBarView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navBarView addSubview:lineV];
    
    imgView.layer.cornerRadius = imgView.frame.size.height/2;
    imgView.layer.borderWidth = 4;
    imgView.layer.borderColor = [UIColor whiteColor].CGColor;
    NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
    [imgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
    inAnimation = NO;
    
    [self.view bringSubviewToFront:imgContentView];
    [self.view bringSubviewToFront:navBarView];
    
}

- (void)displayAroundUsers{
    
    
    
    [self.frontCardView removeFromSuperview];
    [self.backCardView removeFromSuperview];
    self.frontCardView = [self popPersonViewWithFrame:[self frontCardViewFrame]];
    
    self.backCardView = [self popPersonViewWithFrame:[self backCardViewFrame]];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(displayUserDetail)];
    tap.numberOfTapsRequired = 1;
    [self.frontCardView addGestureRecognizer:tap];
    
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
                             
                             if(self.frontCardView == nil)
                             {
                                 actionContentView.hidden = YES;
                                 inAnimation = NO;
                             }
                             else{
                                 actionContentView.hidden = false;
                                 inAnimation = YES;
                             }
                         }];
    
}

- (void) getMatchedUsers{
    /*find_people
     
     facebook_id
     localization_latitude
     localization_longitude*/
    
    if(inAnimation) return;
    
    NSString *latitudeStr, *longitudeStr;
    if([userdefault objectForKey:@"pimba_currentlocation"] == nil){
        latitudeStr = @"0.0";
        longitudeStr = @"0.0";
    }
    else{
        latitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lat"];
        longitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lnt"];
    }
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"localization_latitude":latitudeStr,
                                 @"localization_longitude":longitudeStr};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"find_people"];
    NSLog(@"find_people params: %@", parameters);
    
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"find_people: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            NSArray *tmpAry = [responseObject objectForKey:@"result"];
            
            for (int i = 0; i<tmpAry.count; i++) {
                [people addObject:[[Person alloc] initWithUserInfo:tmpAry[i]]];
            }
            if(tmpAry.count>0) {
                [self displayAroundUsers];
                [self stopFindPeople];
            }
            if(tmpAry.count == 1) lastCardFlg = true;
            
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
        [SVProgressHUD dismiss];
    }];

}
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if(event.type == UIEventSubtypeMotionShake)
    {
        NSLog(@"shake....");
         NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[userdefault objectForKey:@"pimba_profile" ]];
        if([userInfo[@"sex"] integerValue] != 2 || [[userdefault objectForKey:@"on_fire"] integerValue] == 1) return;
        
        if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
            SystemSoundID completeSound;
            NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"onFire" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
            AudioServicesPlaySystemSound (completeSound);
        }
        
        [self setFireOnOff:@"1"];
        fire_bttn.enabled = YES;
        fire_imgView.hidden = NO;
        
        
        [userdefault setObject:@"1" forKey:@"on_fire"];
        
    }
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}
- (void) setFireOnOff:(NSString*)OnOffStr{
    /*set_fire	
     
     	facebook_id
     	fire_or_not     1- on, 2- off
     localization_latitude
     localization_longitude
     */
    NSString *latitudeStr, *longitudeStr;
    if([userdefault objectForKey:@"pimba_currentlocation"] == nil){
        latitudeStr = @"0.0";
        longitudeStr = @"0.0";
    }
    else{
        latitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lat"];
        longitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lnt"];
    }

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"fire_or_not":OnOffStr,
                                 @"localization_latitude":latitudeStr,
                                 @"localization_longitude":longitudeStr};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"set_fire"];
    NSLog(@"set_fire params: %@", parameters);
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"set_fire: %@", responseObject);
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
        [SVProgressHUD dismiss];
    }];
}

- (void)findAroundUsers{
    getUser_timer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(sendtimerMatchUser:) userInfo:nil repeats:YES];
}
- (void) stopFindPeople{
    [getUser_timer invalidate];
    getUser_timer = nil;
}
- (void)sendtimerMatchUser:(NSTimer*)tmr{
    [self getMatchedUsers];
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
    if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
        SystemSoundID completeSound;
        if([actionStr  isEqual: action_SP])
        {
            NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"superPimba" withExtension:@"wav"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
            AudioServicesPlaySystemSound (completeSound);
        }
        else
        {
            NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"swap" withExtension:@"mp3"];
            AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
            AudioServicesPlaySystemSound (completeSound);
        }
        
    }
    

    actionStr = @"";
    
    if(lastCardFlg){
        
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            actionContentView.hidden = YES;
                            inAnimation = NO;
                            
                            [UIView setAnimationsEnabled:oldState];
                        } completion:^(BOOL finish){
                            lastCardFlg = NO;
                            
                            
                        }];
        
    }
    
    self.frontCardView = self.backCardView;
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
    if ([people count] == 0) {
        
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
                                                                    person:people[0]
                                                                   options:options];
    [people removeObjectAtIndex:0];
    return personView;
}

#pragma mark View Contruction

- (CGRect)frontCardViewFrame {
    CGFloat horizontalPadding = 16.f;
    CGFloat topPadding = 70.f;
    CGFloat bottomPadding = 100.f;
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
            if(lastCardFlg){
                [self findAroundUsers];
                lastCardFlg = false;
            }
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
- (void)strechImgView{
    CGRect rc = CGRectMake(0, 0, self.view.frame.size.width, 254);
    if(userDetailScrollView.contentOffset.y < 0){
        rc.origin.y = userDetailScrollView.contentOffset.y;
        rc.size.height += -userDetailScrollView.contentOffset.y;
    }
    userDetailImgView.frame = rc;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self strechImgView];
}
- (void)displayUserDetail{
    
    userDetailCancel_bttn.layer.cornerRadius = userDetailCancel_bttn.frame.size.height/2;
    
    [userDetailImgView setImageWithURL:[NSURL URLWithString:self.currentPerson.userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
    [self strechImgView];
    
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
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    [informationView addSubview:nameLabel];
    
    CGRect distanceframe = CGRectMake(floorf(CGRectGetWidth(informationView.frame)/2) ,
                                      topPadding,
                                      floorf(CGRectGetWidth(informationView.frame)/2) - leftPadding ,
                                      30);
    UILabel *distanceLbl = [[UILabel alloc] initWithFrame:distanceframe];
    distanceLbl.text = [NSString stringWithFormat:@"%.fKm", [self.currentPerson.userInfo[@"distance_to_user"] floatValue]];
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
    showUserDetail = YES;
    fbOtherId = self.currentPerson.userInfo[@"facebook_id"];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [userDetailContentView setHidden:NO];
                        [self.view bringSubviewToFront:userDetailContentView];
                        [userDetailCancel_bttn setHidden:NO];
                        [self.view bringSubviewToFront:userDetailCancel_bttn];
                        
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        showUserDetail = YES;
                        fbOtherId = self.currentPerson.userInfo[@"facebook_id"];
                        [self getProfileDetail:fbOtherId];
                    }];

}

- (void)getProfileDetail:(NSString*)userId{
    /*get_profile_detail	
     	facebook_id*/
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":userId};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_profile_detail"];
    NSLog(@"get_profile_detail :%@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"get_profile_detail: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];

}

////////////////
/*
- (void)animationDidStart:(CAAnimation *)anim
{
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    inAnimation = NO;
    [self performSelectorInBackground:@selector(startAnimation) withObject:nil];
}*/
- (void)startAnimation{
    if(inAnimation == YES) return;
    
    CALayer *Layer=[CALayer layer];
    Layer.frame = CGRectMake(imgContentView.frame.origin.x+imgContentView.frame.size.width/2-30, imgContentView.frame.origin.y+imgContentView.frame.size.height/2-30, 60,60);
    Layer.borderWidth = 0.6;
    Layer.borderColor = [UIColor clearColor].CGColor;
    Layer.cornerRadius = 30.f;
    [self.view.layer insertSublayer:Layer below:self.backCardView.layer];
 //   [self.view bringSubviewToFront:imgContentView];
    [self waveAnimation:Layer];
    if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
        SystemSoundID completeSound;
        NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"findPeople" withExtension:@"mp3"];
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
        AudioServicesPlaySystemSound (completeSound);
    }
    
}
-(void)waveAnimation:(CALayer*)aLayer
{
    ////NSLog(@"layer : %@", aLayer);
    CABasicAnimation *transformAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    transformAnimation.duration = 3;
    transformAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transformAnimation.removedOnCompletion = YES;
    transformAnimation.fillMode = kCAFillModeBackwards;
    [aLayer setTransform:CATransform3DMakeScale( 1.2, 1.2, 1.0)];
    [transformAnimation setDelegate:self];
    
    CATransform3D xform = CATransform3DIdentity;
    xform = CATransform3DScale(xform, 6.2, 6.2, 1.0);
    //xform = CATransform3DTranslate(xform, 60, -60, 0);
    transformAnimation.toValue = [NSValue valueWithCATransform3D:xform];
    [aLayer addAnimation:transformAnimation forKey:@"transformAnimation"];
    
    
    UIColor *fromColor = [UIColor colorWithRed:20 green:0 blue:0 alpha:0.1];
    UIColor *toColor = [UIColor colorWithRed:10 green:0 blue:0 alpha:0.0005];
    CABasicAnimation *colorAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    colorAnimation.duration = 3;
    colorAnimation.fromValue = (id)fromColor.CGColor;
    colorAnimation.toValue = (id)toColor.CGColor;
    [aLayer addAnimation:colorAnimation forKey:@"colorAnimationBG"];
    
    
    UIColor *fromColor1 = [UIColor colorWithRed:20 green:0 blue:0 alpha:0.2];
    UIColor *toColor1 = [UIColor colorWithRed:10 green:0 blue:0 alpha:0.001];
    CABasicAnimation *colorAnimation1 = [CABasicAnimation animationWithKeyPath:@"borderColor"];
    colorAnimation1.duration = 3;
    colorAnimation1.fromValue = (id)fromColor1.CGColor;
    colorAnimation1.toValue = (id)toColor1.CGColor;
    [aLayer addAnimation:colorAnimation1 forKey:@"colorAnimation"];
    
    
}


#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
    
    inAnimation = true;
    NSLog(@"open ....");
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
    if(self.frontCardView == nil)inAnimation = false;
    NSLog(@"close ....");
}

- (IBAction)img_bttnDown:(id)sender {
    
    
    NSLog(@"1");
    inAnimation = YES;
    
    CGRect frm = imgView.frame;
    frm.size.height = 76;
    frm.size.width = 76;
    frm.origin.x = (imgContentView.frame.size.width - frm.size.width)/2;
    frm.origin.y = (imgContentView.frame.size.height - frm.size.height)/2;
    [UIView animateWithDuration:.05f animations:^{
        
        imgView.frame = frm;
        imgView.layer.cornerRadius = imgView.frame.size.height/2;
    }completion:^(BOOL finish){
        
    }];
  
    
}

- (IBAction)img_bttnUpInside:(id)sender {
    NSLog(@"2");
    
    inAnimation = NO;
    [self startAnimation];
    
    CGRect frm = imgView.frame;
    frm.size.height = 96;
    frm.size.width = 96;
    frm.origin.x = (imgContentView.frame.size.width - frm.size.width)/2;
    frm.origin.y = (imgContentView.frame.size.height - frm.size.height)/2;
    
    [UIView animateWithDuration:.07f animations:^{
        
        imgView.frame = frm;
        imgView.layer.cornerRadius = imgView.frame.size.height/2;
    }completion:^(BOOL finish){
        
        [self resizeImgView];
    }];
    
}

- (IBAction)img_bttnUpOutside:(id)sender {
    NSLog(@"3");
    inAnimation = NO;
    [self startAnimation];
    
    CGRect frm = imgView.frame;
    frm.size.height = 96;
    frm.size.width = 96;
    frm.origin.x = (imgContentView.frame.size.width - frm.size.width)/2;
    frm.origin.y = (imgContentView.frame.size.height - frm.size.height)/2;

    [UIView animateWithDuration:.07f animations:^{
        imgView.frame = frm;
        imgView.layer.cornerRadius = imgView.frame.size.height/2;
    }completion:^(BOOL finish){
        
        [self resizeImgView];
    }];
    

}
- (void) resizeImgView{
    CGRect frm = imgView.frame;
    frm.size.height = 86;
    frm.size.width = 86;
    frm.origin.x = (imgContentView.frame.size.width - frm.size.width)/2;
    frm.origin.y = (imgContentView.frame.size.height - frm.size.height)/2;
    [UIView animateWithDuration:.1f animations:^{
        
        imgView.frame = frm;
        imgView.layer.cornerRadius = imgView.frame.size.height/2;
    }completion:^(BOOL finish){
        
    }];
}

- (IBAction)click_actionBttn:(UIButton *)sender {
    if(showUserDetail){
        
        
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            [userDetailContentView setHidden:YES];
                            [userDetailCancel_bttn setHidden:YES];
                            [UIView setAnimationsEnabled:oldState];
                        } completion:^(BOOL finish){
                            [userDetailScrollView setContentOffset:CGPointMake(0, 0)];
                            showUserDetail = NO;
                            
                            if(sender.tag == 201){//refresh
                                actionStr =action_refresh;
                                [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
                                [self displayAroundUsers];
                                
                            }
                            else if (sender.tag == 202){//dislike
                                actionStr =action_dislike;
                                [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
                                [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
                            }
                            else if (sender.tag == 203){//like
                                actionStr =action_like;
                                [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
                                [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
                            }
                            else{//super like
                                actionStr =action_SP;
                                [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
                                [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
                            }
                            
                        }];

    }
    else{
        if(sender.tag == 201){//refresh
            actionStr =action_refresh;
            [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
            [self displayAroundUsers];
            
        }
        else if (sender.tag == 202){//dislike
            actionStr =action_dislike;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionLeft];
            [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
        }
        else if (sender.tag == 203){//like
            actionStr =action_like;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
            [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
        }
        else{//super like
            actionStr =action_SP;
            [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
            [self actionLikeDislike:actionStr fbId:self.currentPerson.userInfo[@"facebook_id"]];
        }
        
    }
}

- (IBAction)click_fireBttn:(id)sender {
    /*You will disable the She’s on fire! are you sure?”, */
    if([[userdefault objectForKey:@"on_fire"] integerValue] == 1){
        [[[UIAlertView alloc] initWithTitle:@"You will disable the She’s on fire! Are you sure?"
                                    message:@""
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK",nil] show];
    }
    else{
        
    }
    
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0){
        [self setFireOnOff:@"2"];
        fire_bttn.enabled = NO;
        fire_imgView.hidden = YES;
        
        [userdefault setObject:@"2" forKey:@"on_fire"];
    }
}

- (IBAction)click_detailCancelBttn:(id)sender {
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [userDetailContentView setHidden:YES];
                        [userDetailCancel_bttn setHidden:YES];
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        [userDetailScrollView setContentOffset:CGPointMake(0, 0)];
                        showUserDetail = NO;
                    }];

}

- (IBAction)click_menuBttn:(id)sender {
    [self.drawer open];
}
@end
