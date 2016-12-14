//
//  LoginViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterStep1ViewController.h"
#import "FBLoginHandler.h"
#import "ICSDrawerController.h"
#import "MenuViewController.h"
#import "FindPeopleViewController.h"

#import "Constant.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>

#import "AppDelegate.h"
@interface LoginViewController ()<FBLoginHandlerDelegate>

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)click_loginBttn:(UIButton *)sender {
    
    FBLoginHandler *fbLoginHandler = [FBLoginHandler sharedInstance];
    fbLoginHandler.delegate = self;
    [fbLoginHandler loginWithFacebook];
  
}
-(void)didFacebookUserLogin:(BOOL)login withDetail:(NSDictionary *)userInfo{
    if (login)
    {
        
        
        NSLog(@"Do something when user is loggin with data %@",userInfo);
        [self loginToServer:userInfo];
    

        
    }
    else [SVProgressHUD dismiss];}
-(void)didFacebookUserLoginFail{
    [SVProgressHUD dismiss];
}

- (void)loginToServer:(NSDictionary*)userInfo{
    [SVProgressHUD showWithStatus:@"Wait a sec..." maskType:SVProgressHUDMaskTypeNone];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":userInfo[@"FacebookId"],
                                 @"device_type":@"iOS"};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"check_signup_login"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"check_signup_login: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])//login
        {
            [userdefault setObject:userInfo[@"FacebookId"] forKey:@"pimba_fbId"];
            [userdefault setObject:[responseObject objectForKey:@"result"] forKey:@"pimba_profile"];
            AppDelegate *appDelegate=( AppDelegate* )[UIApplication sharedApplication].delegate;
            [appDelegate updatePushToken];
            
            MenuViewController *menuV = [[MenuViewController alloc] init];
            FindPeopleViewController *plainColorVC = [[FindPeopleViewController alloc] init];
            
            ICSDrawerController *drawer = [[ICSDrawerController alloc] initWithLeftViewController:menuV
                                                                             centerViewController:plainColorVC];
            [self presentViewController:drawer animated:YES completion:nil];
        }
        else if([[responseObject objectForKey:@"flag"]  isEqual: @"2"])//sign up
        {
            
            RegisterStep1ViewController *sub = [[RegisterStep1ViewController alloc] init];
            sub.userInfo = userInfo;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
            [nav navigationBar].hidden = YES;
            
            [self presentViewController:nav animated:YES completion:nil];
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
@end
