//
//  MenuViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "MenuViewController.h"

#import "FindPeopleViewController.h"
#import "DestinyViewController.h"
#import "CheckInViewController.h"
#import "SecondChanceViewController.h"
#import "VoteViewController.h"
#import "PlayScoreViewController.h"
#import "MessageListViewController.h"
#import "TopRankingViewController.h"
#import "SettingViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"

#import "ProfileViewController.h"
@interface MenuViewController ()<UITableViewDataSource, UITableViewDelegate>
{
    UITableView *menuTableView;
    NSArray *titleArray;
    NSInteger previousRow;
    UIImageView *profileImgView;
    
    FindPeopleViewController *sub1;
    DestinyViewController *sub2;
    CheckInViewController *sub3;
    SecondChanceViewController *sub4;
    VoteViewController *sub5;
    PlayScoreViewController *sub6;
    MessageListViewController *sub7;
    TopRankingViewController *sub8;
    SettingViewController *sub9;
        
}
@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    titleArray = @[@"People Radar",
                   @"Pimba Destiny",
                   @"Check-in",
                   @"Second Chance",
                   @"Vote",
                   @"Play Score",
                   @"Messages",
                   @"TOP PIMBA",
                   @"Settings"];
    
    menuTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    menuTableView.dataSource = self;
    menuTableView.delegate = self;
    menuTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:menuTableView];
    
    menuTableView.tableHeaderView = ({
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 140.0f)];
        view.backgroundColor = [UIColor colorWithRed:200.f/255 green:200.f/255 blue:200.f/255 alpha:0.4];
        
        profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(20, 40, 60, 60)];
        NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
        [profileImgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
        profileImgView.layer.cornerRadius = 30;
        profileImgView.layer.borderColor = image_borderColor.CGColor;
        profileImgView.layer.borderWidth = 1.0;
        profileImgView.clipsToBounds = YES;
        profileImgView.contentMode = UIViewContentModeScaleAspectFill;
        [view addSubview:profileImgView];
        
        UILabel *nameLbl = [[UILabel alloc] initWithFrame: CGRectMake(20, 100, 160, 30)];
        nameLbl.text = userInfo[@"facebook_name"];
        [view addSubview:nameLbl];
        
        view;
    });
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfile:)];
    tap.numberOfTapsRequired = 1;
    [menuTableView.tableHeaderView addGestureRecognizer:tap];
    
    
    sub1 = (FindPeopleViewController*) self.drawer.centerViewController;
    sub2 = [[DestinyViewController alloc] init];
    sub3 = [[CheckInViewController alloc] init];
    sub4 = [[SecondChanceViewController alloc] init];
    sub5 = [[VoteViewController alloc] init];
    sub6 = [[PlayScoreViewController alloc] init];
    sub7 = [[MessageListViewController alloc] init];
    sub8 = [[TopRankingViewController alloc] init];
    sub9 = [[SettingViewController alloc] init];
    
}
- (void) viewWillAppear:(BOOL)animated{
    NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
    [profileImgView setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) tapProfile:(UIGestureRecognizer*)tap{
    ProfileViewController *sub = [[ProfileViewController alloc] init];
    sub.profileInfo = [[NSMutableDictionary alloc] initWithDictionary:[userdefault objectForKey:@"pimba_profile" ]];
    [self presentViewController:sub animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return titleArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    static NSString *cellIdentifier = @"CElll";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];

    cell.textLabel.text = titleArray[indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == previousRow) {
        
        [self.drawer close];
    }
    else {
        previousRow = indexPath.row;
       /* typeof(self) __weak weakSelf = self;
        [self.drawer reloadCenterViewControllerUsingBlock:^(){
            
          //  weakSelf.drawer.centerViewController.view.backgroundColor = weakSelf.colors[indexPath.row];
        }];*/
        if(indexPath.row == 0){//find people
            
            [self.drawer replaceCenterViewControllerWithViewController:sub1];
        }
        else if(indexPath.row == 1){//Destiny
            
            [self.drawer replaceCenterViewControllerWithViewController:sub2];
        }
        else if(indexPath.row == 2){//CheckIn
            
            [self.drawer replaceCenterViewControllerWithViewController:sub3];
        }
        else if(indexPath.row == 3){//SecondChance
            
            [self.drawer replaceCenterViewControllerWithViewController:sub4];
        }
        else if(indexPath.row == 4){//Vote
            
            [self.drawer replaceCenterViewControllerWithViewController:sub5];
        }
        else if(indexPath.row == 5){//PlayScore
            
            [self.drawer replaceCenterViewControllerWithViewController:sub6];
        }
        else if(indexPath.row == 6){//message
            
            [self.drawer replaceCenterViewControllerWithViewController:sub7];
        }
        else if(indexPath.row == 7){//top pimba
            
            [self.drawer replaceCenterViewControllerWithViewController:sub8];
        }
        else if(indexPath.row == 8){//Setting
            
            [self.drawer replaceCenterViewControllerWithViewController:sub9];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
#pragma mark - ICSDrawerControllerPresenting

- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}


@end
