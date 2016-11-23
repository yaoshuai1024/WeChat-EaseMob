//
//  HMContatViewController.h
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HMContatViewController : UITableViewController

/**
 从环信服务器读取数据(实现开发中应该依赖自己服务器的好友关系)
 */
- (void)readContactsFromServer;

@end
