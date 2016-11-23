//
//  HMSettingsViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMSettingsViewController.h"

@interface HMSettingsViewController ()

@end

@implementation HMSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 3 && indexPath.row == 0){
        EMError *error = [[EMClient sharedClient] logout:YES];
        if (!error) {
            NSLog(@"退出成功");
            UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            [[UIApplication sharedApplication].delegate window].rootViewController = [mainSB instantiateViewControllerWithIdentifier:@"HMLogin"];
        }
    }
}

@end
