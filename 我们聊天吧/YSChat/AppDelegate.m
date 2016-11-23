//
//  AppDelegate.m
//  YSChat
//
//  Created by yaoshuai on 2016/11/20.
//  Copyright © 2016年 ys. All rights reserved.
//

#import "AppDelegate.h"
#import "EMSDK.h"
#import "HMContatViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<EMClientDelegate,EMContactManagerDelegate,EMChatManagerDelegate,UNUserNotificationCenterDelegate>

//好友请求数
@property (nonatomic, assign) NSInteger friendRequestCount;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //AppKey:注册的AppKey，详细见下面注释。
    //apnsCertName:推送证书名（不需要加后缀），详细见下面注释。
    EMOptions *options = [EMOptions optionsWithAppkey:@"1177161104178937#imtest"];
    options.apnsCertName = @"YSChatPushDev";
    [[EMClient sharedClient] initializeSDKWithOptions:options];
    
    
    //添加回调监听代理:
    [[EMClient sharedClient] addDelegate:self delegateQueue:nil];
    //注册好友回调
    [[EMClient sharedClient].contactManager addDelegate:self delegateQueue:nil];
    //注册消息回调
    [[EMClient sharedClient].chatManager addDelegate:self delegateQueue:nil];
    
    // 判断是否可以自动登录
    BOOL isAutoLogin = [EMClient sharedClient].options.isAutoLogin;
    if (isAutoLogin) { // 可以自动登录，修改根控制器为TabBarVC，否则为默认(登录VC)
        UIStoryboard *mainSB = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController =[mainSB instantiateViewControllerWithIdentifier:@"HMTabBar"];
    }
    
    
    [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionAlert | UNAuthorizationOptionSound completionHandler:^(BOOL granted, NSError * _Nullable error) {
        if (granted) {
            NSLog(@"授权成功");
            [UNUserNotificationCenter currentNotificationCenter].delegate = self;
            
        }else {
            NSLog(@"授权失败");
        }
        
    }];
    
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    
    return YES;
}

// 将得到的deviceToken传给SDK
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    [[EMClient sharedClient] bindDeviceToken:deviceToken];
    NSLog(@"deviceToken上传成功：%@",deviceToken);
}

// 注册deviceToken失败
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"error -- %@",error);
    NSLog(@"deviceToken上传失败");
}

// APP进入后台
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationDidEnterBackground:application];
}


// APP将要从后台返回
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[EMClient sharedClient] applicationWillEnterForeground:application];
}

#pragma mark - EMClientDelegate
/*!
 *  自动登录返回结果
 *
 *  @param aError 错误信息
 */
- (void)autoLoginDidCompleteWithError:(EMError *)aError{
    if(aError){
        NSLog(@"自动登录失败：%@",aError);
    }else{
        NSLog(@"自动登录成功");
    }
}

/*!
 *  SDK连接服务器的状态变化时会接收到该回调
 *
 *  有以下几种情况，会引起该方法的调用：
 *  1. 登录成功后，手机无法上网时，会调用该回调
 *  2. 登录成功后，网络状态变化时，会调用该回调
 *
 *  @param aConnectionState 当前状态
 */
- (void)didConnectionStateChanged:(EMConnectionState)aConnectionState{
    switch (aConnectionState) {
        case EMConnectionConnected:
            NSLog(@"已经连接");
            break;
        case EMConnectionDisconnected:
            NSLog(@"断开了连接");
            break;
        default:
            break;
    }
}

/*!
 *  当前登录账号在其它设备登录时会接收到该回调
 */
- (void)userAccountDidLoginFromOtherDevice{
    NSLog(@"当前账号已在其他设备登录");
}

/*!
 *  当前登录账号已经被从服务器端删除时会收到该回调
 */
- (void)userAccountDidRemoveFromServer{
    NSLog(@"当前账号在服务器上被删除了");
}

#pragma mark - EMContactManagerDelegate
/*!
 *  用户A发送加用户B为好友的申请，用户B会收到这个回调
 *
 *  @param aUsername   用户名
 *  @param aMessage    附属信息
 */
- (void)friendRequestDidReceiveFromUser:(NSString *)aUsername
                                message:(NSString *)aMessage{
    //接收到好友请求后,添加通讯录角标
    UITabBarController *tabBarVc = (UITabBarController *)self.window.rootViewController;
    tabBarVc.viewControllers[1].tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd", ++self.friendRequestCount];
    
    //让用户选择是否加好友
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好友请求" message:[NSString stringWithFormat:@"%@想要添加您为好友,备注:%@", aUsername, aMessage] preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //同意请求
        EMError *error = [[EMClient sharedClient].contactManager acceptInvitationForUsername:aUsername];
        if (!error) {
            NSLog(@"发送同意成功");
            //如果角标为0,则设置nil
            if (--self.friendRequestCount == 0) {
                tabBarVc.viewControllers[1].tabBarItem.badgeValue = nil;
            }else {
                tabBarVc.viewControllers[1].tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd", self.friendRequestCount];
            }
        }
        // 刷新通讯录列表
        UITabBarController *tabBarVC = self.window.rootViewController;
        HMContatViewController *contactVC = tabBarVC.viewControllers[1].childViewControllers[0];
        [contactVC readContactsFromServer];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //拒绝请求
        EMError *error = [[EMClient sharedClient].contactManager declineInvitationForUsername:aUsername];
        if (!error) {
            NSLog(@"发送拒绝成功");
            if (--self.friendRequestCount == 0) {
                tabBarVc.viewControllers[1].tabBarItem.badgeValue = nil;
            }else {
                tabBarVc.viewControllers[1].tabBarItem.badgeValue = [NSString stringWithFormat:@"%zd", self.friendRequestCount];
            }
        }
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    //进行modal展示
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
}


/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B同意后，用户A会收到这个回调
 */
- (void)friendRequestDidApproveByUser:(NSString *)aUsername{
    // 对方同意好友请求
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好友通知" message:[NSString stringWithFormat:@"%@已经成为您的好友",aUsername] preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    // 刷新通讯录列表
    UITabBarController *tabBarVC = self.window.rootViewController;
    HMContatViewController *contactVC = tabBarVC.viewControllers[1].childViewControllers[0];
    [contactVC readContactsFromServer];
    
    // 延迟销毁
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

/*!
 @method
 @brief 用户A发送加用户B为好友的申请，用户B拒绝后，用户A会收到这个回调
 */
- (void)friendRequestDidDeclineByUser:(NSString *)aUsername{
    // 对方拒绝好友请求
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"好友通知" message:[NSString stringWithFormat:@"%@拒绝成为您的好友",aUsername] preferredStyle:UIAlertControllerStyleAlert];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    
    // 延迟销毁
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [alertController dismissViewControllerAnimated:YES completion:nil];
    });
}

#pragma mark - EMChatManagerDelegate
- (void)messagesDidReceive:(NSArray *)aMessages{
    // 通知最近联系人刷新数据
    [[NSNotificationCenter defaultCenter] postNotificationName:@"YSMsgDidSendNote" object:nil userInfo:nil];
}

#pragma mark - UNUserNotificationCenterDelegate
//iOS10 应用在前台时接收到通知后会调用该方法
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler{
    NSLog(@"收到离线推送了");
}

//iOS10 应用在前台&后台&应用关闭后,点击横幅/横幅中按钮后调用
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler{
    
    NSLog(@"收到离线推送了");
}


@end
