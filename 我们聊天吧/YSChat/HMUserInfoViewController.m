//
//  HMUserInfoViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMUserInfoViewController.h"
#import "HMChatDetailViewController.h"

@interface HMUserInfoViewController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@end

@implementation HMUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.userNameLabel.text = self.userName;
}

#pragma mark - 发送消息
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HMChatDetailViewController *chatVC = segue.destinationViewController;
    chatVC.userName = self.userName;
}

@end
