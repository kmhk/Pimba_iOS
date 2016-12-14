//
//  FBLoginHandler.h
//  FBShareSample
//
//  Created by Surender Rathore on 17/12/13.
//  Copyright (c) 2013 Facebook Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
@protocol FBLoginHandlerDelegate <NSObject>
@optional
-(void)didFacebookUserLogin:(BOOL)login withDetail:(NSDictionary*)userInfo;
-(void)didFacebookUserLogout:(BOOL)logout;
-(void)didFacebookUserLoginFail;
@end
@interface FBLoginHandler : UIView
@property(nonatomic,strong)id<FBLoginHandlerDelegate> delegate;
+ (id)sharedInstance;
-(void)loginWithFacebook;
-(void)updateFacebookSessionwithblock:(void (^)(BOOL succeeded, NSError *error))completionBlock;;
-(void)logoutFacebookUser;
-(void)requestForNewPermission:(NSArray*)permission;
@end
