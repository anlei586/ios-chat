//
//  AppDelegate.m
//  WildFireChat
//
//  Created by WF Chat on 2017/11/5.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//


//如果您不需要voip功能，请在ChatUIKit工程中关掉voip功能，然后这里定义WFCU_SUPPORT_VOIP为0
//ChatUIKit关闭voip的方式是，找到ChatUIKit工程下的Predefine.h头文件，定义WFCU_SUPPORT_VOIP为0，
//然后找到脚本“xcodescript.sh”，删除掉“cp -af WFChatUIKit/AVEngine/*  ${DST_DIR}/”这句话。
//在删除掉ChatUIKit工程的WebRTC和WFAVEngineKit的依赖。
//删除掉应用工程中的WebRTC.framework和WFAVEngineKit.framework。
//define WFCU_SUPPORT_VOIP 1
#define WFCU_SUPPORT_VOIP 0

#import "AppDelegate.h"
#import <WFChatClient/WFCChatClient.h>
#if WFCU_SUPPORT_VOIP
#import <WFAVEngineKit/WFAVEngineKit.h>
#endif
#import "WFCConfig.h"
#import "AppInitView.h"

#import <WFChatUIKit/WFChatUIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "CreateBarCodeViewController.h"
#import "QQLBXScanViewController.h"
#import "StyleDIY.h"
//#import <Bugly/Bugly.h>
#import "AppService.h"
#import "GroupInfoViewController.h"
#import "PCLoginConfirmViewController.h"

#import "WFCLoginViewController.h"
#import "WFCBaseTabBarController.h"

#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "WFCConfig.h"

#import "UITextViewWorkaround.h"
#import "WXUncaughtExceptionHandler.h"

#import "JPUSHService.h"
#ifdef NSFoundationVersionNumber_iOS_9_x_Max
#import <UserNotifications/UserNotifications.h>
#endif
// 如果需要使用 idfa 功能所需要引入的头文件（可选）
#import <AdSupport/AdSupport.h>

#define HexColor(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

@interface AppDelegate ()<JPUSHRegisterDelegate,JPUSHGeofenceDelegate>{
  CLLocationManager * _locationManager;

}
@end

@interface AppDelegate () <ConnectionStatusDelegate, ReceiveMessageDelegate,
#if WFCU_SUPPORT_VOIP
    WFAVEngineDelegate,
#endif
    UNUserNotificationCenterDelegate, QrCodeDelegate>
@property(nonatomic, strong) AVAudioPlayer *audioPlayer;
@property(nonatomic, strong) WFCBaseTabBarController *tabBarVC;
@property(strong, nonatomic) UIAlertAction *_okAction;
@property(strong, nonatomic) UIAlertAction *_cancelAction;
@property(strong, nonatomic) AVAudioPlayer *musicPlayer;
@property(strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation AppDelegate

static NSString *st;
static NSString *sp;
static NSString *su;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    //简单调用
    //InstanceWXUncaughtExceptionHandler();
    //链式调用 是否显示警告框 是否显示错误信息 是否回调日志地址
    InstanceWXUncaughtExceptionHandler().showAlert(YES).showErrorInfor(YES).getlogPathBlock(^(NSString *logPathStr){
        NSLog(@"程序异常日志地址 == %@",logPathStr);
    });
    
    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
      // 3.0.0及以后版本注册
      JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
      if (@available(iOS 12.0, *)) {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound|JPAuthorizationOptionProvidesAppNotificationSettings;
      } else {
        entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
      }
      if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
    //    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
    //      NSSet<UNNotificationCategory *> *categories;
    //      entity.categories = categories;
    //    }
    //    else {
    //      NSSet<UIUserNotificationCategory *> *categories;
    //      entity.categories = categories;
    //    }
      }
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:jg_appKey
                          channel:jg_channel
                 apsForProduction:1
            advertisingIdentifier:advertisingId];
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
      if(resCode == 0){
        NSLog(@"registrationID获取成功：%@",registrationID);
      }
      else{
        NSLog(@"registrationID获取失败，code：%d",resCode);
      }
    }];
    [JPUSHService removeNotification:nil];

    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.label.text = @"加载配置中...";
    [hud showAnimated:YES];
    
    
    
    AppInitView *aiv = [AppInitView alloc];
    [aiv onLoadCenterConfig:^{
        //read local cde
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *rcode = [self.userDefaults objectForKey:@"rcode"];
        if(rcode==nil && RCODE_ONF==0){
            [self.userDefaults setObject:RCODE_IDK forKey:@"rcode"];
            rcode = RCODE_IDK;
        }
        if(rcode!=nil){ //if have cache, load config
            [hud hideAnimated:YES];
            [self initApp3:application didFinishLaunchingWithOptions:launchOptions];
        }else{ // else no cache , pop win , input code, load code config,

            [aiv viewInit];
            self.window.rootViewController = [aiv init];
            [aiv onLoadCenterConfig:^{
                [self initApp3:application didFinishLaunchingWithOptions:launchOptions];
            }];
            [aiv displayChild];
            [hud hideAnimated:YES];
        }
    }];
    
    return YES;
}
    
-(BOOL)initApp3:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.window animated:YES];
    hud.label.text = @"加载配置中...";
    [hud showAnimated:YES];
    
    
    NSString *rcode = [self.userDefaults objectForKey:@"rcode"];
    if(rcode){
        //IM_SERVER_HOST
        //APP_SERVER_ADDRESS
        //APP_SERVER_PHP
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *txtPath = [docPath stringByAppendingPathComponent:@"rconfig.txt"];
        NSString *_data = [NSString stringWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];

        NSError *err;
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err){
            [self alert:@"官码JSON解析出错"];
            [self alert:_data];
        }
        
        NSString *pst;
        NSString *psp;
        NSString *psu;
        NSInteger onf = 0;
        int *len = [dict count];
        for(int i=0;i<len;i++){

            NSString *istr = [NSString stringWithFormat:@"%d",i];
            NSDictionary *larr = dict[istr];
            
            NSString *bai = larr[@"bai"];
            NSString *bid = larr[@"id"];
            if([bai isEqualToString:@"1"] && [bid isEqualToString:rcode] ){

                pst = larr[@"st"];
                psp = larr[@"sp"];
                psu = larr[@"su"];
                onf = 1;
                break;
            }
        }

        if(onf == 0){
            [self alert:@"该码已下架"];
        }else if(onf){
            NSLog(@"很好2");
        }
        
        [AppDelegate setMFS_http:pst];
        [AppDelegate setMFS_port:psp];
        [AppDelegate setMFS_url:psu];
    }
    //原旧版
    IM_SERVER_HOST = [AppDelegate getMFS_url];
    APP_SERVER_ADDRESS = [[AppDelegate getMFS_url] stringByAppendingString:@":8888"];
    APP_SERVER_ADDRESS = [@"http://" stringByAppendingString:APP_SERVER_ADDRESS];
    if([AppDelegate getMFS_port].length<=0){
        APP_SERVER_PHP = [AppDelegate getMFS_hu];
    }else{
        APP_SERVER_PHP = [[AppDelegate getMFS_hu] stringByAppendingString: @":"];
        APP_SERVER_PHP = [APP_SERVER_PHP stringByAppendingString: [AppDelegate getMFS_port]];
    }
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@", APP_SERVER_PHP, @"/yh/apiclient.php"];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud hideAnimated:YES];
            NSString *_data = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            [WFCBaseTabBarController setApiClient:dict];
            NSDictionary *dc2 = [WFCBaseTabBarController getApiClient];
            if(err){
                [self alert:@"JSON解析出错"];
                [self alert:jsonData];
            }
            
            [self initApp2:application didFinishLaunchingWithOptions:launchOptions];
        

            
     }    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            NSLog(@"--%@",error);
            //[self alert:@"加载配置出错"];
            // 初始化对话框
            UIAlertController *_alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"也许您的网络遇到了问题，请尝试切换4G或WIFI" preferredStyle:UIAlertControllerStyleAlert];
            // 确定注销
            self._okAction = [UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                    [self application:application didFinishLaunchingWithOptions:launchOptions];
            }];
             self._cancelAction =[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                 exit(0);
             }];

            [_alert addAction:self._okAction];
            [_alert addAction:self._cancelAction];

                // 弹出对话框
            [self.window.rootViewController presentViewController:_alert animated:true completion:nil];
            
            //[self application:application didFinishLaunchingWithOptions:launchOptions];
    }];
    return YES;
}

-(BOOL)initApp2:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    //替换为您自己的Bugly账户。
    //[Bugly startWithAppId:@"b21375e023"];
    
    [WFCCNetworkService startLog];
    [WFCCNetworkService sharedInstance].connectionStatusDelegate = self;
    [WFCCNetworkService sharedInstance].receiveMessageDelegate = self;
    [[WFCCNetworkService sharedInstance] setServerAddress:IM_SERVER_HOST port:IM_SERVER_PORT];
    
    [UITextViewWorkaround executeWorkaround];
    
#if WFCU_SUPPORT_VOIP
    [[WFAVEngineKit sharedEngineKit] addIceServer:ICE_ADDRESS userName:ICE_USERNAME password:ICE_PASSWORD];
    [[WFAVEngineKit sharedEngineKit] setVideoProfile:kWFAVVideoProfile360P swapWidthHeight:YES];
    [WFAVEngineKit sharedEngineKit].delegate = self;
#endif
    
    [WFCUConfigManager globalManager].appServiceProvider = [AppService sharedAppService];
    

    NSString *savedToken = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedToken"];
    NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    

    self.tabBarVC = [WFCBaseTabBarController new];
    self.window.rootViewController = self.tabBarVC;
    

    ///[self setTableIndex1];
    //[self performSelector:@selector(setTableIndex1) withObject:nil afterDelay:0.5f];
    //[self performSelector:@selector(setTableIndex2) withObject:nil afterDelay:1.5f];
    //[self performSelector:@selector(setTableIndex0) withObject:nil afterDelay:2.0f];
    
    [self setupNavBar];
    
    setQrCodeDelegate(self);
    
    
    if (@available(iOS 10.0, *)) {
        //第一步：获取推送通知中心
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        center.delegate = self;
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert|UNAuthorizationOptionSound|UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  if (!error) {
                                      NSLog(@"succeeded!");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [application registerForRemoteNotifications];
                                      });
                                  }
                              }];
    } else {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    }
    
        
    if (savedToken.length > 0 && savedUserId.length > 0) {
        //需要注意token跟clientId是强依赖的，一定要调用getClientId获取到clientId，然后用这个clientId获取token，这样connect才能成功，如果随便使用一个clientId获取到的token将无法链接成功。
        [[WFCCNetworkService sharedInstance] connect:savedUserId token:savedToken];
        
    } else {
        UIViewController *loginVC = [[WFCLoginViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:loginVC];
        self.window.rootViewController = nav;
    }
        
    
    return YES;
}
//return http://xxxx
+(NSString*)getMFS_hu{
    NSString *h = [self getMFS_http];
    NSString *u = [self getMFS_url];
    NSString *_str = [h stringByAppendingString:@"://"];
    _str = [_str stringByAppendingString:u];
    return _str;
}

//return http or https
+(NSString*)getMFS_http{
    if(st){
        return st;
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    return [dict objectForKey:@"serverhttp"];
}
+(void)setMFS_http:(NSString*)str{
    st = str;
}

//return domain or ip
+(NSString*)getMFS_url{
    if(su){
        return su;
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    return [dict objectForKey:@"serverurl"];
}
+(void)setMFS_url:(NSString*)str{
    su = str;
}

//return domain or port
+(NSString*)getMFS_port{
    if(sp){
        return sp;
    }
    NSString *file = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithContentsOfFile:file];
    return [dict objectForKey:@"serverport"];
}
+(void)setMFS_port:(NSString*)str{
    sp = str;
}

-(void)alert:(NSString*) text{
    UIAlertView *_alert = [[UIAlertView alloc]initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [_alert show];
}

-(void) setTableIndex1 {
    self.tabBarVC.selectedIndex = 1;
}
-(void) setTableIndex2 {
    self.tabBarVC.selectedIndex = 2;
}

-(void) setTableIndex0 {
    self.tabBarVC.selectedIndex = 0;
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    if ([deviceToken isKindOfClass:[NSData class]]) {
        const unsigned *tokenBytes = [deviceToken bytes];
        NSString *hexToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x",
                              ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),
                              ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]),
                              ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
        [[WFCCNetworkService sharedInstance] setDeviceToken:hexToken];
    } else {
        NSString *token = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                                                 withString:@""]
                            stringByReplacingOccurrencesOfString:@">"
                            withString:@""]
                           stringByReplacingOccurrencesOfString:@" "
                           withString:@""];
        
        [[WFCCNetworkService sharedInstance] setDeviceToken:token];
    }

    [JPUSHService registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
  NSLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
    [UIApplication sharedApplication].applicationIconBadgeNumber = unreadCount.unread;
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [WFCCNetworkService startLog];
}




#pragma mark- JPUSHRegisterDelegate

// iOS 12 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center openSettingsForNotification:(UNNotification *)notification{
  if (notification && [notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    //从通知界面直接进入应用
  }else{
    //从通知设置界面进入应用
  }
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
  // Required
  NSDictionary * userInfo = notification.request.content.userInfo;
  if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler(UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有 Badge、Sound、Alert 三种类型可以选择设置
}

// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
  // Required
  NSDictionary * userInfo = response.notification.request.content.userInfo;
  if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
    [JPUSHService handleRemoteNotification:userInfo];
  }
  completionHandler();  // 系统要求执行这个方法
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {

  // Required, iOS 7 Support
  [JPUSHService handleRemoteNotification:userInfo];
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {

  // Required, For systems with less than or equal to iOS 6
  [JPUSHService handleRemoteNotification:userInfo];
}









-(void)playding{
    /*
    if (!self.musicPlayer) {
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"definite" withExtension:@"mp3"];
        NSError *error = nil;
        self.musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    }
    //if (![self.musicPlayer isPlaying]){
        self.musicPlayer.numberOfLoops = -1;
        self.musicPlayer.volume = 1.0;
        [self.musicPlayer prepareToPlay];
        [self.musicPlayer play];
        NSLog(@"play mp3");
    //}*/
    
    
    
    if (!self.musicPlayer) {
            NSString *filePath = [[NSBundle mainBundle] pathForResource:@"definite" ofType:@"mp3"];
            NSURL *fileUrl = [NSURL URLWithString:filePath];
            self.musicPlayer = [[AVAudioPlayer alloc]initWithContentsOfURL:fileUrl error:nil];
            //self.musicPlayer.delegate = self;
        }

    if (![self.musicPlayer isPlaying]){
        [self.musicPlayer setVolume:0.6];
        [self.musicPlayer prepareToPlay];
        [self.musicPlayer play];
        NSLog(@"play mp3");
    }
}


- (void)onReceiveMessage:(NSArray<WFCCMessage *> *)messages hasMore:(BOOL)hasMore {
    if(messages!=nil && messages!=NULL && messages.count>0){
        WFCCMessage *_msg = messages[0];
        if(_msg!=nil && _msg!=NULL && _msg.content.extra!=nil && _msg.content.extra!=NULL && _msg.messageId>0){
            WFCCConversationInfo *_info = [[WFCCIMService sharedWFCIMService] getConversationInfo:_msg.conversation];
            BOOL *_value = [[WFCCIMService sharedWFCIMService] isGlobalSlient];
            if(!_value && !_info.isSilent){
                [self playding];
            }
        }
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        WFCCUnreadCount *unreadCount = [[WFCCIMService sharedWFCIMService] getUnreadCount:@[@(Single_Type), @(Group_Type), @(Channel_Type)] lines:@[@(0)]];
        int count = unreadCount.unread;
        [UIApplication sharedApplication].applicationIconBadgeNumber = count;
        
        for (WFCCMessage *msg in messages) {
            //当在后台活跃时收到新消息，需要弹出本地通知。有一种可能时客户端已经收到远程推送，然后由于voip/backgroud fetch在后台拉活了应用，此时会收到接收下来消息，因此需要避免重复通知
            if (([[NSDate date] timeIntervalSince1970] - (msg.serverTime - [WFCCNetworkService sharedInstance].serverDeltaTime)/1000) > 3) {
                continue;
            }
            
            if (msg.direction == MessageDirection_Send) {
                continue;
            }
            
            int flag = (int)[msg.content.class performSelector:@selector(getContentFlags)];
            WFCCConversationInfo *info = [[WFCCIMService sharedWFCIMService] getConversationInfo:msg.conversation];
            if((flag & 0x03) && !info.isSilent && ![msg.content isKindOfClass:[WFCCCallStartMessageContent class]]) {
              UILocalNotification *localNote = [[UILocalNotification alloc] init];
              
              localNote.alertBody = [msg digest];
              if (msg.conversation.type == Single_Type) {
                WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.conversation.target refresh:NO];
                if (sender.displayName) {
                    if (@available(iOS 8.2, *)) {
                        localNote.alertTitle = sender.displayName;
                    } else {
                        // Fallback on earlier versions
                    }
                }
              } else if(msg.conversation.type == Group_Type) {
                  WFCCGroupInfo *group = [[WFCCIMService sharedWFCIMService] getGroupInfo:msg.conversation.target refresh:NO];
                  WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:msg.fromUser refresh:NO];
                  if (sender.displayName && group.name) {
                      if (@available(iOS 8.2, *)) {
                          localNote.alertTitle = [NSString stringWithFormat:@"%@@%@:", sender.displayName, group.name];
                      } else {
                          // Fallback on earlier versions
                      }
                  }else if (sender.displayName) {
                      if (@available(iOS 8.2, *)) {
                          localNote.alertTitle = sender.displayName;
                      } else {
                          // Fallback on earlier versions
                      }
                  }
                  if (msg.status == Message_Status_Mentioned || msg.status == Message_Status_AllMentioned) {
                      if (sender.displayName) {
                          localNote.alertBody = [NSString stringWithFormat:@"%@在群里@了你", sender.displayName];
                      } else {
                          localNote.alertBody = @"有人在群里@了你";
                      }
                          
                  }
              }
              
              localNote.applicationIconBadgeNumber = count;
              localNote.userInfo = @{@"conversationType" : @(msg.conversation.type), @"conversationTarget" : msg.conversation.target, @"conversationLine" : @(msg.conversation.line) };
              
                dispatch_async(dispatch_get_main_queue(), ^{
                  [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
                });
            }
        }
        
    }
}

- (void)onConnectionStatusChanged:(ConnectionStatus)status {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == kConnectionStatusRejected || status == kConnectionStatusTokenIncorrect || status == kConnectionStatusSecretKeyMismatch) {
            [[WFCCNetworkService sharedInstance] disconnect:YES];
        } else if (status == kConnectionStatusLogout) {
            UIViewController *loginVC = [[WFCLoginViewController alloc] init];
            self.window.rootViewController = loginVC;
        } 
    });
}

- (void)setupNavBar {
    //[WFCUConfigManager globalManager].naviBackgroudColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9];
    //[WFCUConfigManager globalManager].naviBackgroudColor = HexColor(0x1670C1);
    [WFCUConfigManager globalManager].naviBackgroudColor = HexColor(0x39abf2);
    [WFCUConfigManager globalManager].naviTextColor = [UIColor whiteColor];
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.barTintColor = [WFCUConfigManager globalManager].naviBackgroudColor;
    bar.tintColor = [WFCUConfigManager globalManager].naviTextColor;
    bar.titleTextAttributes = @{NSForegroundColorAttributeName : [WFCUConfigManager globalManager].naviTextColor};
    bar.barStyle = UIBarStyleDefault;
    
    [[UITabBar appearance] setBarTintColor:[WFCUConfigManager globalManager].frameBackgroudColor];
    [UITabBar appearance].translucent = NO;
}
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    return [self handleUrl:[url absoluteString] withNav:application.delegate.window.rootViewController.navigationController];
}

- (BOOL)handleUrl:(NSString *)str withNav:(UINavigationController *)navigator {
    NSLog(@"str scanned %@", str);
    if ([str rangeOfString:@"wildfirechat://user" options:NSCaseInsensitiveSearch].location == 0) {
        NSString *userId = [str lastPathComponent];
        WFCUProfileTableViewController *vc2 = [[WFCUProfileTableViewController alloc] init];
        vc2.userId = userId;
        vc2.hidesBottomBarWhenPushed = YES;
        
        [navigator pushViewController:vc2 animated:YES];
        return YES;
    } else if ([str rangeOfString:@"wildfirechat://group" options:NSCaseInsensitiveSearch].location == 0) {
        NSString *groupId = [str lastPathComponent];
        GroupInfoViewController *vc2 = [[GroupInfoViewController alloc] init];
        vc2.groupId = groupId;
        vc2.hidesBottomBarWhenPushed = YES;
        [navigator pushViewController:vc2 animated:YES];
        return YES;
    } else if ([str rangeOfString:@"wildfirechat://pcsession" options:NSCaseInsensitiveSearch].location == 0) {
        NSString *sessionId = [str lastPathComponent];
        PCLoginConfirmViewController *vc2 = [[PCLoginConfirmViewController alloc] init];
        vc2.sessionId = sessionId;
        vc2.hidesBottomBarWhenPushed = YES;
        [navigator pushViewController:vc2 animated:YES];
        return YES;
    }
    return NO;
}

#if WFCU_SUPPORT_VOIP
#pragma mark - WFAVEngineDelegate
- (void)didReceiveCall:(WFAVCallSession *)session {
    WFCUVideoViewController *videoVC = [[WFCUVideoViewController alloc] initWithSession:session];
    [[WFAVEngineKit sharedEngineKit] presentViewController:videoVC];
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        UILocalNotification *localNote = [[UILocalNotification alloc] init];
        
        localNote.alertBody = @"来电话了";
        
            WFCCUserInfo *sender = [[WFCCIMService sharedWFCIMService] getUserInfo:session.clientId refresh:NO];
            if (sender.displayName) {
                if (@available(iOS 8.2, *)) {
                    localNote.alertTitle = sender.displayName;
                } else {
                    // Fallback on earlier versions
                    
                }
            }
        
        localNote.soundName = @"ring.caf";
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] scheduleLocalNotification:localNote];
        });
    }
}

- (void)shouldStartRing:(BOOL)isIncoming {
    
    if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        AudioServicesAddSystemSoundCompletion(kSystemSoundID_Vibrate, NULL, NULL, systemAudioCallback, NULL);
        AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
    } else {
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        //默认情况按静音或者锁屏键会静音
        [audioSession setCategory:AVAudioSessionCategorySoloAmbient error:nil];
        [audioSession setActive:YES error:nil];
        
        if (self.audioPlayer) {
            [self shouldStopRing];
        }
        
        NSURL *url = [[NSBundle mainBundle] URLForResource:@"ring" withExtension:@"mp3"];
        NSError *error = nil;
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        if (!error) {
            self.audioPlayer.numberOfLoops = -1;
            self.audioPlayer.volume = 1.0;
            [self.audioPlayer prepareToPlay];
            [self.audioPlayer play];
        }
    }
}

void systemAudioCallback (SystemSoundID soundID, void* clientData) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
            if ([WFAVEngineKit sharedEngineKit].currentSession.state == kWFAVEngineStateIncomming) {
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
            }
        }
    });
}

- (void)shouldStopRing {
    if (self.audioPlayer) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
        [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
    }
}
#endif
#pragma mark - UNUserNotificationCenterDelegate
//将要推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler API_AVAILABLE(ios(10.0)){
    NSLog(@"----------willPresentNotification");
}
//已经完成推送
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler API_AVAILABLE(ios(10.0)){
    NSLog(@"============didReceiveNotificationResponse");
    NSString *categoryID = response.notification.request.content.categoryIdentifier;
    if ([categoryID isEqualToString:@"categoryIdentifier"]) {
        if ([response.actionIdentifier isEqualToString:@"enterApp"]) {
            if (@available(iOS 10.0, *)) {
                
            } else {
                // Fallback on earlier versions
            }
        }else{
            NSLog(@"No======");
        }
    }
    completionHandler();
}


#pragma mark - QrCodeDelegate
- (void)showQrCodeViewController:(UINavigationController *)navigator type:(int)type target:(NSString *)target {
    CreateBarCodeViewController *vc = [CreateBarCodeViewController new];
    vc.qrType = type;
    vc.target = target;
    [navigator pushViewController:vc animated:YES];
}

- (void)scanQrCode:(UINavigationController *)navigator {
    QQLBXScanViewController *vc = [QQLBXScanViewController new];
    vc.libraryType = SLT_Native;
    vc.scanCodeType = SCT_QRCode;
    
    vc.style = [StyleDIY qqStyle];
    
    //镜头拉远拉近功能
    vc.isVideoZoom = YES;
    
    vc.hidesBottomBarWhenPushed = YES;
    __weak typeof(self)ws = self;
    vc.scanResult = ^(NSString *str) {
        [ws handleUrl:str withNav:navigator];
    };
    [navigator pushViewController:vc animated:YES];
}
@end
