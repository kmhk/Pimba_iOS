//
//  ProfileViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "ProfileViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
#import "EditProfileViewController.h"
@interface ProfileViewController ()

@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getProfile];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) viewWillAppear:(BOOL)animated{
     [self initViewSetting];
}
- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navView addSubview:lineV];
    
    NSString *myId = [userdefault objectForKey:@"pimba_fbId"];
    if(![myId isEqual:self.profileInfo[@"facebook_id"]]){
        edit_lbl.hidden = YES;
        editBttn.enabled = false;
        distance_lbl.hidden = false;
    }
    else{
        self.profileInfo = [[NSMutableDictionary alloc] initWithDictionary:[userdefault objectForKey:@"pimba_profile"]];
        distance_lbl.hidden = true;
    }
    
    
    NSArray *viewsToRemove = [profileImg_scrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    NSArray *imgArry = self.profileInfo[@"profile_image"];
    [profileImg_scrollView  setContentSize:CGSizeMake([UIScreen mainScreen].bounds.size.width * imgArry.count, profileImg_scrollView.frame.size.height)];
    [profileImg_scrollView setContentOffset:CGPointMake(0, 0)];
    for (int i = 0 ; i < imgArry.count ; i++)
    {
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width * i, 0, [UIScreen mainScreen].bounds.size.width, profileImg_scrollView.frame.size.height)];
        [imgView setImageWithURL:[NSURL URLWithString:imgArry[i][@"profile_image"]] placeholderImage:nil];
        imgView.clipsToBounds = YES;
        imgView.contentMode = UIViewContentModeScaleAspectFill;
        imgView.tag = 100 + i ;

        [profileImg_scrollView addSubview:imgView];
    }
    
    pageCtrl.numberOfPages = imgArry.count;
    pageCtrl.currentPage = 0;
    
    profileName_lbl.text = [NSString stringWithFormat:@"%@, %@", self.profileInfo[@"facebook_name"], self.profileInfo[@"age"]];
    school_lbl.text = self.profileInfo[@"studies_in"];
    distance_lbl.text = [NSString stringWithFormat:@"%.fKm", [self.profileInfo[@"distance_to_user"] floatValue]];
    
    mood_lbl.text = moodArray[[self.profileInfo[@"mood_today"] integerValue]-1];
    mood_lbl.numberOfLines = 0;
    [mood_lbl sizeToFit];

    CGRect frm = description_contentView.frame;
    frm.origin.y = mood_lbl.frame.origin.y + mood_lbl.frame.size.height + 15;
    description_contentView.frame = frm;
    
    description_lbl.text = self.profileInfo[@"description"];
    description_lbl.numberOfLines = 0;
    [description_lbl sizeToFit];
    
    frm = rate_contentView.frame;
    frm.origin.y = description_lbl.frame.origin.y + description_lbl.frame.size.height + 15;
    rate_contentView.frame = frm;
    
    UIImage *dot = [UIImage imageNamed:@"star_empty.png"];
    UIImage *star = [UIImage imageNamed:@"star_gold.png"];
    
    charm_rateView = [[AMRatingControl alloc] initWithLocation:charm_rateView.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    charm_rateView.tag = 101;
    charm_rateView.enabled = false;
    charm_rateView.rating = [self.profileInfo[@"charm"] integerValue];
    [rate_contentView addSubview:charm_rateView];
    
    humor_rateView = [[AMRatingControl alloc] initWithLocation:humor_rateView.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    humor_rateView.tag = 102;
    humor_rateView.enabled = false;
    humor_rateView.rating = [self.profileInfo[@"humor"] integerValue];
    [rate_contentView addSubview:humor_rateView];
    
    chat_rateView = [[AMRatingControl alloc] initWithLocation:chat_rateView.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    chat_rateView.tag = 103;
    chat_rateView.enabled = false;
    chat_rateView.rating = [self.profileInfo[@"chat"] integerValue];
    [rate_contentView addSubview:chat_rateView];
    
    beauty_rateView = [[AMRatingControl alloc] initWithLocation:beauty_rateView.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    beauty_rateView.tag = 104;
    beauty_rateView.enabled = false;
    beauty_rateView.rating = [self.profileInfo[@"beauty"] integerValue];
    [rate_contentView addSubview:beauty_rateView];
    
    horny_rateView = [[AMRatingControl alloc] initWithLocation:horny_rateView.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
    horny_rateView.tag = 105;
    horny_rateView.enabled = false;
    horny_rateView.rating = [self.profileInfo[@"horny"] integerValue];
    [rate_contentView addSubview:horny_rateView];
    
    [ScrollView setContentSize:CGSizeMake(320, 1000)];
}
- (void)strechImgView{
    CGRect rc = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    if(ScrollView.contentOffset.y < 0){
        rc.origin.y = ScrollView.contentOffset.y;
        rc.size.height += -ScrollView.contentOffset.y;
    }
    profileImg_scrollView.frame = rc;
    
    UIImageView *imgView = (UIImageView*)[profileImg_scrollView viewWithTag:pageCtrl.currentPage+100];
    rc = imgView.frame;
    rc.size = profileImg_scrollView.frame.size;
    imgView.frame = rc;
    
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if(ScrollView == scrollView) [self strechImgView];
    else if (scrollView == profileImg_scrollView){
        NSInteger no = round(scrollView.contentOffset.x/[UIScreen mainScreen].bounds.size.width);
        pageCtrl.currentPage = no;
    }
}

- (IBAction)click_menuBttn:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)click_editBttn:(id)sender {
    EditProfileViewController *sub = [[EditProfileViewController alloc] init];
    sub.profileInfo = [[NSMutableDictionary alloc] initWithDictionary:self.profileInfo];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
    [self presentViewController:nav animated:YES completion:nil];
}
- (void)getProfile{
    /*get_profile
     	facebook_id_mine
     	facebook_id_other
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":self.profileInfo[@"facebook_id"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_profile"];
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_profile: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            self.profileInfo = [[NSMutableDictionary alloc] initWithDictionary:[responseObject objectForKey:@"result"]];
            [self initViewSetting];
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
        
    }];

    
}
@end
