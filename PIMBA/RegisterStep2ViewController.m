//
//  RegisterStep2ViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "RegisterStep2ViewController.h"
#import "SelectMoodViewController.h"
#import "ICSDrawerController.h"
#import "MenuViewController.h"
#import "FindPeopleViewController.h"
#import "Constant.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import <AFNetworking/AFNetworking.h>
#import "AppDelegate.h"
@interface RegisterStep2ViewController ()
{
    
}
@end

@implementation RegisterStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectMood:) name:@"selectMood" object:nil];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *birthday = [format dateFromString:self.userInfo[@"bithday"]];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    name_lbl.text = [NSString stringWithFormat:@"%@, %ld", self.userInfo[@"Name"], (long)age];
    welcome_lbl.text = [NSString stringWithFormat:@"Welcome %@!", self.userInfo[@"Name"]];
    
    mood_lbl.layer.cornerRadius = 6;
    school_txtfld.layer.cornerRadius = 6;
    description_txtfld.layer.cornerRadius = 6;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)selectMood:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    mood_lbl.text = userInfo[@"mood"];
}


- (IBAction)click_doneBttn:(UIButton *)sender {
    
    if(![mood_lbl.text  isEqual: @""] &&
       ![school_txtfld.text  isEqual: @""] &&
       ![description_txtfld.text  isEqual: @""]){
        
        [self registerUserInfo];
    }
    else{
        [[[UIAlertView alloc] initWithTitle:@"Please complete all fields to start using the app"
                                    message:nil
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }
}

- (IBAction)click_selectMoodBttn:(id)sender {
    SelectMoodViewController *sub = [[SelectMoodViewController alloc] init];
    sub.moodStr = mood_lbl.text;
    [self.navigationController pushViewController:sub animated:YES];
}

- (void) registerUserInfo{
    
    /*•	device_id
     •	device_type (1- Android, 2-iOS)
     •	token
     •	facebook_id
     •	facebook_name
     •	sex
     •	age ( 1-man,2-woman)
     •	mood_today
     •	studies_in
     •	description
     •	profile_image1
*/
    NSString *schoolStr = [school_txtfld.text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *descriptStr = [description_txtfld.text stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *nameStr = [self.userInfo[@"Name"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MM/dd/yyyy"];
    
    NSDate *birthday = [format dateFromString:self.userInfo[@"bithday"]];
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    
    [SVProgressHUD showWithStatus:@"Wait a sec..." maskType:SVProgressHUDMaskTypeNone];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"device_type"     :@"iOS",
                                 @"device_id"       :[[[UIDevice currentDevice] identifierForVendor] UUIDString],
                                 @"facebook_id"     :self.userInfo[@"FacebookId"],
                                 @"token"           :@"",
                                 @"facebook_name"   :nameStr,
                                 @"sex"             :[self.userInfo[@"Gender"] isEqual: @"female"] ? @"2" : @"1",
                                 @"age"             :[NSString stringWithFormat:@"%ld", (long)age],
                                 @"mood_today"      :[NSString stringWithFormat:@"%lu",[moodArray indexOfObject:mood_lbl.text] + 1],
                                 @"studies_in"      :schoolStr,
                                 @"description"     :descriptStr};
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"signup"];
    
    NSLog(@"signup params : %@", parameters);
    
    [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<self.imgArray.count; i++) {
            NSString *nameStr = [NSString stringWithFormat:@"profile_image%d", i+1];
            NSData *imgData = [[NSData alloc] init];
            UIImage *tmpImg = self.imgArray[i];
            imgData = UIImageJPEGRepresentation(tmpImg, 0.3);
            if(imgData != nil){
                [formData appendPartWithFileData:imgData name:nameStr fileName:@"image.jpg" mimeType:@"image/jpeg"];
            }
            
        }
        
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [SVProgressHUD dismiss];
        NSLog(@"signup: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [userdefault setObject:self.userInfo[@"FacebookId"] forKey:@"pimba_fbId"];
            [userdefault setObject:[responseObject objectForKey:@"result"] forKey:@"pimba_profile"];
            
            AppDelegate *appDelegate=( AppDelegate* )[UIApplication sharedApplication].delegate;
            [appDelegate updatePushToken];
            
            MenuViewController *menuV = [[MenuViewController alloc] init];
            FindPeopleViewController *plainColorVC = [[FindPeopleViewController alloc] init];
            
            ICSDrawerController *drawer = [[ICSDrawerController alloc] initWithLeftViewController:menuV
                                                                             centerViewController:plainColorVC];
            
            [self presentViewController:drawer animated:YES completion:nil];
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
