//
//  Constant.h
//  PIMBA
//
//  Created by herocules on 2/27/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#define base_url @"http://162.243.87.54/API/pimba_api.php/"

//foursquare API
#define CLIENT_ID @"QC0DIPX51IKUKKBGGHV0XG1G3SF5L2QB4SGFO3F1QURIT0OI"
#define CLIENT_SECRET @"CQ2SDHYTJRLQQKNFY2JIAUOZULFJSGIJCA4IE0LXA41J00HN"
#define foursquare_url @"https://api.foursquare.com/v2/venues/search"


#define moodArray @[@"Romance/Relationship",@"Just fun",@"Casual date",@"Party",@"I want to drink to not remember what happened."]
#define selectMoodArray @[@"Romance/Relationship", @"Just fun", @"Casual date",@"Party",@"I want to drink to not remember what happened.", @"All"]
#define genderArray @[@"Only Men", @"Only Women", @"Men and Women"]


#define action_refresh @"1"
#define action_dislike @"2"
#define action_like @"3"
#define action_SP @"4"

#define pieChartColor_array @[[UIColor grayColor],[UIColor lightGrayColor]]

#define profile_default [UIImage imageNamed:@"default-profile"]
#define image_borderColor [UIColor colorWithRed:0/255 green:81.f/255 blue:162.f/255 alpha:1.0]

/// effect sound
#define message_recevied @"message-recevied.aiff"
#define message_send @"message-send.aiff"
#define findPeople @"findPeople.aiff"
#define swap @"swap.aiff"

///
#define Yes @"yes"
#define No @"no"

/// window key
#define kChatWindow @"kChatWindow"
#define kFindPeopleWindow @"kFindPeopleWindow"

#define ShowNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = YES
#define HideNetworkActivityIndicator() [UIApplication sharedApplication].networkActivityIndicatorVisible = NO

#define userdefault [NSUserDefaults standardUserDefaults]

#endif /* Constant_h */
