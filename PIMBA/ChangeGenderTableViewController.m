//
//  ChangeGenderTableViewController.m
//  PIMBA
//
//  Created by herocules on 3/24/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "ChangeGenderTableViewController.h"

@interface ChangeGenderTableViewController ()
{
    NSArray *sexArray;
}
@end

@implementation ChangeGenderTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    sexArray = @[@"Man", @"Woman"];
    
    self.navigationItem.title = @"Select";
    self.navigationController.navigationBar.hidden = false;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
    
       
   
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)Done{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeGender" object:self userInfo:@{@"gender":self.genderStr}];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sexArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    cell.textLabel.text = sexArray[indexPath.row];
    
    if([cell.textLabel.text isEqual:self.genderStr]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.genderStr = [sexArray objectAtIndex:indexPath.row];
    [tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = true;
}


@end
