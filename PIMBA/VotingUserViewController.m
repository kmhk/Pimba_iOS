//
//  VotingUserViewController.m
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "VotingUserViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
@interface VotingUserViewController ()

@end

@implementation VotingUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViewSetting{
    userProfile_imgView.layer.cornerRadius = userProfile_imgView.frame.size.height/2;
    userProfile_imgView.layer.borderColor = image_borderColor.CGColor;
    userProfile_imgView.layer.borderWidth = 4;
    
    [userProfile_imgView setImageWithURL:[NSURL URLWithString:self.userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
    userName_lbl.text = [NSString stringWithFormat:@"%@, %@", self.userInfo[@"facebook_name"], self.userInfo[@"age"]];
    
    UIImage *dot = [UIImage imageNamed:@"star_empty.png"];
    UIImage *star = [UIImage imageNamed:@"star_gold.png"];

    charm_rateCtrl = [[AMRatingControl alloc] initWithLocation:charm_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    charm_rateCtrl.tag = 101;
    if([self.voteType  isEqual: @"confirm"]){
        charm_rateCtrl.enabled = false;
        charm_rateCtrl.rating = [self.userInfo[@"vote_detail"][@"charm"] integerValue];
    }
    else charm_rateCtrl.rating = 0;
    
    [charm_rateCtrl addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:charm_rateCtrl];
    
    humor_rateCtrl = [[AMRatingControl alloc] initWithLocation:humor_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    humor_rateCtrl.tag = 102;
    if([self.voteType  isEqual: @"confirm"]){
        humor_rateCtrl.enabled = false;
        humor_rateCtrl.rating = [self.userInfo[@"vote_detail"][@"humor"] integerValue];
    }
    else charm_rateCtrl.rating = 0;
    
    [humor_rateCtrl addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:humor_rateCtrl];
    
    chat_rateCtrl = [[AMRatingControl alloc] initWithLocation:chat_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    chat_rateCtrl.tag = 103;
    if([self.voteType  isEqual: @"confirm"]){
        chat_rateCtrl.enabled = false;
        chat_rateCtrl.rating = [self.userInfo[@"vote_detail"][@"chat"] integerValue];
    }
    else charm_rateCtrl.rating = 0;
    
    [chat_rateCtrl addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:chat_rateCtrl];
    
    beauty_rateCtrl = [[AMRatingControl alloc] initWithLocation:beauty_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    beauty_rateCtrl.tag = 104;
    if([self.voteType  isEqual: @"confirm"]){
        beauty_rateCtrl.enabled = false;
        beauty_rateCtrl.rating = [self.userInfo[@"vote_detail"][@"beauty"] integerValue];
    }
    else charm_rateCtrl.rating = 0;
    
    [beauty_rateCtrl addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:beauty_rateCtrl];
    
    horny_rateCtrl = [[AMRatingControl alloc] initWithLocation:horny_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    horny_rateCtrl.tag = 105;
    if([self.voteType  isEqual: @"confirm"]){
        horny_rateCtrl.enabled = false;
        horny_rateCtrl.rating = [self.userInfo[@"vote_detail"][@"horny"] integerValue];
    }
    else charm_rateCtrl.rating = 0;
    
    [horny_rateCtrl addTarget:self action:@selector(changeRate:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:horny_rateCtrl];
}

- (void)changeRate:(UIControl*)ctrl{
    
}


- (IBAction)click_actionBttn:(UIButton *)sender {
    if([self.voteType  isEqual: @"confirm"]){
        if(sender.tag == 201){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"confirmVote" object:nil userInfo:@{@"type":@"2",
                                                                                                        @"userInfo":self.userInfo}];
        }
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"confirmVote" object:nil userInfo:@{@"type":@"1",
                                                                                                            @"userInfo":self.userInfo}];
        }
        
    }
    else{
        if(sender.tag == 201){
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoteOrNot" object:nil userInfo:nil];
        }
        else{
            NSDictionary *tmpDic = @{@"charm":[NSString stringWithFormat:@"%ld", (long)charm_rateCtrl.rating],
                                     @"humor":[NSString stringWithFormat:@"%ld", (long)humor_rateCtrl.rating],
                                     @"chat":[NSString stringWithFormat:@"%ld", (long)chat_rateCtrl.rating],
                                     @"beauty":[NSString stringWithFormat:@"%ld", (long)beauty_rateCtrl.rating],
                                     @"horny":[NSString stringWithFormat:@"%ld", (long)horny_rateCtrl.rating]};
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"VoteOrNot" object:nil userInfo:tmpDic];
        }
    }
    
    
}
@end
