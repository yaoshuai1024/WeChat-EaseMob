//
//  HMChatDetailViewController.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "HMChatDetailViewController.h"

@interface HMChatDetailViewController ()<UITableViewDataSource,UITextFieldDelegate,EMChatManagerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 消息列表
 */
@property(nonatomic,strong) NSArray *msgList;

@end

@implementation HMChatDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.estimatedRowHeight = 200;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    //注册消息回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];

    [self readMsgFromDB];
}

- (void)dealloc{
    // 移除消息回调
    [[EMClient sharedClient].chatManager removeDelegate:self];
}

// 从本地数据库中获取消息列表
- (void)readMsgFromDB{
    // 获取会话
    EMConversation *conversation = [[EMClient sharedClient].chatManager getConversation:self.userName type:EMConversationTypeChat createIfNotExist:YES];
    // 消息检索
    // FromId：参考消息ID，为nil表示从最新消息获取
    // count：获取的条数
    // direction：向前/后获取，从参考消息ID开始计算
    [conversation loadMessagesStartFromId:nil count:100 searchDirection:EMMessageSearchDirectionUp completion:^(NSArray *aMessages, EMError *aError) {
        if(!aError){
            NSLog(@"消息检查成功");
            self.msgList = aMessages;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.msgList.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell;
    
    //解析消息  收到消息的回调，带有附件类型的消息可以用 SDK 提供的下载附件方法下载(文字消息,语音消息是直接下载,图片和视频消息需要使用手动下载的SDK进行下载)
    EMMessage *message = self.msgList[indexPath.row];
    EMMessageBody *msgBody = message.body;
    switch (msgBody.type) {
        case EMMessageBodyTypeText:
        {
            // 收到的文字消息
            EMTextMessageBody *textBody = (EMTextMessageBody *)msgBody;
            NSLog(@"%@", textBody.text);
            //判断收发情况
            switch (message.direction) {
                case EMMessageDirectionSend: //发送消息
                {
                    //获取cell
                    cell = [tableView dequeueReusableCellWithIdentifier:@"rightCell" forIndexPath:indexPath];
                    UILabel *contentLabel = [cell viewWithTag:1002];
                    contentLabel.text = textBody.text;
                    
                }
                    break;
                case EMMessageDirectionReceive: //接收消息
                {
                    //获取cell
                    cell = [tableView dequeueReusableCellWithIdentifier:@"leftCell" forIndexPath:indexPath];
                    UILabel *contentLabel = [cell viewWithTag:1002];
                    contentLabel.text = textBody.text;
                    
                }
                    break;
                    
                default:
                    break;
            }
            
        }
            break;
        case EMMessageBodyTypeImage:
        {
            // 得到一个图片消息body
            EMImageMessageBody *body = ((EMImageMessageBody *)msgBody);
            
            
            //                //下载图片的大图(该方法一般在点击图片,以大图方式进行展示时才会调用)
            //                [[EMClient sharedClient].chatManager downloadMessageAttachment:message progress:nil completion:^(EMMessage *message, EMError *error) {
            //                    if (!error) {
            //                        NSLog(@"下载成功，下载后的message是 -- %@",aMessage);
            //                    }
            //                }];
            //
            //                NSLog(@"大图的W -- %f ,大图的H -- %f",body.size.width,body.size.height);
            //                NSLog(@"大图的下载状态 -- %lu",body.downloadStatus);
            // 需要使用sdk提供的下载方法后才会存在
            //                NSLog(@"大图local路径 -- %@"    ,body.localPath);
            
            // 缩略图sdk会自动下载
            NSLog(@"小图local路径 -- %@"    ,body.thumbnailLocalPath);
            NSLog(@"小图的W -- %f ,大图的H -- %f",body.thumbnailSize.width,body.thumbnailSize.height);
            NSLog(@"小图的下载状态 -- %lu",body.thumbnailDownloadStatus);
        }
            break;
        case EMMessageBodyTypeLocation:
        {
            EMLocationMessageBody *body = (EMLocationMessageBody *)msgBody;
            NSLog(@"纬度-- %f",body.latitude);
            NSLog(@"经度-- %f",body.longitude);
            NSLog(@"地址-- %@",body.address);
        }
            break;
        case EMMessageBodyTypeVoice:
        {
            // 音频sdk会自动下载
            EMVoiceMessageBody *body = (EMVoiceMessageBody *)msgBody;
            
            NSLog(@"音频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在（音频会自动调用）
            
            NSLog(@"音频文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"音频文件的下载状态 -- %lu"   ,body.downloadStatus);
            NSLog(@"音频的时间长度 -- %lu"      ,body.duration);
        }
            break;
        case EMMessageBodyTypeVideo:
        {
            EMVideoMessageBody *body = (EMVideoMessageBody *)msgBody;
            
            NSLog(@"视频remote路径 -- %@"      ,body.remotePath);
            NSLog(@"视频local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
            NSLog(@"视频文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"视频文件的下载状态 -- %lu"   ,body.downloadStatus);
            NSLog(@"视频的时间长度 -- %lu"      ,body.duration);
            NSLog(@"视频的W -- %f ,视频的H -- %f", body.thumbnailSize.width, body.thumbnailSize.height);
            
            // 缩略图sdk会自动下载
            NSLog(@"缩略图的remote路径 -- %@"     ,body.thumbnailRemotePath);
            NSLog(@"缩略图的local路径 -- %@"      ,body.thumbnailLocalPath);
            NSLog(@"缩略图的secret -- %@"        ,body.thumbnailSecretKey);
            NSLog(@"缩略图的下载状态 -- %lu"      ,body.thumbnailDownloadStatus);
        }
            break;
        case EMMessageBodyTypeFile:
        {
            EMFileMessageBody *body = (EMFileMessageBody *)msgBody;
            NSLog(@"文件remote路径 -- %@"      ,body.remotePath);
            NSLog(@"文件local路径 -- %@"       ,body.localPath); // 需要使用sdk提供的下载方法后才会存在
            NSLog(@"文件的secret -- %@"        ,body.secretKey);
            NSLog(@"文件文件大小 -- %lld"       ,body.fileLength);
            NSLog(@"文件文件的下载状态 -- %lu"   ,body.downloadStatus);
        }
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    // 构造文本消息
    EMTextMessageBody *body = [[EMTextMessageBody alloc] initWithText:textField.text];
    NSString *from = [[EMClient sharedClient] currentUsername];
    
    //生成Message
    // 会话：保存在本地
    // 如果当前是发送者，会话ID如果不设置，默认以接收者的userName生成一组会话
    // 如果当前是接收者，会话ID如果不设置，默认是发送者的userName
    EMMessage *message = [[EMMessage alloc] initWithConversationID:nil from:from to:self.userName body:body ext:nil];
    message.chatType = EMChatTypeChat;// 设置为单聊消息
    //message.chatType = EMChatTypeGroupChat;// 设置为群聊消息
    //message.chatType = EMChatTypeChatRoom;// 设置为聊天室消息
    
    message.ext = @{@"em_force_notification":@YES};
    
    // 发送消息
    [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *aMessage, EMError *aError) {
        if(!aError){
            NSLog(@"消息发送成功");
            textField.text = nil;
            [self readMsgFromDB];
            
            // 通知最近联系人刷新数据
            [[NSNotificationCenter defaultCenter] postNotificationName:@"YSMsgDidSendNote" object:nil userInfo:nil];
        }
    }];
    
    return YES;
}

#pragma mark - EMChatManagerDelegate
/*!
 @method
 @brief 接收到一条及以上非cmd消息
 */
- (void)messagesDidReceive:(NSArray *)aMessages{
    NSLog(@"接收到消息");
    [self readMsgFromDB];
}

@end
