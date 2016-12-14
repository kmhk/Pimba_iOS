//
//  DiscoverySettingViewController.m
//  PIMBA
//
//  Created by herocules on 3/1/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "DiscoverySettingViewController.h"
#import "SelectInterestTableViewController.h"
#import "SelectGenderTableViewController.h"
#import "Constant.h"
#import <AFNetworking/AFNetworking.h>
#import <NMRangeSlider/NMRangeSlider.h>
@interface DiscoverySettingViewController ()
{
    BOOL showme;
    NSString *interestStr;
    
    NSString *locationAddress;
    NSString *maxDistanceStr;
    NSString *genderStr;
    NSString *age_minStr;
    NSString *age_maxStr;
    NSString *usernameStr;
    
}
@end

@implementation DiscoverySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Discovery Settings";
    self.navigationController.navigationBar.hidden = false;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];

    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getInterest:) name:@"selectInterest" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGender:) name:@"selectGender" object:nil];
    NSString *tmpstr = self.settingInfo[@"show_me_on_discover"];
    showme = tmpstr.intValue%2;
    interestStr = self.settingInfo[@"people_interesting_in"];
    maxDistanceStr = self.settingInfo[@"distance"];
    
    genderStr = self.settingInfo[@"sex"];
    age_minStr = self.settingInfo[@"age_low"];
    age_maxStr = self.settingInfo[@"age_high"];
    usernameStr = self.settingInfo[@"name_of_user"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)Done{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    
    
    [self saveSettings];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 0 || section == 4) return 60;
    else return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        return 50;
    }
    else if(indexPath.section == 1){
        return 50;
    }
    else if (indexPath.section == 2){
        return 70;
    }
    else if (indexPath.section == 3){
        if(indexPath.row == 0) return 60;
        else return 70;
    }
    else return 60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    else if (section == 1) return 1;
    else if (section == 2) return 1;
    else if (section == 3) return 2;
    else return 1;

}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 1){
        return @"Interest";
    }
    else if (section == 2){
        return @"WHERE";
    }
    else if (section == 3){
        return @"WHO";
    }
    else if (section == 4) return @"WEB PROFILE";
    else return nil;
}

- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 0){
        return @"While turned off, you will not be shown in the card stack. You can still see and chat with your matches.";
    }
    else if (section == 4){
        return @"Create a public Username. Share your Username. Have people all over the world swipe you on PIMBA";
    }
    else return nil;
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if(indexPath.section == 0){
        
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
        lbl.text = @"Show me in Discovery";
        [cell addSubview:lbl];
        
        UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
       
        swtch.on = showme;
        [swtch addTarget:self action:@selector(changeShowme:) forControlEvents:UIControlEventValueChanged];
        [cell addSubview:swtch];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    else if(indexPath.section == 1){
        
        UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 50, 50)];
        lbl.text = selectMoodArray[interestStr.integerValue-1];
        [cell addSubview:lbl];
        
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
    }
    else if(indexPath.section == 2){
        
        if (indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 30)];
            lbl.text = @"Maximum Distance";
            [cell addSubview:lbl];
            
            UILabel *lbl1 = [[UILabel alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 80, 30)];
            lbl1.text = [NSString stringWithFormat:@"%@Km",maxDistanceStr];
            lbl1.textAlignment = NSTextAlignmentRight;
            lbl1.textColor = [UIColor grayColor];
            [cell addSubview:lbl1];
            
            UISlider *sldr = [[UISlider alloc] initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width - 40, 40)];
            sldr.minimumValue = 1;
            sldr.maximumValue = 100;
            sldr.value = maxDistanceStr.floatValue;
            [sldr addTarget:self action:@selector(changeDistance:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:sldr];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    else if(indexPath.section == 3){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 80, 60)];
            lbl.text = @"Gender";
            [cell addSubview:lbl];

            UILabel *lbl2 = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 200, 0, 170, 60)];
            lbl2.textAlignment = NSTextAlignmentRight;
            lbl2.text = genderArray[genderStr.intValue-1];
            lbl2.textColor = [UIColor grayColor];
            [cell addSubview:lbl2];
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }
        else{
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 30)];
            lbl.text = @"Age Range";
            [cell addSubview:lbl];
            
            UILabel *lbl1 = [[UILabel alloc] initWithFrame: CGRectMake([UIScreen mainScreen].bounds.size.width - 100, 0, 80, 30)];
            
            lbl1.text = [NSString stringWithFormat:@"%@-%@", age_minStr, age_maxStr];
            lbl1.textAlignment = NSTextAlignmentRight;
            lbl1.textColor = [UIColor grayColor];
            [cell addSubview:lbl1];

            NMRangeSlider *Slider = [[NMRangeSlider alloc] initWithFrame:CGRectMake(20, 30, [UIScreen mainScreen].bounds.size.width - 40, 40)];
            Slider.minimumValue = 18.f/100;
            Slider.maximumValue = 55.f/100;
            
            Slider.lowerValue = age_minStr.floatValue/100;
            Slider.upperValue = age_maxStr.floatValue/100;
            Slider.stepValue = 1.f/100;
            Slider.minimumRange = 4.f/100;
            
            [Slider addTarget:self action:@selector(changeAge:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:Slider];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 1){
        SelectInterestTableViewController *sub = [[SelectInterestTableViewController alloc] init];
        sub.moodStr = selectMoodArray[interestStr.integerValue-1];
        [self.navigationController pushViewController:sub animated:YES];
    }
    if(indexPath.section == 3){
        if(indexPath.row == 0){
            SelectGenderTableViewController *sub = [[SelectGenderTableViewController alloc] init];
            sub.genderStr = genderArray[genderStr.integerValue-1];
            [self.navigationController pushViewController:sub animated:YES];

        }
    }
}
- (void)changeShowme:(UISwitch*)swt{
    showme = swt.on;
}

- (void)changeDistance:(UISlider*)sld{
    maxDistanceStr = [NSString stringWithFormat:@"%d", (int)sld.value];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [TableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

}

- (void)changeAge:(NMRangeSlider*)sld{
    age_minStr = [NSString stringWithFormat:@"%.0f", sld.lowerValue*100];
    age_maxStr = [NSString stringWithFormat:@"%.0f", sld.upperValue*100];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:1 inSection:3];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [TableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];

}
- (void)getInterest:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    interestStr = userInfo[@"mood"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [TableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)getGender:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    genderStr = userInfo[@"gender"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:3];
    NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
    [TableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
}

- (void)saveSettings{
    /*update_preference	
     
     •	facebook_id
     •	show_me_on_discover(1-show me, 2- not)
     •	people_interesting_in
     •	localization_address
     •	localization_latitude
     •	localization_longitude
     •	distance_low
     •	distance_high
     •	sex (1-man, 2-woman,3-ALL)
     •	age_low
     •	age_high
     •	name_of_user
     
     •	noti_new_pimba ( 1-turn on,2-turnoff)
     •	noti_message
     •	noti_super_pimba
     •	noti_check_in_like
     •	noti_vote
     •	on_fire        (1- turn on, 2 –turn off)
     •	enable_ranking (1, enable, 2 disable)
*/
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"show_me_on_discover":[NSString stringWithFormat:@"%d",showme == 0 ? 2:1],
                                 @"people_interesting_in": interestStr,
                                 @"distance":maxDistanceStr,
                                 @"sex":genderStr,
                                 @"age_low":age_minStr,
                                 @"age_high":age_maxStr,
                                 @"name_of_user":usernameStr,
                                 
                                 @"noti_new_pimba":self.settingInfo[@"noti_new_pimba"],
                                 @"noti_message":self.settingInfo[@"noti_message"],
                                 @"noti_super_pimba":self.settingInfo[@"noti_super_pimba"],
                                 @"noti_check_in_like":self.settingInfo[@"noti_check_in_like"],
                                 @"noti_vote":self.settingInfo[@"noti_vote"],
                                 @"on_fire":self.settingInfo[@"on_fire"],
                                 @"enable_ranking":self.settingInfo[@"enable_ranking"],
                                 
                                 };
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSetting" object:nil userInfo:parameters];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"update_preference"];
    NSLog(@"update_preference :%@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"update_preference: %@", responseObject);
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

@end
