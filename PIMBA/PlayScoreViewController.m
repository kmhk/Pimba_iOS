//
//  PlayScoreViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "PlayScoreViewController.h"
#import "PieChartView.h"
#import "AMRatingControl.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"

#import "PlayScore_FirstSightTableViewCell.h"
#import "PlayScore_ProfilePhotoTableViewCell.h"
#import "PlayScore_DetailProfileTableViewCell.h"
#import "PlayScore_ViewNumberTableViewCell.h"
#import "PlayScore_VotingTableViewCell.h"
@interface PlayScoreViewController ()
{
    NSDictionary *playScoreDic;
    NSString *tipStr;
}
@end

@implementation PlayScoreViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initViewSetting];
    
    [userDetailTableView setHidden:YES];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navBarView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navBarView addSubview:lineV];
    
    profileImgView.layer.cornerRadius = profileImgView.frame.size.width/2;
    profileImgView.layer.borderColor = image_borderColor.CGColor;
    profileImgView.layer.borderWidth = 4;
    
    NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
    [profileImgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    userNameAgeLbl.text = [NSString stringWithFormat:@"%@, %@", userInfo[@"facebook_name"], userInfo[@"age"]];
}
- (void)viewWillAppear:(BOOL)animated{
    [self getPlayScore];
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

- (void) displayUserDetail{
    
   
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 6;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if(section == 0) return 50;
    else return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 50;
    }
    else if(indexPath.section == 1){
        return 95;
    }
    else if (indexPath.section == 2){
        return 95;
    }
    else if (indexPath.section == 3){
        return 95;
    }
    else if (indexPath.section == 4) return 226;
    else {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width - 30, 40)];
        lbl.textColor = [UIColor grayColor];
        lbl.text = tipStr;
        lbl.numberOfLines = 0;
        [lbl sizeToFit];
        
        return lbl.frame.size.height+20;
    };
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(playScoreDic == nil) return 0;
    
    if(section == 3){
        NSArray *tmpAry = playScoreDic[@"score_under_pictures"];
        return tmpAry.count;
    }
    else  return 1;
    
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return @"Number of people who have seen your profile:";
    }
    else if (section == 1){
        return @"PIMBA! at first sight:";
    }
    else if (section == 2){
        return @"People detailing their profile";
    }
    else if (section == 3) return @"PIMBA under the profile photo:";
    else if (section == 4) return @"Voting";
    else return @"Tips of Pimba Coach!";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"PlayScore_ViewNumberTableViewCell";
        PlayScore_ViewNumberTableViewCell *cell = (PlayScore_ViewNumberTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        cell.viewNum_lbl.text = playScoreDic[@"num_seen_my_profile"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 1){
        static NSString *CellIdentifier = @"PlayScore_FirstSightTableViewCell";
        PlayScore_FirstSightTableViewCell *cell = (PlayScore_FirstSightTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        
        cell.chartView.mValueArray = [NSMutableArray arrayWithArray:@[playScoreDic[@"PIMBA_at_first_sight_YES"], playScoreDic[@"PIMBA_at_first_sight_NO"]]];
        cell.chartView.mColorArray = [NSMutableArray arrayWithArray:pieChartColor_array];

        cell.pimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ PIMBA", [playScoreDic[@"PIMBA_at_first_sight_YES"] floatValue]];
        cell.noPimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ not PIMBA", [playScoreDic[@"PIMBA_at_first_sight_NO"] floatValue]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 2){
        static NSString *CellIdentifier = @"PlayScore_DetailProfileTableViewCell";
        PlayScore_DetailProfileTableViewCell *cell = (PlayScore_DetailProfileTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        cell.chartView.mValueArray = [NSMutableArray arrayWithArray:@[playScoreDic[@"People_detailing_their_profile_YES"], playScoreDic[@"People_detailing_their_profile_NO"]]];
        cell.chartView.mColorArray = [NSMutableArray arrayWithArray:pieChartColor_array];
        cell.pimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ YES", [playScoreDic[@"People_detailing_their_profile_YES"] floatValue]];
        cell.noPimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ NO", [playScoreDic[@"People_detailing_their_profile_NO"] floatValue]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 3){
        static NSString *CellIdentifier = @"PlayScore_ProfilePhotoTableViewCell";
        PlayScore_ProfilePhotoTableViewCell *cell = (PlayScore_ProfilePhotoTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        
        cell.profile_ImgView.layer.cornerRadius = cell.profile_ImgView.frame.size.height/2;
        cell.profile_ImgView.layer.borderColor = image_borderColor.CGColor;
        cell.profile_ImgView.layer.borderWidth = 2;
        
        [cell.profile_ImgView setImageWithURL:[NSURL URLWithString:playScoreDic[@"score_under_pictures"][indexPath.row][@"profile_image"]] placeholderImage:profile_default];
        cell.pimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ PIMBA", [playScoreDic[@"score_under_pictures"][indexPath.row][@"PIMBA_under_the_profile_photo_YES"] floatValue]];
        cell.noPimba_lbl.text = [NSString stringWithFormat:@"%.1f⁒ not PIMBA", [playScoreDic[@"score_under_pictures"][indexPath.row][@"PIMBA_under_the_profile_photo_NO"] floatValue]];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 4){
        static NSString *CellIdentifier = @"PlayScore_VotingTableViewCell";
        PlayScore_VotingTableViewCell *cell = (PlayScore_VotingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        
        cell.note_lbl.text = [NSString stringWithFormat:@"%@ people voted for you",playScoreDic[@"num_vote_me"]];
        
        
        UIImage *dot = [UIImage imageNamed:@"star_empty.png"];
        UIImage *star = [UIImage imageNamed:@"star_gold.png"];
        
        cell.charm_rateCtrl = [[AMRatingControl alloc] initWithLocation:cell.charm_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
        [cell.charm_rateCtrl setEnabled:false];        
        [cell.charm_rateCtrl setRating:[playScoreDic[@"charm"] integerValue]];
        [cell addSubview:cell.charm_rateCtrl];
        
        cell.humor_rateCtrl = [[AMRatingControl alloc] initWithLocation:cell.humor_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
        [cell.humor_rateCtrl setEnabled:false];
        [cell.humor_rateCtrl setRating:[playScoreDic[@"humor"] integerValue]];
        [cell addSubview:cell.humor_rateCtrl];
        
        cell.chat_rateCtrl = [[AMRatingControl alloc] initWithLocation:cell.chat_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
        [cell.chat_rateCtrl setEnabled:false];
        [cell.chat_rateCtrl setRating:[playScoreDic[@"chat"] integerValue]];
        [cell addSubview:cell.chat_rateCtrl];
        
        cell.beauty_rateCtrl = [[AMRatingControl alloc] initWithLocation:cell.beauty_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
        [cell.beauty_rateCtrl setEnabled:false];
        [cell.beauty_rateCtrl setRating:[playScoreDic[@"beauty"] integerValue]];
        [cell addSubview:cell.beauty_rateCtrl];
        
        cell.horny_rateCtrl = [[AMRatingControl alloc] initWithLocation:cell.horny_rateCtrl.frame.origin emptyImage:dot solidImage:star andMaxRating:5];
        [cell.horny_rateCtrl setEnabled:false];
        [cell.horny_rateCtrl setRating:[playScoreDic[@"horny"] integerValue]];
        [cell addSubview:cell.horny_rateCtrl];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"Cell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, [UIScreen mainScreen].bounds.size.width - 30, 40)];
        lbl.textColor = [UIColor grayColor];
        lbl.text = tipStr;
        lbl.numberOfLines = 0;
        [lbl sizeToFit];
        [cell addSubview:lbl];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return  cell;
    }
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}
- (void)getPlayScore{
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_play_score"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_play_score: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            playScoreDic = [[NSDictionary alloc] initWithDictionary:[responseObject objectForKey:@"result"]];
            
            [self getTipStr];
            
            [userDetailTableView reloadData];
            [userDetailTableView setHidden:NO];
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

- (void) getTipStr{
    
    NSArray *tipArray = @[@"We are collecting data to give you statistics. Wait soon you will have your performance. ;)",
                          @[@"Try changing your first picture, because in the end the first impression is the one that is", @"Very well! You are a pimba Player!"],
                          @[@"Try changing the number of photo 'X' shows interesting places and their different sides, to attract fans to enjoy you.", @"Your photos are like movie photos! Congratulations!"],
                          @"It would be nice that more people rank you ask for his fans (when it finds them), you evaluate for other possible fans may approach you for their qualities",
                          @[@"Try to improve your 'X' that will attract a lot more tanned =). After all people are attracted by its qualities.", @"Only you and the Rock Stars know what it is! Keep it up"],
                          @[@"Wow! How are you? Brad pit?", @"Wow! How are you? Scarlett Johansson?"]];
    
    tipStr = @"";
    if([playScoreDic[@"num_seen_my_profile"] integerValue] < 50)
    {
        tipStr = tipArray[0];        
    }
    else{
        if([playScoreDic[@"PIMBA_at_first_sight_NO"] floatValue] > [playScoreDic[@"PIMBA_at_first_sight_YES"] floatValue])
            tipStr = [tipStr stringByAppendingString:tipArray[1][0]];
        else tipStr = [tipStr stringByAppendingString:tipArray[1][1]];
        
        tipStr = [tipStr stringByAppendingString:@"\n\n"];
        
        NSArray *tmpArray = playScoreDic[@"score_under_pictures"];
        NSMutableArray *numArray = [NSMutableArray new];
        for (int i = 0; i < tmpArray.count; i++) {
            if([tmpArray[i][@"PIMBA_under_the_profile_photo_NO"] floatValue] > [tmpArray[i][@"PIMBA_under_the_profile_photo_YES"] floatValue])
                [numArray addObject:[NSString stringWithFormat:@"%d",i+1]];
        }
        
        if(numArray.count > 0){
            NSString *str = [numArray componentsJoinedByString:@", "];
            str = [tipArray[2][0] stringByReplacingOccurrencesOfString:@"'X'" withString:[NSString stringWithFormat:@"%@", str]];
            tipStr = [tipStr stringByAppendingString:str];
        }
        else tipStr = [tipStr stringByAppendingString:tipArray[2][1]];
        
        tipStr = [tipStr stringByAppendingString:@"\n\n"];
        
        if([playScoreDic[@"num_vote_me"] integerValue] < 5){
            tipStr = [tipStr stringByAppendingString: tipArray[3]];
            tipStr = [tipStr stringByAppendingString:@"\n\n"];
        }
        
        
        tmpArray = @[@"charm", @"humor", @"chat", @"beauty", @"horny" ];
        numArray = [NSMutableArray new];
        NSMutableArray *rateArray = [NSMutableArray new];
        for (int i = 0; i < tmpArray.count; i++) {
            if([playScoreDic[tmpArray[i]] floatValue] <= 3)
                [numArray addObject:tmpArray[i]];
            if([playScoreDic[tmpArray[i]] floatValue] < 4)
                [rateArray addObject:tmpArray[i]];
            
        }
        if(numArray.count > 0){
            NSString *str = [numArray componentsJoinedByString:@", "];
            str = [tipArray[4][0] stringByReplacingOccurrencesOfString:@"'X'" withString:[NSString stringWithFormat:@"%@", str]];
            
            tipStr = [tipStr stringByAppendingString:str];
        }
        else tipStr = [tipStr stringByAppendingString:tipArray[4][1]];
        
        tipStr = [tipStr stringByAppendingString:@"\n\n"];
        
        if([playScoreDic[@"PIMBA_at_first_sight_YES"] floatValue] > 95 && rateArray.count == 0)
        {
            NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
            if([userInfo[@"sex"] integerValue] == 2)
                tipStr = [tipStr stringByAppendingString:tipArray[5][1]];
            else tipStr = [tipStr stringByAppendingString:tipArray[5][0]];
        }

    }
    
    
}
@end
