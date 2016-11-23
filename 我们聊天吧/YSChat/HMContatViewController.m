//
//  HMContatViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMContatViewController.h"
#import "HMUserInfoViewController.h"

@interface HMContatViewController ()

// 用户列表
@property(nonatomic,strong) NSArray *userList;

@end

@implementation HMContatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self readContactsFromServer];
}

/**
 从环信服务器读取数据(实现开发中应该依赖自己服务器的好友关系)
 */
- (void)readContactsFromServer{
    EMError *error = nil;
    // 取出的数组里面就是字符串格式的用户名
    NSArray *userlist = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (!error) {
        self.userList = userlist;
        [self.tableView reloadData];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.userList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"contactCell" forIndexPath:indexPath];
    
    UILabel *userLabel = [cell viewWithTag:1001];
    userLabel.text = self.userList[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        // 删除好友
        EMError *error = [[EMClient sharedClient].contactManager deleteContact:self.userList[indexPath.row]];
        if (!error) {
            NSLog(@"删除成功");
        }
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    //判断segue的标记,确定是跳聊天详情/添加联系人界面
    if ([segue.identifier isEqualToString:@"contacts"]) {
        
        //传递数据
        HMUserInfoViewController *userinfoVC = segue.destinationViewController;
        NSIndexPath *indexpath = [self.tableView indexPathForSelectedRow];
        userinfoVC.userName = self.userList[indexpath.row];
    }
}

@end
