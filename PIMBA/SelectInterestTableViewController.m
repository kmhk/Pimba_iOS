//
//  SelectInterestTableViewController.m
//  PIMBA
//
//  Created by herocules on 3/4/16.
//  Copyright © 2016 herocules. All rights reserved.
//

#import "SelectInterestTableViewController.h"
#import "Constant.h"
@interface SelectInterestTableViewController ()

@end

@implementation SelectInterestTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Select";
    self.navigationController.navigationBar.hidden = false;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(Done)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)Done{
    [self.navigationController popViewControllerAnimated:YES];
    
    
    NSInteger idx = [selectMoodArray indexOfObject:self.moodStr]+1;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectInterest" object:self userInfo:@{@"mood":[NSString stringWithFormat:@"%ld", (long)idx] }];
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return selectMoodArray.count;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return  50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"CEll";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
    UILabel *title_lbl = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, self.view.frame.size.width-40, 50)];
    title_lbl.numberOfLines = 2;
    title_lbl.text = [selectMoodArray objectAtIndex:indexPath.row];
    [cell addSubview:title_lbl];
    
    if([title_lbl.text isEqual:self.moodStr]){
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    self.moodStr = [selectMoodArray objectAtIndex:indexPath.row];
    [tableView reloadData];
    self.navigationItem.rightBarButtonItem.enabled = true;
}

@end
