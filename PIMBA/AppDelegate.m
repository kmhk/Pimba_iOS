//
//  AppDelegate.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "AppDelegate.h"
#import "LoginViewController.h"
#import "FBLoginHandler.h"
#import "ICSDrawerController.h"
#import "MenuViewController.h"
#import "FindPeopleViewController.h"
#import "ChatViewController.h"
#import <AFNetworking/AFNetworking.h>
#import "Constant.h"
#import <AudioToolbox/AudioToolbox.h>
#import <CRToast/CRToast.h>
@interface AppDelegate ()
{
    CLLocationManager *locationManager;
    
    BOOL getPushBackground;
    NSDictionary *apsInfo;
}
@end

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBSession.activeSession handleOpenURL:url];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }
    
    [CRToastManager setDefaultOptions:@{kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastFontKey             : [UIFont fontWithName:@"HelveticaNeue-Light" size:16],
                                        kCRToastTextColorKey        : [UIColor whiteColor],
                                        kCRToastBackgroundColorKey  : [UIColor orangeColor],
                                        kCRToastAutorotateKey       : @(YES)}];

    application.applicationSupportsShakeToEdit = YES;
    
    self.locationTracker = [[LocationTracker alloc]init];
    [self.locationTracker startLocationTracking];
    
    NSTimeInterval time = 60.0;
    self.locationUpdateTimer =
    [NSTimer scheduledTimerWithTimeInterval:time
                                     target:self
                                   selector:@selector(updateLocation)
                                   userInfo:nil
                                    repeats:YES];
    
    FBLoginHandler *fbHandler = [[FBLoginHandler alloc] init];
    [fbHandler updateFacebookSessionwithblock:^(BOOL successed , NSError *error)
     {
         
     }];
    
    NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    apsInfo = [userInfo objectForKey:@"aps"];
    
    [self replaceRootViewController];
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}
- (void)replaceRootViewController{
    if([userdefault objectForKey:@"pimba_fbId"] == nil){
        LoginViewController *sub = [[LoginViewController alloc] init];
        self.window.rootViewController = sub;
    }
    else{
        MenuViewController *menuV = [[MenuViewController alloc] init];
        FindPeopleViewController *plainColorVC = [[FindPeopleViewController alloc] init];
        if([apsInfo[@"notification_type"] integerValue] == 4) plainColorVC.pushInfo = apsInfo;
        ICSDrawerController *drawer = [[ICSDrawerController alloc] initWithLeftViewController:menuV
                                                                         centerViewController:plainColorVC];
        self.window.rootViewController = drawer;
        
        
    }
}
-(void)updateLocation {
    NSLog(@"updateLocation");
    
    [self.locationTracker updateLocationToServer];
}
- (void) updatePushToken{
    /*token_update
     
     •	facebook_id
     •	token
     •	device_type
     */
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"token":[userdefault objectForKey:@"pimba_push_token"],
                                 @"device_type":@"iOS"};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"token_update"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *task, id responseObject) {
        
        NSLog(@"token_update: %@", responseObject);
        
    } failure:^(AFHTTPRequestOperation *task, NSError *error) {
        NSLog(@"Error: %@", error);
        
    }];
    
}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {    
    
    NSString *dt = [[deviceToken description] stringByTrimmingCharactersInSet:
                    [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    dt = [dt stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:dt forKey:@"pimba_push_token"];
    NSLog(@"My push_token is:%@",dt);
    if([userdefault objectForKey:@"pimba_fbId"] != nil) [self updatePushToken];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    
    NSLog(@"Failed to get token, error: %@", err);
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"pimba_push_token" forKey:@"pimba_push_token"];
    
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    /*•	1 ->  Matched!
     •	2 -> A super Like you!
     •	3 -> A vote you!
     •	4 -> chat message!
     •	5 -> A confirm your vote!
     •	6 -> onfire!
     */
    NSLog(@"push = %@",userInfo[@"aps"]);
    
    if([userInfo[@"aps"][@"notification_type"] integerValue] == 1)//Match
    {
        if(![[userdefault objectForKey:kFindPeopleWindow]  isEqual: Yes])
            [CRToastManager showNotificationWithOptions:[self options:userInfo[@"aps"]]
                                         apperanceBlock:^(void) {
                                             NSLog(@"Appeared");
                                         }
                                        completionBlock:^(void) {
                                            NSLog(@"Completed");
                                        }];
        else{
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MatchNotification" object:nil userInfo:userInfo[@"aps"]];
        }
    }
    if([userInfo[@"aps"][@"notification_type"] integerValue] == 2 || [userInfo[@"aps"][@"notification_type"] integerValue] == 3 || [userInfo[@"aps"][@"notification_type"] integerValue] == 5 || [userInfo[@"aps"][@"notification_type"] integerValue] == 6)//Super like
    {
        if(!getPushBackground)
            [CRToastManager showNotificationWithOptions:[self options:userInfo[@"aps"]]
                                     apperanceBlock:^(void) {
                                         NSLog(@"Appeared");
                                     }
                                    completionBlock:^(void) {
                                        NSLog(@"Completed");
                                    }];
    }
    if([userInfo[@"aps"][@"notification_type"] integerValue] == 4)//chat
    {
        
        if(getPushBackground && [userdefault objectForKey:@"pimba_fbId"] != nil){
            ChatViewController *sub = [[ChatViewController alloc] init];
            sub.userInfo = userInfo[@"aps"][@"profile_info"];
            sub.userName = userInfo[@"aps"][@"sender_facebook_name"];//userInfo[@"aps"][@"facebook_name"];
            
            sub.senderId = [userdefault objectForKey:@"pimba_fbId"];
            sub.senderDisplayName = @" ";
            
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:sub];
            
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }
        if(!getPushBackground){
            if(![[userdefault objectForKey:@"sound_pimba"]  isEqual: @"2"]){
                SystemSoundID completeSound;
                NSURL *audioPath = [[NSBundle mainBundle] URLForResource:@"message-recevied" withExtension:@"mp3"];
                AudioServicesCreateSystemSoundID((__bridge CFURLRef)audioPath, &completeSound);
                AudioServicesPlaySystemSound (completeSound);
            }
            

            [[NSNotificationCenter defaultCenter] postNotificationName:@"ChattingNotification" object:nil userInfo:userInfo[@"aps"]];
            if(![[userdefault objectForKey:kChatWindow]  isEqual: Yes])
                [CRToastManager showNotificationWithOptions:[self options:userInfo[@"aps"]]
                                         apperanceBlock:^(void) {
                                             NSLog(@"Appeared");
                                         }
                                        completionBlock:^(void) {
                                            NSLog(@"Completed");
                                        }];

        }
        
    }
    
    
}
- (NSDictionary*)options:(NSDictionary*)info{
    
    
    /*•	1  ->  Matched!
     •	2 -> A super Like you!
     •	3 -> A vote you!
     •	5 -> A confirm your vote!
     •	4 -> chat message!
     •	6 -> onfire!
     */
    NSString *title, *messge;
    UIImage *iconImg;
    if([info[@"notification_type"] integerValue] == 1){
        title = @"Congratulations!";
        messge = [NSString stringWithFormat:@"You and %@ are PIMBADA.", info[@"sender_facebook_name"]];
        iconImg = [UIImage imageNamed:@"alert_icon.png"];
    }
    else if([info[@"notification_type"] integerValue] == 2){
        title = @"Super Pimba!";
        messge = [NSString stringWithFormat:@"%@ did Super PIMBA to you.", info[@"sender_facebook_name"]];
        iconImg = [UIImage imageNamed:@"alert_icon.png"];
    }
    else if([info[@"notification_type"] integerValue] == 3){
        title = [NSString stringWithFormat:@"%@ vote you.", info[@"sender_facebook_name"]];
        messge = @"Please confirm the vote";
        iconImg = [UIImage imageNamed:@"alert_icon.png"];
    }
    else if([info[@"notification_type"] integerValue] == 4){
        
        title = [NSString stringWithFormat:@"Message from %@", info[@"sender_facebook_name"]];
        messge = [NSString stringWithFormat:@"%@", info[@"message_content"]];;
        iconImg = [UIImage imageNamed:@"alert_icon.png"];

    }
    else if([info[@"notification_type"] integerValue] == 5){
        title = [NSString stringWithFormat:@"%@ confirm your vote", info[@"sender_facebook_name"]];
        messge = @"Please confirm the vote";
        iconImg = [UIImage imageNamed:@"alert_icon.png"];
    }
    else if([info[@"notification_type"] integerValue] == 6){
        title = [NSString stringWithFormat:@"%@ is on fire'", info[@"sender_facebook_name"]];
        messge = @"Hello, Please help me";
        iconImg = [UIImage imageNamed:@"alert_icon.png"];
    }
    
    NSMutableDictionary *options = [@{kCRToastNotificationTypeKey               : @(CRToastTypeNavigationBar),
                                      kCRToastNotificationPresentationTypeKey   : @(CRToastPresentationTypeCover),
                                      kCRToastUnderStatusBarKey                 : @(YES),
                                      kCRToastTextKey                           : title,
                                      kCRToastTextAlignmentKey                  : @(NSTextAlignmentLeft),
                                      kCRToastTimeIntervalKey                   : @(2),
                                      kCRToastAnimationInTypeKey                : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey               : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationInDirectionKey           : @(0),
                                      kCRToastAnimationOutDirectionKey          : @(0),
                                      kCRToastNotificationPreferredPaddingKey   : @(0),
                                      kCRToastSubtitleTextKey                   : messge,
                                      kCRToastSubtitleTextAlignmentKey          : @(NSTextAlignmentLeft),
                                      kCRToastImageKey                          : iconImg
                                      } mutableCopy];
    return options;

}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    getPushBackground = YES;
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    getPushBackground = NO;
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [userdefault setObject:nil forKey:kFindPeopleWindow];
    [userdefault setObject:nil forKey:kChatWindow];
    [userdefault setObject:nil forKey:@"on_fire"];
}

@end
