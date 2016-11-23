//
//  HMAddContactViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMAddContactViewController.h"

@interface HMAddContactViewController ()<UITextFieldDelegate>

@end

@implementation HMAddContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 添加好友
    EMError *error = [[EMClient sharedClient].contactManager addContact:textField.text message:[NSString stringWithFormat:@"小样儿，我是三哥"]];
    if (!error) {
        NSLog(@"好友请求发送成功");
    }
    return YES;
}

@end
