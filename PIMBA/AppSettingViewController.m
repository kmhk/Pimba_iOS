//
//  AppSettingViewController.m
//  PIMBA
//
//  Created by herocules on 3/1/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "AppSettingViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Constant.h"
#import "AppDelegate.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
@interface AppSettingViewController ()
{
    BOOL newPimba;
    BOOL message;
    BOOL SPimba;
    BOOL checkinLike;
    BOOL vote;
    BOOL onFire;
    BOOL ranking;
    BOOL sound;
}
@end

@implementation AppSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"App Settings";
    self.navigationController.navigationBar.hidden = false;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];

    NSString *tmpstr = self.settingInfo[@"noti_new_pimba"];
    newPimba = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"noti_message"];
    message = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"noti_super_pimba"];
    SPimba = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"noti_check_in_like"];
    checkinLike = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"noti_vote"];
    vote = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"on_fire"];
    onFire = tmpstr.intValue%2;
    tmpstr = self.settingInfo[@"enable_ranking"];
    ranking = tmpstr.intValue%2;
    sound = [[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"] ? NO : YES;
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
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0)  return 50;
    else if(section == 4) return 10;
    else return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if(section == 2) return 40;
    if(section == 4) return 30;
    return 10;
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    if (section == 2){
        return @"While joined PIMBA ranking, you will be showed on others' TOP PIMBA setion.";
    }
    
    else return nil;
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 6;
    else return 1;
    
    
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 0) return @"NOTIFICATIONS";
    else if(section == 1) return @"SOUND SETTING";
    else if(section == 2) return @"JOIN RANKING";
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if(indexPath.section == 0){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"New PIMBADAS";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = newPimba;
            swtch.tag = 101;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];

        }
        else if(indexPath.row == 1){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Mesages";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = message;
            swtch.tag = 102;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        else if(indexPath.row == 2){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Super Pimbas";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = SPimba;
            swtch.tag = 103;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        else if(indexPath.row == 3){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Check-in like";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = checkinLike;
            swtch.tag = 104;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        else if(indexPath.row == 4){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Vote";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = vote;
            swtch.tag = 105;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        else if(indexPath.row == 5){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"She’s on fire";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = onFire;
            swtch.tag = 106;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
        }

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 1){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Sounds of PIMBA";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = sound;
            swtch.tag = 108;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 2){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, 200, 50)];
            lbl.text = @"Join PIMBA ranking";
            [cell addSubview:lbl];
            
            UISwitch *swtch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width - 60, 9, 40, 31)];
            swtch.on = ranking;
            swtch.tag = 107;
            [swtch addTarget:self action:@selector(changeSwtch:) forControlEvents:UIControlEventValueChanged];
            [cell addSubview:swtch];
            
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    else if(indexPath.section == 3){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, 50)];
            lbl.text = @"Log Off";
            lbl.textAlignment = NSTextAlignmentCenter;
            [cell addSubview:lbl];
        }
    }
    else if(indexPath.section == 4){
        if(indexPath.row == 0){
            UILabel *lbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 0, [UIScreen mainScreen].bounds.size.width - 40, 50)];
            lbl.textAlignment = NSTextAlignmentCenter;
            lbl.text = @"Erase your account";
            [cell addSubview:lbl];
            
        }
    }
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.section == 3){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Do you want to log out really?"
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"Cancel"
                          otherButtonTitles:@"OK",nil];
        alert.tag = 1001;
        [alert show];

    }
    else if(indexPath.section == 4){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Erase your Pimba life!"
                                                        message:@"If you for some reason do not want people to know that you are or have been here the \"PIMBA\",we offer this feature for those who like to keep things clean"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"OK",nil];
        alert.tag = 1002;
        [alert show];
    }
    
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0 && alertView.tag == 1001){
        
        [userdefault setObject:nil forKey:@"pimba_fbId"];
        AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
        [appDelegate replaceRootViewController];
    }
    if(buttonIndex != 0 && alertView.tag == 1002){
        [self eraseProfile];
    }
}
- (void)changeSwtch:(UISwitch*)swth{
    if(swth.tag == 101) newPimba = swth.on;
    else if(swth.tag == 102) message = swth.on;
    else if(swth.tag == 103) SPimba = swth.on;
    else if(swth.tag == 104) checkinLike = swth.on;
    else if(swth.tag == 105) vote = swth.on;
    else if(swth.tag == 106) onFire = swth.on;
    else if(swth.tag == 107) ranking = swth.on;
    else if(swth.tag == 108) sound = swth.on;
}
- (void)eraseProfile{
    /*erase_user	
     
     facebook_id*/
    ShowNetworkActivityIndicator();
    [SVProgressHUD showWithStatus:@"Erasing your accout..." maskType:SVProgressHUDMaskTypeNone];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"erase_user"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        [SVProgressHUD dismiss];
        NSLog(@"erase_user: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [userdefault setObject:nil forKey:@"pimba_fbId"];
            AppDelegate *appDelegate=(AppDelegate*)[UIApplication sharedApplication].delegate;
            [appDelegate replaceRootViewController];
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
        [SVProgressHUD dismiss];
    }];

    
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
    
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"show_me_on_discover":self.settingInfo[@"show_me_on_discover"],
                                 @"people_interesting_in": self.settingInfo[@"people_interesting_in"],
                                 @"distance":self.settingInfo[@"distance"],
                                 @"sex":self.settingInfo[@"sex"],
                                 @"age_low":self.settingInfo[@"age_low"],
                                 @"age_high":self.settingInfo[@"age_high"],
                                 @"name_of_user":self.settingInfo[@"name_of_user"],
                                 
                                 @"noti_new_pimba":[NSString stringWithFormat:@"%d", newPimba == 0 ? 2:1],
                                 @"noti_message":[NSString stringWithFormat:@"%d", message == 0 ? 2:1],
                                 @"noti_super_pimba":[NSString stringWithFormat:@"%d", SPimba == 0 ? 2:1],
                                 @"noti_check_in_like":[NSString stringWithFormat:@"%d", checkinLike == 0 ? 2:1],
                                 @"noti_vote":[NSString stringWithFormat:@"%d", vote == 0 ? 2:1],
                                 @"on_fire":[NSString stringWithFormat:@"%d", onFire == 0 ? 2:1],
                                 
                                 @"enable_ranking":[NSString stringWithFormat:@"%d", ranking == 0 ? 2:1]
                                 
                                 };
    [userdefault setObject:sound ? @"1":@"2" forKey:@"sound_pimba"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeSetting" object:nil userInfo:parameters];
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"update_preference"];
    NSLog(@"update_preference :%@", parameters);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"update_preference: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            NSMutableDictionary *userInfo = [[NSMutableDictionary alloc] initWithDictionary:[userdefault objectForKey:@"pimba_profile" ]];
            
            [userdefault setObject:userInfo forKey:@"pimba_profile" ];
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
