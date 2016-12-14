//
//  VoteViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "VoteViewController.h"
#import "UserCollectionViewCell.h"

#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
#import "VotingUserViewController.h"
#import "PendingUserTableviewCell.h"
@interface VoteViewController ()
{
    NSMutableArray *userArray;
    NSMutableArray *pendingUserArray;
    NSDictionary *selectUserInfo;
    
    VotingUserViewController *voteUserViewController;
}
@end

@implementation VoteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *identifier = @"UserCollectionViewCell";
    UINib *nib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle: nil];
    [CollectionView registerNib:nib forCellWithReuseIdentifier:identifier];
    
    [self initViewSetting];
    
    voteUserViewController = [[VotingUserViewController alloc] init];
 
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(click_voteBttn:) name:@"VoteOrNot" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(click_confirmVoteBttn:) name:@"confirmVote" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navBarView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navBarView addSubview:lineV];
}

- (void) viewDidAppear:(BOOL)animated{
    [self getlist];
}
#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

- (IBAction)click_menuBttn:(id)sender {
    [self.drawer open];
}
- (void) click_voteBttn:(NSNotification*)noti{
    NSDictionary *userInfoDic = noti.userInfo;
    
    [UIView transitionWithView:self.view
                          duration:0.3
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            [voteUserViewController.view removeFromSuperview];
                            [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        if(userInfoDic != nil){
                            [self voteToUser:userInfoDic];
                            [userArray removeObject:selectUserInfo];
                            [CollectionView reloadData];
                        }
                    }];
    
}

- (void) voteToUser:(NSDictionary*)voteInfo{
    /*do_vote	
     •	facebook_id_mine
     •	facebook_id_other
     •	charm
     •	humor
     •	chat
     •	beauty
     •	horny
     */
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":selectUserInfo[@"facebook_id"],
                                 @"charm":voteInfo[@"charm"],
                                 @"humor":voteInfo[@"humor"],
                                 @"chat":voteInfo[@"chat"],
                                 @"beauty":voteInfo[@"beauty"],
                                 @"horny":voteInfo[@"horny"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"do_vote"];
    NSLog(@"do_vote param : %@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"do_vote: %@", responseObject);
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
- (void)click_confirmVoteBttn:(NSNotification*)noti{
    NSDictionary *userInfoDic = noti.userInfo;
    
    [UIView transitionWithView:self.view
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [voteUserViewController.view removeFromSuperview];
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        if(userInfoDic != nil){
                            [self confirmVote:userInfoDic[@"userInfo"] typeStr:userInfoDic[@"type"]];
                            
                            [pendingUserArray removeObject:userInfoDic[@"userInfo"]];
                            [self displayPendingUsers];
                        }
                    }];

}
- (void) confirmVote:(NSDictionary*)voteInfo typeStr:(NSString*)actStr{
    /*confirm_vote	
     
     •	facebook_id_mine
     •	facebook_id_other
     •	confirm_or_not ( 1 confirm, 2 reject)
     •	charm
     •	humor
     •	chat
     •	beauty
     •	horny*/
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id_mine":[userdefault objectForKey:@"pimba_fbId"],
                                 @"facebook_id_other":voteInfo[@"facebook_id"],
                                 @"confirm_or_not":actStr,
                                 @"charm":voteInfo[@"vote_detail"][@"charm"],
                                 @"humor":voteInfo[@"vote_detail"][@"humor"],
                                 @"chat":voteInfo[@"vote_detail"][@"chat"],
                                 @"beauty":voteInfo[@"vote_detail"][@"beauty"],
                                 @"horny":voteInfo[@"vote_detail"][@"horny"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"confirm_vote"];
    NSLog(@"confirm_vote param : %@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"confirm_vote: %@", responseObject);
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

- (IBAction)click_actionBttn:(UIButton *)sender {
    if(sender.tag == 201){
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            confirmContentView.hidden = YES;
                            
                            [UIView setAnimationsEnabled:oldState];
                        } completion:^(BOOL finish){
                            
                        }];
    }
    else if (sender.tag == 202){
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            BOOL oldState = [UIView areAnimationsEnabled];
                            [UIView setAnimationsEnabled:NO];
                            
                            confirmContentView.hidden = YES;
                            
                            [UIView setAnimationsEnabled:oldState];
                        } completion:^(BOOL finish){
                            
                            voteUserViewController.userInfo = [[NSDictionary alloc] initWithDictionary:selectUserInfo];
                            voteUserViewController.view.frame = CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 65);
                            [self addChildViewController:voteUserViewController];
                            [self.view addSubview:voteUserViewController.view];
                        }];
        
        
        
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return userArray.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    UserCollectionViewCell *cell = (UserCollectionViewCell *)[collectionView                                                dequeueReusableCellWithReuseIdentifier:@"UserCollectionViewCell" forIndexPath:indexPath];
    
    cell.userImgView.layer.cornerRadius = cell.userImgView.frame.size.width/2;
    cell.userImgView.layer.borderColor = image_borderColor.CGColor;
    cell.userImgView.layer.borderWidth = 4;
    
    [cell.userImgView setImageWithURL:[NSURL URLWithString:userArray[indexPath.row][@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    cell.userNameLbl.text = [NSString stringWithFormat:@"%@, %@",userArray[indexPath.row][@"facebook_name"], userArray[indexPath.row][@"age"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width/2-2, [UIScreen mainScreen].bounds.size.width/2-2);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectUserInfo = userArray[indexPath.row];
    [self showConfirmView:selectUserInfo];
}

- (void) displayPendingUsers{
    
    NSArray *viewsToRemove = [pendingUser_scrollview subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    for (int i = 0 ; i < pendingUserArray.count; i++)
    {
        PendingUserTableviewCell *viewFromNib = [[PendingUserTableviewCell alloc] initWithFrame:CGRectMake(122 * i, 0, 122, 122)];
        
        viewFromNib.tag = 200+i;
        
        viewFromNib.userProfile_ImgView.layer.cornerRadius = viewFromNib.userProfile_ImgView.frame.size.height/2;
        viewFromNib.userProfile_ImgView.layer.borderColor = image_borderColor.CGColor;
        viewFromNib.userProfile_ImgView.layer.borderWidth = 2.f;
        
        [viewFromNib.userProfile_ImgView setImageWithURL:[NSURL URLWithString:pendingUserArray[i][@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
        viewFromNib.userName_lbl.text = pendingUserArray[i][@"facebook_name"];
        
        [pendingUser_scrollview addSubview:viewFromNib];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPendingUser:)];
        tap.numberOfTapsRequired = 1;
        [viewFromNib addGestureRecognizer:tap];
    }
    
    
}

- (void) tapPendingUser:(UITapGestureRecognizer*)tap{
    UIView *vw = tap.view;
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        voteUserViewController.userInfo = [[NSDictionary alloc] initWithDictionary:pendingUserArray[vw.tag - 200]];
                        voteUserViewController.voteType = @"confirm";
                        voteUserViewController.view.frame = CGRectMake(0, 65, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 65);
                        [self addChildViewController:voteUserViewController];
                        [self.view addSubview:voteUserViewController.view];
                        
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        
                        
                    }];
    

}

-(void)showConfirmView:(NSDictionary*)userInfo{
    
    confirm_userImgView.layer.cornerRadius = confirm_userImgView.frame.size.height/2;
    confirm_userImgView.layer.borderColor = image_borderColor.CGColor;
    confirm_userImgView.layer.borderWidth = 4;
    
    [confirm_userImgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
    confirm_noteLbl.text = [NSString stringWithFormat:@"To vote in %@ the PIMBA,\njust will confim your vote,\nafter\n%@\naprove the vote.", userInfo[@"facebook_name"], userInfo[@"facebook_name"]];
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        confirmContentView.hidden = NO;
                        
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        
                    }];
}

- (void)getlist{
    /*get_matchedFriend_list
     
     facebook_id
     localization_longitude
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
                                 @"localization_latitude":latitudeStr,
                                 @"localization_longitude":longitudeStr};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_matchedFriend_list_vote"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_matchedFriend_list_vote: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            userArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"Friends_for_vote"]];
            pendingUserArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"pending_friends_for_confirm"]];
            [self displayPendingUsers];
            [CollectionView  reloadData];
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
