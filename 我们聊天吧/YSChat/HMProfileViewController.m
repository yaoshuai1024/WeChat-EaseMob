//
//  HMProfileTableViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMProfileViewController.h"

@interface HMProfileViewController ()<UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation HMProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameLabel.text = [EMClient sharedClient].currentUsername;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 临时拿相册做实验，设置推送配置
    if(indexPath.section == 1 && indexPath.row == 0){
        
        EMError *error = nil;
        EMPushOptions *options = [[EMClient sharedClient] getPushOptionsFromServerWithError:&error];
        
        options.displayName = @"小强";
        options.displayStyle = EMPushDisplayStyleMessageSummary;
        options.noDisturbStatus = EMPushNoDisturbStatusClose;
        
        [[EMClient sharedClient] updatePushOptionsToServer];
        [[EMClient sharedClient] setApnsNickname:@"我们聊天吧"];
        
        NSLog(@"推送配置设置成功");
    }
}

@end
