//
//  CheckInViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "CheckInViewController.h"
#import "FindAddressViewController.h"
#import "Constant.h"
#import "Person.h"
#import <AFNetworking/AFNetworking.h>
#import <MHPrettyDate/MHPrettyDate.h>
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import "FindUserCheckinViewController.h"

#import "CheckinTableViewCell.h"
@interface CheckInViewController ()
{
    NSMutableArray *placeArray;
}
@end

@implementation CheckInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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
- (void) viewWillAppear:(BOOL)animated{
    [self getPlaceList];
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

- (IBAction)click_checkinBttn:(id)sender {
    FindAddressViewController *sub = [[FindAddressViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (IBAction)click_findpeopleBttn:(id)sender {
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  60;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [placeArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"CheckinTableViewCell";
    CheckinTableViewCell *cell = (CheckinTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
    
    NSDateFormatter *dateFormatter= [NSDateFormatter new];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:[[NSLocale currentLocale] localeIdentifier]]];
    NSDate *date = [dateFormatter dateFromString:placeArray[indexPath.row][@"date_time"]];
    cell.place_lbl.text = [NSString stringWithFormat:@"%@ - %@", placeArray[indexPath.row][@"address"], [MHPrettyDate prettyDateFromDate:date withFormat:MHPrettyDateFormatNoTime]];
    
    [cell.cancel_bttn addTarget:self action:@selector(deletePlace:) forControlEvents:UIControlEventTouchUpInside];
    cell.cancel_bttn.tag = 1200+indexPath.row;
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self getMatchedList:placeArray[indexPath.row]];
}
- (void)deletePlace:(UIButton*)sender{
    [self removePlace:placeArray[sender.tag - 1200][@"locater_id"]];
    [placeArray removeObjectAtIndex:sender.tag - 1200];
    [TableView reloadData];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if(buttonIndex != 0 && alertView.tag == 2111){
        
    }
}
- (void)removePlace:(NSString*)locatorId{
    /*remove_checkin	
     
     •	facebook_id
     •	locater_id
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"locater_id":locatorId};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"remove_checkin"];
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"remove_checkin: %@", responseObject);
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
        
    }];

}
- (void)getPlaceList{
    /*get_checkin_address	     
     facebook_id*/
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_checkin_address"];
   

    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_checkin_address: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            placeArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"result"]];
            [TableView reloadData];
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

- (void) getMatchedList:(NSDictionary*)placeInfo{
    
    /*find_people_check_inPlaces
     
     •	facebook_id
     •	locater_id
     •	latitude
     •	longitude
     */
    ShowNetworkActivityIndicator();
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"latitude":placeInfo[@"latitude"],
                                 @"longitude":placeInfo[@"longitude"],
                                 @"locater_id":placeInfo[@"locater_id"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"find_people_check_inPlaces"];
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        [SVProgressHUD dismiss];
        NSLog(@"find_people_check_inPlaces: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            NSArray *tmpAry = [responseObject objectForKey:@"result"];
            
            if(tmpAry.count>0){
                FindUserCheckinViewController *sub = [[FindUserCheckinViewController alloc] init];
                sub.people = [NSMutableArray new];
                for (int i = 0; i<tmpAry.count; i++) {
                    [sub.people addObject:[[Person alloc] initWithUserInfo:tmpAry[i]]];
                }
                sub.placeStr = placeInfo[@"address"];
                [self presentViewController:sub animated:YES completion:nil];
            }
            else
                [[[UIAlertView alloc] initWithTitle:@"Ooops!"
                                            message:@"Thers is no users checked-in in this place"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
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
@end
