//
//  TopRankingViewController.m
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "TopRankingViewController.h"
#import "TopRankingTableViewCell.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
@interface TopRankingViewController ()
{
    NSArray *womanArray, *manArray;
    NSString *genderStr;
}
@end

@implementation TopRankingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    genderStr = @"1";
    
    
    [self initViewSetting];
    [self getUserList];
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

- (IBAction)click_genderBttn:(UIButton *)sender {
    if(sender.tag == 201){
        genderStr = @"1";
        [gender_womanBttn setTitleColor:[UIColor colorWithRed:0/255 green:122.f/255 blue:255.f/255 alpha:1.0] forState:UIControlStateNormal];
        [gender_manBttn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    else if(sender.tag == 202){
        genderStr = @"2";
        [gender_manBttn setTitleColor:[UIColor colorWithRed:0/255 green:122.f/255 blue:255.f/255 alpha:1.0] forState:UIControlStateNormal];
        [gender_womanBttn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    }
    [listTableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 150;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(genderStr.integerValue == 1) return womanArray.count;
    else return manArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"TopRankingTableViewCell";
    TopRankingTableViewCell *cell = (TopRankingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
 
    cell.user_imgview.layer.cornerRadius = cell.user_imgview.frame.size.height/2;
    cell.user_imgview.layer.borderColor = image_borderColor.CGColor;
    cell.user_imgview.layer.borderWidth = 4;
    
    cell.index_lbl.text = [NSString stringWithFormat:@"%ld° TOP PIMBA", indexPath.row+1];
    NSNumberFormatter *formatter = [NSNumberFormatter new];
    [formatter setNumberStyle:NSNumberFormatterDecimalStyle]; // this line is important!
    
    if(genderStr.integerValue == 1){
        [cell.user_imgview setImageWithURL:[NSURL URLWithString:womanArray[indexPath.row][@"profile_image"]] placeholderImage:profile_default];
        cell.username_lbl.text = [NSString stringWithFormat:@"%@, %@", womanArray[indexPath.row][@"facebook_name"], womanArray[indexPath.row][@"age"]];
        NSNumber *num =  [NSNumber numberWithInteger:[womanArray[indexPath.row][@"score"] integerValue]];
        cell.score_lbl.text = [NSString stringWithFormat:@"Score %@", [formatter stringFromNumber:num]];
    }
    else if(genderStr.integerValue == 2){
        [cell.user_imgview setImageWithURL:[NSURL URLWithString:manArray[indexPath.row][@"profile_image"]] placeholderImage:profile_default];
        cell.username_lbl.text = [NSString stringWithFormat:@"%@, %@", manArray[indexPath.row][@"facebook_name"], manArray[indexPath.row][@"age"]];
        NSNumber *num =  [NSNumber numberWithInteger:[manArray[indexPath.row][@"score"] integerValue]];
        cell.score_lbl.text = [NSString stringWithFormat:@"Score %@", [formatter stringFromNumber:num]];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}
- (void) getUserList{
    
    /*get_top_pimba	
     
     	facebook_id
     	localization_longitude
     	localization_longitude
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
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_top_pimba"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_top_pimba: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            country_lbl.text = [NSString stringWithFormat:@"TOP PIMBA [%@]",[responseObject objectForKey:@"country"]];
            womanArray = [[NSArray alloc] initWithArray:[responseObject objectForKey:@"woman"]];
            manArray = [[NSArray alloc] initWithArray:[responseObject objectForKey:@"man"]];
            [listTableView reloadData];
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
