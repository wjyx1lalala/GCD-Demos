//
//  GCDController.m
//  GCDTest
//
//  Created by wjyx on 2018/12/17.
//  Copyright © 2018 nuomi. All rights reserved.
//

#import "GCDController.h"

@interface GCDController ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic,strong) UITableView * tableView;
@property (nonatomic,strong) NSArray * list;

@end

@implementation GCDController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"GCD-Demos";
    self.list = @[
      @{@"title":@"DISPATCH_QUEUE_SERIAL",@"vc":@"GCDQueueController"},
      @{@"title":@"DISPATCH_QUEUE_CONCURRENT",@"vc":@"GCDQueueController"},
      @{@"title":@"dispatch_sync",@"vc":@"GCDQueueController"},
      @{@"title":@"dispatch_async",@"vc":@"GCDQueueController"},
      @{@"title":@"dispatch_once",@"vc":@"GCDQueueController"},
      @{@"title":@"dispatch_after",@"vc":@"GCDQueueController"},
      @{@"title":@"dispatch_group_t",@"vc":@"GCDGroupController"},
      ];
    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 55;
    self.tableView.tableFooterView = [UIView new];
    [self.view addSubview:self.tableView];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    Class vcClass = NSClassFromString(self.list[indexPath.row][@"vc"]);
    if (!vcClass) return;
    UIViewController * vc = [[vcClass alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identifier = @"GCDCellIdentifier";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    NSString * title = self.list[indexPath.row][@"title"];
    cell.textLabel.text = title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}



@end
