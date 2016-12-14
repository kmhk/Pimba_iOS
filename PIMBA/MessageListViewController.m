//
//  MessageListViewController.m
//  PIMBA
//
//  Created by herocules on 3/15/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "MessageListViewController.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"

#import "ChatViewController.h"
@interface MessageListViewController ()
{
    NSMutableArray *newMatchArray, *chatListArray;
}
@end

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initViewSetting];
    
}
- (void) initViewSetting{
    UIView *lineV = [[UIView alloc] initWithFrame:CGRectMake(0, navBarView.frame.size.height-0.6, [UIScreen mainScreen].bounds.size.width, 0.6)];
    lineV.backgroundColor = [UIColor lightGrayColor];
    [navBarView addSubview:lineV];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)pushNotificationReceived:(NSNotification *)anote
{
    [self getChatList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushNotificationReceived:) name:@"ChattingNotification" object:nil];
  //  [userdefault setObject:Yes forKey:kChatWindow];
    [self getChatList];
}
- (void) viewDidDisappear:(BOOL)animated{
    
 //   [userdefault setObject:No forKey:kChatWindow];
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

- (void) getChatList{
    /*get_matchedFriend_list_chat	
     
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
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"get_matchedFriend_list_chat"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"get_matchedFriend_list_chat: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            newMatchArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"new_friends"]];
            chatListArray = [[NSMutableArray alloc] initWithArray:[responseObject objectForKey:@"old friends"]];
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


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 4;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0){
        if(newMatchArray.count == 0) return 0;
        else return 110;
    }
    else return  82;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    else return chatListArray.count;
    
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    if(section == 0){
        return @"NEW MATCHES";
    }
    else if (section == 1){
        return @"MESSAGES";
    }
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
 
    if(indexPath.section == 0){
        
        UIScrollView *scrollview = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 110)];
        [scrollview setContentSize:CGSizeMake(100 * newMatchArray.count, 110)];
        for (int i = 0; i < newMatchArray.count; i++)
        {
            UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(i*100, 0, 100, 110)];
            UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 70, 70)];
            
            [profileImgView setImageWithURL:[NSURL URLWithString:newMatchArray[indexPath.row][@"profile_image"][0][@"profile_image"]]
                           placeholderImage:profile_default];
            profileImgView.layer.cornerRadius = profileImgView.frame.size.height/2;
            profileImgView.layer.borderColor = image_borderColor.CGColor;
            
            profileImgView.clipsToBounds = YES;
            profileImgView.contentMode = UIViewContentModeScaleAspectFill;
            [contentView addSubview:profileImgView];
            
            UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 100, 30)];
            nameLbl.text = newMatchArray[indexPath.row][@"facebook_name"];
            nameLbl.textAlignment = NSTextAlignmentCenter;
            nameLbl.font = [UIFont systemFontOfSize:14];
            
            contentView.tag = 2000+i;
            [contentView addSubview:nameLbl];
            
            [scrollview addSubview:contentView];
            
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapNewUser:)];
            tap.numberOfTapsRequired = 1;
            [contentView addGestureRecognizer:tap];
        }
        
        [cell addSubview:scrollview];
        
    }
    else {
        
        UIImageView *profileImgView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 6, 70, 70)];
        
        [profileImgView setImageWithURL:[NSURL URLWithString:chatListArray[indexPath.row][@"profile_image"][0][@"profile_image"]]
                       placeholderImage:profile_default];
        profileImgView.layer.cornerRadius = profileImgView.frame.size.height/2;
        profileImgView.layer.borderColor = image_borderColor.CGColor;
        profileImgView.clipsToBounds = YES;
        profileImgView.contentMode = UIViewContentModeScaleAspectFill;
        [cell addSubview:profileImgView];
        
        UILabel *pLbl = [[UILabel alloc] initWithFrame:CGRectMake(70, 0, 20, 82)];
        pLbl.textAlignment = NSTextAlignmentRight;
        pLbl.text = @"●";
        pLbl.font = [UIFont systemFontOfSize:28];
        pLbl.textColor = [UIColor blueColor];
        if([chatListArray[indexPath.row][@"read_or_not"] integerValue] == 2)
          [cell addSubview:pLbl];
        
        
        UILabel *nameLbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 10, 200, 40)];
        nameLbl.text = chatListArray[indexPath.row][@"facebook_name"];
        nameLbl.font = [UIFont systemFontOfSize:18];
        [cell addSubview:nameLbl];
        
        UILabel *lastChatLbl = [[UILabel alloc] initWithFrame:CGRectMake(100, 45, 200, 20)];
        lastChatLbl.text = chatListArray[indexPath.row][@"last_message"];
        lastChatLbl.textColor = [UIColor grayColor];
        lastChatLbl.font = [UIFont systemFontOfSize:13];
        [cell addSubview:lastChatLbl];
        
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ChatViewController *sub = [[ChatViewController alloc] init];
    sub.userInfo = chatListArray[indexPath.row];
    sub.senderId = [userdefault objectForKey:@"pimba_fbId"];
    sub.senderDisplayName = @" ";
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];
}
- (void)tapNewUser:(UIGestureRecognizer*)tap{
    NSInteger idx = tap.view.tag;
    ChatViewController *sub = [[ChatViewController alloc] init];
    sub.userInfo = newMatchArray[idx - 2000];
    sub.senderId = [userdefault objectForKey:@"pimba_fbId"];
    sub.senderDisplayName = @" ";
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
    [self presentViewController:nav
                       animated:YES
                     completion:nil];

}
@end
