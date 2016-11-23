//
//  HMLoginViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMLoginViewController.h"

@interface HMLoginViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;

@end

@implementation HMLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - 注册登录事件
- (IBAction)registerAction:(id)sender {
    
    EMError *error = [[EMClient sharedClient] registerWithUsername:self.accountTF.text password:self.passwordTF.text];
    if (error==nil) {
        NSLog(@"注册成功");
    }
    
}
- (IBAction)loginAction:(id)sender {
    EMError *error = [[EMClient sharedClient] loginWithUsername:self.accountTF.text password:self.passwordTF.text];
    if (!error) {
        NSLog(@"登录成功");
        
        // 开启自动登录
        [[EMClient sharedClient].options setIsAutoLogin:YES];
    
        // 跳转根控制器
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        [[UIApplication sharedApplication].delegate window].rootViewController =[mainSB instantiateViewControllerWithIdentifier:@"HMTabBar"];
    }
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // 滚动时取消编辑
    [self.view endEditing:YES];
}

@end
