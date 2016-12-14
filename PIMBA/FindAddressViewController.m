//
//  FindAddressViewController.m
//  PIMBA
//
//  Created by herocules on 3/3/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "FindAddressViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Constant.h"
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
@interface FindAddressViewController ()
{
    NSArray *suggestAddressArry;
    NSDictionary *selectPlace;
}
@end

@implementation FindAddressViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Check-in";
    
    self.navigationController.navigationBar.translucent = NO;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelBttn)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
    self.navigationItem.rightBarButtonItem.enabled = false;
    
    UIView *vwContainer2 = [[UIView alloc] init];
    [vwContainer2 setFrame:CGRectMake(0.0f, 0.0f, 25, searTxtfld.frame.size.height)];
    [vwContainer2 setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *icon2 = [[UIImageView alloc] init];
    [icon2 setImage:[UIImage imageNamed:@"search-icon"]];
    [icon2 setFrame:CGRectMake(0.0f,(searTxtfld.frame.size.height - 20)/2, 20, 20)];
    [icon2 setBackgroundColor:[UIColor clearColor]];
    
    [vwContainer2 addSubview:icon2];
    [searTxtfld setLeftView:vwContainer2];
    [searTxtfld setLeftViewMode:UITextFieldViewModeAlways];
    
    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(0, searTxtfld.frame.size.height-0.6f, searTxtfld.frame.size.width+10, 0.6f)];
    line2.backgroundColor = [UIColor lightGrayColor];
    [searTxtfld addSubview:line2];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)viewDidAppear:(BOOL)animated{
    if([userdefault objectForKey:@"pimba_currentlocation"] == nil ||
       [[userdefault objectForKey:@"pimba_currentlocation"][@"lat"]  isEqual: @"0.0"]){
        NSLog(@"location error");
                
        [[[UIAlertView alloc] initWithTitle:@"Warning!"
                                    message:@"Please turn on the location service about this application."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        
    }
    [self getAutoSuggestAddress:@""];
}
- (void)cancelBttn{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)Done{
    [self checkInPlace];
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSLog(@"%@",newString);
    if((newString.length >= 3) &&
       (searTxtfld == textField))
    {
        [self getAutoSuggestAddress:newString];
    }
    else{
        [TableView setHidden:YES];
    }
    return YES;
}
- (void) getAutoSuggestAddress:(NSString*)keyStr{
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSString *latitudeStr, *longitudeStr;
    NSDateFormatter *dt=[[NSDateFormatter alloc] init];
    [dt setDateFormat:@"yyyyMMdd"];
    NSString *curr_dt = [dt stringFromDate:[NSDate date]];
    if([userdefault objectForKey:@"pimba_currentlocation"] == nil ||
       [[userdefault objectForKey:@"pimba_currentlocation"][@"lat"]  isEqual: @"0.0"]){
        NSLog(@"location error");
        HideNetworkActivityIndicator();
        
        [[[UIAlertView alloc] initWithTitle:@"Warning!"
                                    message:@"Please turn on the location service about this application."
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
        return;
    }
    else{
        latitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lat"];
        longitudeStr = [userdefault objectForKey:@"pimba_currentlocation"][@"lnt"];
    }
    
    NSDictionary *parameters = @{@"client_id":CLIENT_ID,
                                 @"client_secret":CLIENT_SECRET,
                                 @"ll":[NSString stringWithFormat:@"%@,%@", latitudeStr,longitudeStr],
                                 
                                 @"llAcc":@"1000",
                                 @"limit":@"10",
                                 @"query":keyStr,
                                 @"radius":@"80000",
                                 @"v":curr_dt
                                 };
    NSLog(@"search address parms : %@", parameters);
    [manager GET:foursquare_url parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"foursquare result: %@", responseObject);
        {
            suggestAddressArry = [[NSArray alloc] initWithArray:[responseObject objectForKey:@"response"][@"venues"] ];
            [TableView reloadData];
            [TableView setHidden:NO];
        }
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        HideNetworkActivityIndicator();
    }];

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [suggestAddressArry count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    
    
    cell.textLabel.text = [suggestAddressArry objectAtIndex:indexPath.row][@"name"];
    cell.textLabel.textColor = [UIColor darkGrayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    
    NSArray *tmparry = [suggestAddressArry objectAtIndex:indexPath.row][@"location"][@"formattedAddress"];
    
    cell.detailTextLabel.text = [tmparry componentsJoinedByString:@" "];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.imageView.image = [UIImage imageNamed:@"place-pin"];
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    selectPlace = [suggestAddressArry objectAtIndex:indexPath.row];
    searTxtfld.text = [suggestAddressArry objectAtIndex:indexPath.row][@"name"];
    self.navigationItem.rightBarButtonItem.enabled = true;
    [tableView setHidden:YES];
}

- (void)checkInPlace{
    /*make_checkin_place	
     
     •	facebook_id
     •	address
     •	latitude
     •	longitude
     •	locater_id
     */
    ShowNetworkActivityIndicator();
    [SVProgressHUD showWithStatus:@"Loading..." maskType:SVProgressHUDMaskTypeNone];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"address":selectPlace[@"name"],
                                 @"latitude":selectPlace[@"location"][@"lat"],
                                 @"longitude":selectPlace[@"location"][@"lng"],
                                 @"locater_id":selectPlace[@"id"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"make_checkin_place"];
    
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        HideNetworkActivityIndicator();
        [SVProgressHUD dismiss];
        NSLog(@"make_checkin_place: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [self dismissViewControllerAnimated:YES completion:nil];
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
