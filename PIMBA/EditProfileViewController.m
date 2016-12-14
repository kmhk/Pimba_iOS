//
//  EditProfileViewController.m
//  PIMBA
//
//  Created by herocules on 3/23/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "EditProfileViewController.h"
#import "ProfileImageTableViewCell.h"
#import "Constant.h"
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/UIKit+AFNetworking.h>
#import <SVProgressHUD-0.8.1/SVProgressHUD.h>
#import "SelectMoodViewController.h"
#import "ChangeGenderTableViewController.h"
@interface EditProfileViewController ()<UITextFieldDelegate, UITextViewDelegate>
{
    NSMutableArray *itemArray;
    
    UITextView *txtvw;
    
    CGRect originFrm;
    BOOL contain;
    CGPoint startPoint;
    CGPoint originPoint;
    
    BOOL inAnimation;
    NSMutableArray *profileImg_array;
}
@end

@implementation EditProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    itemArray = [NSMutableArray new];
    profileImg_array = [[NSMutableArray alloc] initWithArray:self.profileInfo[@"profile_image"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectMood:) name:@"selectMood" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeGender:) name:@"changeGender" object:nil];
    NSLog(@"self profile : %@", self.profileInfo);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 5;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 1;
    }
    else return 30;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 0) return 245;
    else if (indexPath.section == 3){
        UITextView *txtView = [[UITextView alloc] initWithFrame:CGRectMake(18, 8, [UIScreen mainScreen].bounds.size.width - 40, 56)];
        txtView.text = self.profileInfo[@"description"];
        txtView.font = [UIFont systemFontOfSize:17];
        [txtView sizeToFit];
        return txtView.frame.size.height + 14;
    }
    else return 56;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return 1;
    else return 1;
    
    
}
- (nullable NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(section == 1) return @"Studies in";
    else if (section == 2) return @"How am I today?";
    else if (section == 3) return @"Description";
    else if (section == 4) return @"Gender";
    
    return nil;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        static NSString *CellIdentifier = @"ProfileImageTableViewCell";
        ProfileImageTableViewCell *cell = (ProfileImageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        cell = [[[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil] objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.img1_contentView.layer.cornerRadius = 10;
        cell.img1_view.layer.cornerRadius = 10;
        cell.idx1_lbl.text = @"1";
        cell.img1_contentView.tag = 0;
        cell.cancel1_bttn.layer.cornerRadius = cell.cancel1_bttn.frame.size.height/2;
        
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImg:)];
        tap1.numberOfTapsRequired = 1;
        [cell.img1_contentView addGestureRecognizer:tap1];
        
        cell.img2_contentView.layer.cornerRadius = 10;
        cell.img2_view.layer.cornerRadius = 10;
        cell.idx2_lbl.text = @"2";
        cell.img2_contentView.tag = 1;
        cell.cancel2_bttn.layer.cornerRadius = cell.cancel2_bttn.frame.size.height/2;
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImg:)];
        tap2.numberOfTapsRequired = 1;
        [cell.img2_contentView addGestureRecognizer:tap2];
        
        cell.img3_contentView.layer.cornerRadius = 10;
        cell.img3_view.layer.cornerRadius = 10;
        cell.idx3_lbl.text = @"3";
        cell.img3_contentView.tag = 2;
        cell.cancel3_bttn.layer.cornerRadius = cell.cancel3_bttn.frame.size.height/2;
        UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImg:)];
        tap3.numberOfTapsRequired = 1;
        [cell.img3_contentView addGestureRecognizer:tap3];

        
        cell.img4_contentView.layer.cornerRadius = 10;
        cell.img4_view.layer.cornerRadius = 10;
        cell.idx4_lbl.text = @"4";
        cell.img4_contentView.tag = 3;
        cell.cancel4_bttn.layer.cornerRadius = cell.cancel4_bttn.frame.size.height/2;
        UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapProfileImg:)];
        tap4.numberOfTapsRequired = 1;
        [cell.img4_contentView addGestureRecognizer:tap4];
        
        if(inAnimation) return cell;
        
        itemArray = [NSMutableArray new];
        for (int i = 0; i < profileImg_array.count; i++)
        {
            if(i == 0){
                if([profileImg_array[i][@"profile_image"] isKindOfClass:[NSString class]])
                    [cell.img1_view setImageWithURL:[NSURL URLWithString:profileImg_array[i][@"profile_image"]] placeholderImage:nil];
                else if ([profileImg_array[i][@"profile_image"] isKindOfClass:[UIImage class]])
                    cell.img1_view.image = profileImg_array[i][@"profile_image"];
                [cell.cancel1_bttn setTitle:@"❌" forState:UIControlStateNormal];
                [cell.cancel1_bttn setBackgroundColor:[UIColor whiteColor]];
                
                
                [itemArray addObject:cell.img1_contentView];
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
                [cell.img1_contentView addGestureRecognizer:longGesture];
                
            }
            else if(i == 1){
                if([profileImg_array[i][@"profile_image"] isKindOfClass:[NSString class]])
                    [cell.img2_view setImageWithURL:[NSURL URLWithString:profileImg_array[i][@"profile_image"]] placeholderImage:nil];
                else if ([profileImg_array[i][@"profile_image"] isKindOfClass:[UIImage class]])
                    cell.img2_view.image = profileImg_array[i][@"profile_image"];
               
                [cell.cancel2_bttn setTitle:@"❌" forState:UIControlStateNormal];
                [cell.cancel2_bttn setBackgroundColor:[UIColor whiteColor]];
                
                
                [itemArray addObject:cell.img2_contentView];
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
                [cell.img2_contentView addGestureRecognizer:longGesture];
                
                

            }
            else if(i == 2){
                if([profileImg_array[i][@"profile_image"] isKindOfClass:[NSString class]])
                    [cell.img3_view setImageWithURL:[NSURL URLWithString:profileImg_array[i][@"profile_image"]] placeholderImage:nil];
                else if ([profileImg_array[i][@"profile_image"] isKindOfClass:[UIImage class]])
                    cell.img3_view.image = profileImg_array[i][@"profile_image"];
                
                [cell.cancel3_bttn setTitle:@"❌" forState:UIControlStateNormal];
                [cell.cancel3_bttn setBackgroundColor:[UIColor whiteColor]];
                [itemArray addObject:cell.img3_contentView];
                
                
                
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
                [cell.img3_contentView addGestureRecognizer:longGesture];
                
               
            }
            else if(i == 3){
                if([profileImg_array[i][@"profile_image"] isKindOfClass:[NSString class]])
                    [cell.img4_view setImageWithURL:[NSURL URLWithString:profileImg_array[i][@"profile_image"]] placeholderImage:nil];
                else if ([profileImg_array[i][@"profile_image"] isKindOfClass:[UIImage class]])
                    cell.img4_view.image = profileImg_array[i][@"profile_image"];
                
                [cell.cancel4_bttn setTitle:@"❌" forState:UIControlStateNormal];
                [cell.cancel4_bttn setBackgroundColor:[UIColor whiteColor]];
                
                
                [itemArray addObject:cell.img4_contentView];
                UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(buttonLongPressed:)];
                [cell.img4_contentView addGestureRecognizer:longGesture];
                
               

            }
        }
        
        
        return cell;
    }
    else if(indexPath.section == 1){
        static NSString *cellIdentifier = @"CEll1";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        UITextField *txtfld = [[UITextField alloc] initWithFrame:CGRectMake(18, 0, [UIScreen mainScreen].bounds.size.width - 40, 56)];
        txtfld.text = self.profileInfo[@"studies_in"];
        txtfld.delegate = self;
        [cell addSubview:txtfld];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 2){
        static NSString *cellIdentifier = @"CEll2";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
        cell.textLabel.text = moodArray[[self.profileInfo[@"mood_today"] integerValue] -1];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else if(indexPath.section == 3){
        static NSString *cellIdentifier = @"CEll3";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
            txtvw = [[UITextView alloc] initWithFrame:CGRectMake(14, 8, [UIScreen mainScreen].bounds.size.width - 30, cell.frame.size.height)];
            txtvw.backgroundColor = [UIColor clearColor];
            txtvw.delegate = self;
            txtvw.scrollEnabled = false;
            txtvw.showsHorizontalScrollIndicator = false;
            txtvw.showsVerticalScrollIndicator = false;
            txtvw.font = [UIFont systemFontOfSize:17];
            txtvw.textColor = [UIColor darkGrayColor];
            
            txtvw.text = self.profileInfo[@"description"];
            [txtvw sizeToFit];
            CGRect frm = txtvw.frame;
            frm.size.width = [UIScreen mainScreen].bounds.size.width - 40;
            //   frm.size.height = cell.frame.size.height;
            txtvw.frame = frm;
            
            [cell addSubview:txtvw];
        }
        
        
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else if(indexPath.section == 4){
        static NSString *cellIdentifier = @"CEll4";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        if([self.profileInfo[@"sex"] integerValue] == 2) cell.textLabel.text = @"Woman";
        else cell.textLabel.text = @"Man";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        return cell;
    }
    else{
        static NSString *cellIdentifier = @"CEll5";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        
       
        return cell;

    }
    
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(indexPath.section == 2){
        SelectMoodViewController *sub = [[SelectMoodViewController alloc] init];
        sub.moodStr = moodArray[[self.profileInfo[@"mood_today"] integerValue] - 1];
        [self.navigationController pushViewController:sub animated:YES];
    }
    if(indexPath.section == 4){
        ChangeGenderTableViewController *sub = [[ChangeGenderTableViewController alloc] init];
        if([self.profileInfo[@"sex"] integerValue] == 2) sub.genderStr = @"Woman";
        else sub.genderStr = @"Man";
        
        [self.navigationController pushViewController:sub animated:YES];

    }
}
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self.profileInfo setObject:textField.text forKey:@"studies_in"];
    return YES;
}
- (void)textFieldDidEndEditing:(UITextField *)textField{
    [self.profileInfo setObject:textField.text forKey:@"studies_in"];
}
- (void)textViewDidChange:(UITextView *)textView
{
    [UserTableView beginUpdates];
    [self.profileInfo setObject:textView.text forKey:@"description"];
    txtvw.text = self.profileInfo[@"description"];
    [txtvw sizeToFit];
    CGRect frm = txtvw.frame;
    frm.size.width = [UIScreen mainScreen].bounds.size.width - 40;
    //   frm.size.height = cell.frame.size.height;
    txtvw.frame = frm;
    [UserTableView endUpdates];
//    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:3];
//    [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationNone];
}
- (void)selectMood:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSString *str = userInfo[@"mood"];
    [self.profileInfo setObject:[NSString stringWithFormat:@"%lu", [moodArray indexOfObject:str]+1] forKey:@"mood_today"];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:2];
    [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationAutomatic];

}
- (void)changeGender:(NSNotification*)noti{
    NSDictionary *userInfo = noti.userInfo;
    NSString *str = userInfo[@"gender"];
    NSArray *sexArray = @[@"Man", @"Woman"];
    [self.profileInfo setObject:[NSString stringWithFormat:@"%lu", [sexArray indexOfObject:str]+1] forKey:@"sex"];
    
    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:4];
    [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
}
- (void)buttonLongPressed:(UILongPressGestureRecognizer *)sender
{
    
    UIView *originView = (UIView *)sender.view;
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"start");
        originFrm = originView.frame;
        originPoint = originView.center;
        
        CGRect frm = originView.frame;
        frm.size = CGSizeMake(68, 68);
        originView.frame = frm;
        originView.center = originPoint;
        
        startPoint = [sender locationInView:sender.view];
        [UserTableView bringSubviewToFront:originView];
        [UIView animateWithDuration:0.2 animations:^{
            
            
            
         //   btn.transform = CGAffineTransformMakeScale(1.1, 1.1);
            originView.alpha = 0.7;
        }];
        
    }
    else if (sender.state == UIGestureRecognizerStateChanged)
    {
        
        CGPoint newPoint = [sender locationInView:sender.view];
        CGFloat deltaX = newPoint.x-startPoint.x;
        CGFloat deltaY = newPoint.y-startPoint.y;
        originView.center = CGPointMake(originView.center.x+deltaX,originView.center.y+deltaY);
        //NSLog(@"center = %@",NSStringFromCGPoint(btn.center));
        NSInteger index = [self indexOfPoint:originView.center withButton:originView];
        if (index<0)
        {
            contain = NO;
        }
        else
        {
            NSLog(@"change %ld", (long)index);
            [UIView animateWithDuration:0.2 animations:^{
                
                CGPoint sndCenter = CGPointZero;
                
                UIView *sndView = itemArray[index];//other view
                
                
            //    CGRect sndFrm = sndView.frame;
                sndCenter = sndView.center;
                
             //   sndView.frame = originFrm;
                sndView.center = originPoint;
                
            //    if(index == 0) originView.frame = sndFrm;
                originView.center = sndCenter;
                
                
           //     originFrm = originView.frame;
                originPoint = originView.center;
                
                
                contain = YES;
                
                
                
            
            }completion:^(BOOL finish){
                NSDictionary *tmpDic1 = profileImg_array[index];
                NSDictionary *tmpDic2 = profileImg_array[originView.tag];
                [profileImg_array replaceObjectAtIndex:index withObject:tmpDic2];
                [profileImg_array replaceObjectAtIndex:originView.tag withObject:tmpDic1];
                
                
            }];
        }
        
        
    }
    else if (sender.state == UIGestureRecognizerStateEnded)
    {
         NSLog(@"end");
        [UIView animateWithDuration:0.2 animations:^{
            
            originView.transform = CGAffineTransformIdentity;
            originView.alpha = 1.0;
            if (!contain)
            {
                originView.center = originPoint;
                
                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];                
                [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
    }
}


- (NSInteger)indexOfPoint:(CGPoint)point withButton:(UIView *)btn
{
    for (NSInteger i = 0;i<itemArray.count;i++)
    {
        UIView *button = itemArray[i];
        if (button != btn)
        {
            if (CGRectContainsPoint(button.frame, point))
            {
                return i;
                
            }
        }
    }
    return -1;
}

- (void)tapProfileImg:(UIGestureRecognizer*)tap{
    UIView *vw = tap.view;
    if(vw.tag < profileImg_array.count){
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                             destructiveButtonTitle:@"Delete"
                                                  otherButtonTitles:nil];
        sheet.delegate = self;
        sheet.tag = 2000+vw.tag;
        [sheet showInView:self.view];
    }
    else{
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Choose from Camera Roll", nil];
        actionSheet.tag = 1002;
        actionSheet.delegate = self;
        [actionSheet showInView:self.view];
    }
    
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(actionSheet.tag == 1002){
        if(buttonIndex == 0)
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
        else if (buttonIndex == 1){
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = YES;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            
            [self presentViewController:picker animated:YES completion:NULL];
        }
    }    
    else {
        if(buttonIndex == 0)
        {
            [self deleteImage:actionSheet.tag - 2000];
            
        }
    }
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    [self addImage:chosenImage];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addImage:(UIImage*)img{
    /*add_image
     
     facebook_id
     profile_image
*/
    ShowNetworkActivityIndicator();
    [SVProgressHUD showWithStatus:@"Add Image..." maskType:SVProgressHUDMaskTypeClear];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"add_image"];
    
    [manager POST:urlStr parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSData *imgData = [[NSData alloc] init];
        imgData = UIImageJPEGRepresentation(img, 0.3);
        if(imgData != nil){
            [formData appendPartWithFileData:imgData name:@"profile_image" fileName:@"image.jpg" mimeType:@"image/jpeg"];
        }
    }
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        HideNetworkActivityIndicator();
        [SVProgressHUD dismiss];
        NSLog(@"add_image: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [profileImg_array addObject:@{@"profile_image":[responseObject objectForKey:@"photo_url"],
                                          @"unique_id":[responseObject objectForKey:@"unique_id"]}];
            
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
            [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationAutomatic];

            [self.profileInfo setObject:profileImg_array forKey:@"profile_image"];
            [userdefault setObject:self.profileInfo forKey:@"pimba_profile"];
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

- (void) deleteImage:(NSInteger)idx{
    /*delete_image
     facebook_id
     unique_id*/
    
    ShowNetworkActivityIndicator();
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"unique_id":profileImg_array[idx][@"unique_id"]};
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"delete_image"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"delete_image: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            [profileImg_array removeObjectAtIndex:idx];
            NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:0];
            [UserTableView reloadRowsAtIndexPaths:@[rowToReload] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            
            [self.profileInfo setObject:profileImg_array forKey:@"profile_image"];
            [userdefault setObject:self.profileInfo forKey:@"pimba_profile"];
            
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
    }];

}

- (void) updateProfile{
    /*update_profile	
     
        facebook_id
     	mood_today
     	studies_in
     	sex
     	description
     	unique_id1
     	unique_id2
     	unique_id3
     	unique_id4
     */
    ShowNetworkActivityIndicator();
    [self.profileInfo setObject:profileImg_array forKey:@"profile_image"];
    [userdefault setObject:self.profileInfo forKey:@"pimba_profile"];
    
    NSString *strSchool = [self.profileInfo[@"studies_in"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    NSString *strDescription = [self.profileInfo[@"description"] stringByReplacingOccurrencesOfString:@"'" withString:@"\\'"];
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithDictionary:@{@"facebook_id":[userdefault objectForKey:@"pimba_fbId"],
                                 @"mood_today":self.profileInfo[@"mood_today"],
                                 @"studies_in":strSchool,
                                 @"sex":self.profileInfo[@"sex"],
                                 @"description":strDescription}];
    for (int  i =0 ; i < profileImg_array.count; i++)
    {
        NSString *str = [NSString stringWithFormat:@"unique_id%d",i+1];
        [parameters setObject:profileImg_array[i][@"unique_id"] forKey:str];
    }
    
    NSString *urlStr = [NSString stringWithFormat:@"%@%@",base_url, @"update_profile"];
    
    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        HideNetworkActivityIndicator();
        NSLog(@"delete_image: %@", responseObject);
        if([[responseObject objectForKey:@"flag"]  isEqual: @"1"])
        {
            
            [userdefault setObject:self.profileInfo forKey:@"pimba_profile"];
            
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
    }];

    
}
- (IBAction)click_doneBttn:(id)sender {
    [self updateProfile];
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
