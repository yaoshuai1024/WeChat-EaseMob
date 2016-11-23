//
//  HMRecentViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMRecentViewController.h"
#import "HMChatDetailViewController.h"

@interface HMRecentViewController ()

/**
 会话列表
 */
@property(nonatomic,strong) NSArray<EMConversation *> *conversations;

@end

@implementation HMRecentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 监听消息已经发送的通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadConversationsFromDB) name:@"YSMsgDidSendNote" object:nil];
    
    [self reloadConversationsFromDB];
}

/**
 从数据库获取所有会话
 */
- (void)reloadConversationsFromDB{
    // 内存中有则从内存中取，没有则从db中取
    NSArray *conversations = [[EMClient sharedClient].chatManager getAllConversations];
    // 根据时间排序
    self.conversations = [conversations sortedArrayUsingComparator:^NSComparisonResult(EMConversation * _Nonnull obj1, EMConversation * _Nonnull obj2) {
        
        if(obj1.latestMessage.localTime > obj2.latestMessage.localTime){
            return NSOrderedAscending;
        }
        else{
            return NSOrderedDescending;
        }
        
    }];
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.conversations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"recentCell" forIndexPath:indexPath];
    
    EMConversation *conversation = self.conversations[indexPath.row];
    UILabel *userNameLabel = [cell viewWithTag:1002];
    userNameLabel.text = conversation.conversationId;
    
    UILabel *contentLabel = [cell viewWithTag:1003];
    EMTextMessageBody *body = (EMTextMessageBody *)conversation.latestMessage.body;
    contentLabel.text = body.text;
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HMChatDetailViewController *chatVC = segue.destinationViewController;
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    chatVC.userName = self.conversations[indexPath.row].conversationId;
}

@end
