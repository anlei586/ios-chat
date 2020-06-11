//
//  WFCBaseTabBarController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCBaseTabBarController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "DiscoverViewController.h"
#import "WFCMeTableViewController.h"

#import <WFChatUIKit/WFCUConfigManager.h>
#import "AFNetworking.h"
#import "WFCConfig.h"

#ifdef WFC_MOMENTS
#import <WFMomentUIKit/WFMomentUIKit.h>
#import <WFMomentClient/WFMomentClient.h>
#endif
#import "UIImage+ERCategory.h"

#define kClassKey   @"rootVCClassString"
#define kTitleKey   @"title"
#define kImgKey     @"imageName"
#define kSelImgKey  @"selectedImageName"


static NSDictionary *apiclient;

@interface WFCBaseTabBarController ()
@property (nonatomic, strong)UINavigationController *firstNav;
@property (nonatomic, strong)UINavigationController *settingNav;


@end

@implementation WFCBaseTabBarController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIViewController *vc = [DiscoverViewController new];
    vc.title = LocalizedString(@"Discover");
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UITabBarItem *item = nav.tabBarItem;
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Discover");
    item.image = [UIImage imageNamed:@"tabbar_discover"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_discover_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    
    self.firstNav = nav;
    
    WFCUConversationTableViewController *vc1 = [WFCUConversationTableViewController new];
    vc1.title = LocalizedString(@"Message");
    nav = [[UINavigationController alloc] initWithRootViewController:vc1];
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Message");

    item.image = [UIImage imageNamed:@"tabbar_chat"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_chat_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    //[vc1 viewDidLoad];
    //[vc1 viewWillAppear:YES];
    
    vc = [WFCUContactListViewController new];
    vc.title = LocalizedString(@"Contact");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Contact");
    item.image = [UIImage imageNamed:@"tabbar_contacts"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_contacts_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    

    vc = [WFCMeTableViewController new];
    vc.title = LocalizedString(@"Me");
    nav = [[UINavigationController alloc] initWithRootViewController:vc];
    item = nav.tabBarItem;
    item.title = LocalizedString(@"Me");
    item.image = [UIImage imageNamed:@"tabbar_me"];
    item.selectedImage = [[UIImage imageNamed:@"tabbar_me_cover"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [item setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]} forState:UIControlStateSelected];
    [self addChildViewController:nav];
    self.settingNav = nav;
    
    NSTimer *timer;
    timer = [NSTimer scheduledTimerWithTimeInterval:50.0 target:self selector:@selector(updateClock:) userInfo:nil repeats:YES];

    #ifdef WFC_MOMENTS
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveComments:) name:kReceiveComments object:nil];
    #endif
}

+(NSDictionary*) getApiClient{
    return apiclient;
}
+(void) setApiClient:(NSDictionary*)dict{
    apiclient = dict;
    [WFCUConfigManager setApiClient:dict];
}
-(void)alert:(NSString*) text{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
}

- (void)onReceiveComments:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateBadgeNumber];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateBadgeNumber];
}

- (void)updateBadgeNumber {
#ifdef WFC_MOMENTS
    [self.tabBar showBadgeOnItemIndex:2 badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif

}

- (void)setNewUser:(BOOL)newUser {
    if (newUser) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"欢迎注册" message:@"请更新您头像和昵称，以便您的朋友能更好地识别！" preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                self.selectedViewController = self.settingNav;
            }];
            [alertController addAction:action];
            NSLog(@"hahahah");
            [self.firstNav presentViewController:alertController animated:YES completion:nil];
        });
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if([[UIApplication sharedApplication].delegate respondsToSelector:@selector(setupNavBar)]) {
                [[UIApplication sharedApplication].delegate performSelector:@selector(setupNavBar)];
            }
            UIView *superView = self.view.superview;
            [self.view removeFromSuperview];
            [superView addSubview:self.view];
        }
    }
}

-(NSString *)updateClock:(NSTimer *)theTimer
{
    NSString *uid = [WFCCNetworkService sharedInstance].userId;
    if(uid==nil || uid==NULL) uid = @"";
    //NSLog(uid);
    //NSString *savedUserId = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedUserId"];
    [self getTimevalGetConfig:uid];
    return @"";
}

-(void)getTimevalGetConfig:(NSString *)uid {
    NSString *_url1 = [@"/yh/apiclient.php?uid=" stringByAppendingString:uid];
    NSString *url = [NSString stringWithFormat:@"%@%@", APP_SERVER_PHP, _url1];
    NSLog(url);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSString *_data = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            [WFCBaseTabBarController setApiClient:dict];
            
            
     }    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
    }];
}

@end
