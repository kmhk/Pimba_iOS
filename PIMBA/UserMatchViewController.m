//
//  UserMatchViewController.m
//  PIMBA
//
//  Created by herocules on 3/1/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "UserMatchViewController.h"
#import <AFNetworking/UIKit+AFNetworking.h>
#import "Constant.h"
@interface UserMatchViewController ()

@end

@implementation UserMatchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 
    [self displayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) displayView{
    
    mePhoto_imgview.layer.cornerRadius = mePhoto_imgview.frame.size.height/2;
    mePhoto_imgview.layer.borderWidth = 4;
    mePhoto_imgview.layer.borderColor = image_borderColor.CGColor;
    
    otherPhoto_imgview.layer.cornerRadius = mePhoto_imgview.frame.size.height/2;
    otherPhoto_imgview.layer.borderWidth = 4;
    otherPhoto_imgview.layer.borderColor = image_borderColor.CGColor;

    note_lbl.text = [NSString stringWithFormat:@"Congratulations!\nYou and %@ make a PIMBA\nin the same time.", self.userInfo[@"sender_facebook_name"]];
    
    NSDictionary *userInfo = [userdefault objectForKey:@"pimba_profile" ];
    [mePhoto_imgview setImageWithURL:[NSURL URLWithString:userInfo[@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    [otherPhoto_imgview setImageWithURL:[NSURL URLWithString:self.userInfo[@"other_profile_info"][@"profile_image"][0][@"profile_image"]] placeholderImage:profile_default];
    [talk_bttn setTitle:[NSString stringWithFormat:@"Talk to %@",self.userInfo[@"sender_facebook_name"]] forState:UIControlStateNormal];
}

- (IBAction)click_talkBttn:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PIMBADANotification"
                                                        object:nil userInfo:@{@"type":@"1",
                                                                              @"userInfo":self.userInfo[@"other_profile_info"]}];

}

- (IBAction)click_continueBttn:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PIMBADANotification" object:nil userInfo:@{@"type":@"2"}];

}
@end
