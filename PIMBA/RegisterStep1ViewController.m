//
//  RegisterStep1ViewController.m
//  PIMBA
//
//  Created by herocules on 2/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "RegisterStep1ViewController.h"
#import "RegisterStep2ViewController.h"
#import "Constant.h"
@interface RegisterStep1ViewController ()
{
    NSMutableArray *imgArray;
    NSInteger imgIdx;
}
@end

@implementation RegisterStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    imgArray = [NSMutableArray new];
    imgIdx = -1;
    [self initviewSetting];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initviewSetting{
    profileImg_1.layer.cornerRadius = profileImg_1.frame.size.height/2;
    profileImg_1.layer.borderColor = image_borderColor.CGColor;
    profileImg_1.layer.borderWidth = 4.0f;
    
    profileImg_2.layer.cornerRadius = profileImg_2.frame.size.height/2;
    profileImg_2.layer.borderColor = image_borderColor.CGColor;
    profileImg_2.layer.borderWidth = 2.0f;
    
    profileImg_3.layer.cornerRadius = profileImg_3.frame.size.height/2;
    profileImg_3.layer.borderColor = image_borderColor.CGColor;
    profileImg_3.layer.borderWidth = 2.0f;
    
    profileImg_4.layer.cornerRadius = profileImg_4.frame.size.height/2;
    profileImg_4.layer.borderColor = image_borderColor.CGColor;
    profileImg_4.layer.borderWidth = 2.0f;
    
    welcome_lbl.text = [NSString stringWithFormat:@"Welcome %@!", self.userInfo[@"Name"]];
}

- (IBAction)click_addImgBttn:(UIButton *)sender {
    if(sender.tag - 100 <= imgArray.count){
        imgIdx = sender.tag - 100;
    }
    else imgIdx = -1;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Take a Photo" otherButtonTitles:@"Choose from Camera Roll", nil];
    actionSheet.tag = 1002;
    [actionSheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
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
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *chosenImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    if(imgIdx == -1)[imgArray addObject:chosenImage];
    else [imgArray replaceObjectAtIndex:imgIdx-1 withObject:chosenImage];
    [self setImgViews];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void) setImgViews{
    if (imgArray.count == 1) {
        profileImg_1.image = imgArray[0];
    }
    if (imgArray.count == 2) {
        profileImg_2.image = imgArray[1];
    }
    if (imgArray.count == 3) {
        profileImg_3.image = imgArray[2];
    }
    if (imgArray.count == 4) {
        profileImg_4.image = imgArray[3];
    }
}
- (IBAction)click_nextBttn:(id)sender {
    if(imgArray.count == 0) return;
    RegisterStep2ViewController *sub = [[RegisterStep2ViewController alloc] init];
    sub.imgArray = [[NSArray alloc]initWithArray:imgArray];
    sub.userInfo = self.userInfo;
    [self.navigationController pushViewController:sub animated:YES];
}
@end
