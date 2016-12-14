//
//  SettingViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "SettingViewController.h"
#import "DiscoverySettingViewController.h"
#import "AppSettingViewController.h"

#import <AFNetworking/AFNetworking.h>
#import "Constant.h"
@interface SettingViewController ()
{
    NSDictionary *settingInfo;
}
@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeSetting:) name:@"changeSetting" object:nil];
    
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

-(void)viewWillAppear:(BOOL)animated{
    if(settingInfo == nil) [self getSetting];
}

- (void) changeSetting:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    settingInfo = [[NSDictionary alloc] initWithDictionary:userInfo];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    if(indexPath.row == 0){
        cell.textLabel.text = @"Discovery Settings";
        cell.detailTextLabel.text = @"Distance, age and more";
    }
    else if (indexPath.row == 1){
        cell.textLabel.text = @"App Settings";
        cell.detailTextLabel.text = @"Notifications, account and more";
    }
    else{
        cell.textLabel.text = @"Help & Support";
        cell.detailTextLabel.text = @"FAQ, contact and more";
    }
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(indexPath.row == 0){
        if (settingInfo == nil) return;
        DiscoverySettingViewController *sub = [[DiscoverySettingViewController alloc] init];
        sub.settingInfo = settingInfo;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
        [self presentViewController:nav animated:YES completion:nil];
    }
    else if (indexPath.row == 1){
        if (settingInfo == nil) return;
        AppSettingViewController *sub = [[AppSettingViewController alloc] init];
        sub.settingInfo = settingInfo;
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)getSetting{
    /*get_preference	
     •	facebook_id*/
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_preference"];
    NSLog(@"get_preference :%@", parameters);
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"get_preference: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            settingInfo = [[NSDictionary alloc] initWithDictionary:[responseObject objectForKey:@"result"]];
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
