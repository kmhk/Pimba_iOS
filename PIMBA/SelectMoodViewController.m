//
//  SelectMoodViewController.m
//  PIMBA
//
//  Created by herocules on 2/27/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "SelectMoodViewController.h"
#import "Constant.h"
@interface SelectMoodViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *moodTalbeView;
    
    
}
@end

@implementation SelectMoodViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Select";
    self.navigationController.navigationBar.hidden = false;
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] init];
    barButton.title = @"Back";
    self.navigationController.navigationBar.topItem.backBarButtonItem = barButton;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
    if(self.moodStr == nil) self.navigationItem.rightBarButtonItem.enabled = false;
    moodTalbeView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    moodTalbeView.delegate = self;
    moodTalbeView.dataSource = self;
    [self.view addSubview:moodTalbeView];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)Done{
    [self.navigationController popViewControllerAnimated:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectMood" object:self userInfo:@{@"mood":self.moodStr}];
}

- (void)viewWillDisappear:(BOOL)animated{
    self.navigationController.navigationBar.hidden = YES;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [moodArray count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UILabel *title_lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 50)];
    title_lbl.numberOfLines = 2;
    title_lbl.text = [moodArray objectAtIndex:indexPath.row];
    [cell addSubview:title_lbl];
    
    if([title_lbl.text isEqual:self.moodStr]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else cell.accessoryType = UITableViewCellAccessoryNone;
  
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.moodStr = [moodArray objectAtIndex:indexPath.row];
    [moodTalbeView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = true;
}

@end
