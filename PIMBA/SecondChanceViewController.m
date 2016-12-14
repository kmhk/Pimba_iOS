//
//  SecondChanceViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "SecondChanceViewController.h"
#import "UserCollectionViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
#import "AMRatingControl.h"
@interface SecondChanceViewController ()
{
    NSMutableArray *userArray;
    NSDictionary *selectDic;
}
@end

@implementation SecondChanceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *identifier = @"UserCollectionViewCell";
    UINib *nib = [UINib nibWithNibName:@"UserCollectionViewCell" bundle: nil];
    [CollectionView registerNib:nib forCellWithReuseIdentifier:identifier];

    [self initViewSetting];
    
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
    [self getList];
}

- (void)strechImgView{
    CGRect rc = CGRectMake(0, 0, self.view.frame.size.width, 254);
    if(detail_scrollView.contentOffset.y < 0){
        rc.origin.y = detail_scrollView.contentOffset.y;
        rc.size.height += -detail_scrollView.contentOffset.y;
    }
    detail_userPhotoView.frame = rc;
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self strechImgView];
}
- (void)displayUserDetail:(NSDictionary*)userInfo{
    
    detail_cancelBttn.layer.cornerRadius = detail_cancelBttn.frame.size.height/2;
    
    [detail_userPhotoView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    
    [self strechImgView];
    
    CGFloat bottomHeight = CGRectGetHeight(detail_scrollView.bounds) - detail_userPhotoView.bounds.size.height;
    CGRect bottomFrame = CGRectMake(0,
                                    CGRectGetHeight(detail_scrollView.bounds) - bottomHeight,
                                    CGRectGetWidth(detail_scrollView.bounds),
                                    bottomHeight+100);
    UIView *informationView = [[UIView alloc] initWithFrame:bottomFrame];
    informationView.backgroundColor = [UIColor whiteColor];
    informationView.clipsToBounds = YES;
    informationView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleTopMargin;
    [detail_scrollView addSubview:informationView];
    
    CGFloat leftPadding = 12.f;
    CGFloat topPadding = 6.f;
    CGRect nameframe = CGRectMake(leftPadding,
                                  topPadding,
                                  floorf(CGRectGetWidth(informationView.frame)/2),
                                  30);
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:nameframe];
    nameLabel.text = [NSString stringWithFormat:@"%@, %@", userInfo[@"facebook_name"], userInfo[@"age"]];
    nameLabel.font = [UIFont boldSystemFontOfSize:17];
    [informationView addSubview:nameLabel];
    
    CGRect distanceframe = CGRectMake(floorf(CGRectGetWidth(informationView.frame)/2) ,
                                      topPadding,
                                      floorf(CGRectGetWidth(informationView.frame)/2) - leftPadding ,
                                      30);
    UILabel *distanceLbl = [[UILabel alloc] initWithFrame:distanceframe];
    distanceLbl.text = [NSString stringWithFormat:@"%.fKm", [userInfo[@"distance_to_user"] floatValue]];
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
    schoolLbl.text = userInfo[@"studies_in"];
    schoolLbl.textColor = [UIColor lightGrayColor];
    schoolLbl.font = [UIFont systemFontOfSize:13];
    [informationView addSubview:schoolLbl];
    
    topPadding += 26;
    CGRect moodFrm = CGRectMake(leftPadding,
                                topPadding,
                                floorf(CGRectGetWidth(informationView.frame) - leftPadding*2),
                                30);
    UILabel *moodLbl = [[UILabel alloc] initWithFrame:moodFrm];
    NSString *tmpStr = userInfo[@"mood_today"];
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
    NSString *rate = userInfo[@"charm"];
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
    rate = userInfo[@"humor"];
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
    rate = userInfo[@"chat"];
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
    rate = userInfo[@"beauty"];
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
    rate = userInfo[@"horny"];
    [RatingControl5 setRating:rate.integerValue];
    [informationView addSubview:RatingControl5];
    
    [detail_scrollView setContentSize:CGSizeMake(320, 550)];
    
    
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [detail_contentView setHidden:NO];
                        [self.view bringSubviewToFront:detail_contentView];
                        [detail_cancelBttn setHidden:NO];
                        [self.view bringSubviewToFront:detail_cancelBttn];
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        
                    }];
    
}
- (IBAction)click_detailCancelBttn:(id)sender {
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [detail_contentView setHidden:YES];
                        [detail_cancelBttn setHidden:YES];
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        [detail_scrollView setContentOffset:CGPointMake(0, 0)];
                        
                    }];
    
}

- (IBAction)click_actBttn:(UIButton*)sender {
    [UIView transitionWithView:self.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        BOOL oldState = [UIView areAnimationsEnabled];
                        [UIView setAnimationsEnabled:NO];
                        
                        [detail_contentView setHidden:YES];
                        [detail_cancelBttn setHidden:YES];
                        [UIView setAnimationsEnabled:oldState];
                    } completion:^(BOOL finish){
                        [detail_scrollView setContentOffset:CGPointMake(0, 0)];
                        
                        if(sender.tag == 202){
                            [self actionLikeDislike:@"2" fbId:selectDic[@"facebook_id"]];
                        }
                        if(sender.tag == 203){
                            [self actionLikeDislike:@"3" fbId:selectDic[@"facebook_id"]];
                        }
                        if(sender.tag == 204){
                            [self actionLikeDislike:@"4" fbId:selectDic[@"facebook_id"]];
                        }
                        [userArray removeObject:selectDic];
                        [CollectionView reloadData];
                    }];
    
}

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
    cell.userImgView.layer.borderWidth = 2;
    
    [cell.userImgView setImageWithURL:[NSURL URLWithString:userArray[indexPath.row][@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    cell.userNameLbl.text = [NSString stringWithFormat:@"%@, %@",userArray[indexPath.row][@"facebook_name"], userArray[indexPath.row][@"age"]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake([UIScreen mainScreen].bounds.size.width/2-2, [UIScreen mainScreen].bounds.size.width/2-2);
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    selectDic = userArray[indexPath.row];
    [self displayUserDetail:selectDic];
}

- (void) getList{
    /*second_chance
     
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
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"second_chance"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"second_chance: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            userArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"result"]];
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
