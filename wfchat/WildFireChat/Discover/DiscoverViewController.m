//
//  DiscoverViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "DiscoverViewController.h"
#import "ChatroomListViewController.h"
#import "DeviceTableViewController.h"
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatClient/WFCCIMService.h>

#import <WebKit/WebKit.h>
#import "WFCBaseTabBarController.h"

#import <WFChatClient/WFCChatClient.h>

#define HexColor(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

#import "DiscoverMomentsTableViewCell.h"
#ifdef WFC_MOMENTS
#import <WFMomentClient/WFMomentClient.h>
#import <WFMomentUIKit/WFMomentUIKit.h>
#endif
#import "UIFont+YH.h"
#import "UIColor+YH.h"


@interface DiscoverViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)WKWebView *wkWebView;
@property (nonatomic, strong)UIProgressView *proBar;
@property (nonatomic, strong)UIActionSheet *uiActionSheet;

@property (nonatomic, strong)NSString *main_url;
@property (nonatomic, assign)BOOL hasMoments;

@property (nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    self.title = LocalizedString(@"Discover");
    
    self.proBar = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 0)];
    self.proBar.tintColor = HexColor(0x45c01a);
    self.proBar.trackTintColor = HexColor(0x1e88e5);
    
    WKPreferences *preferences = [WKPreferences new];
    preferences.javaScriptCanOpenWindowsAutomatically = YES;
    
    
    
    CGRect appf = [[UIScreen mainScreen]applicationFrame];
    
    self.wkWebView = [[WKWebView alloc]initWithFrame:CGRectMake(appf.origin.x,appf.origin.y,appf.size.width,appf.size.height-50)];
    self.wkWebView.navigationDelegate=self;
    
    self.wkWebView.configuration.processPool = preferences;
    
    self.wkWebView.UIDelegate = self;
    self.wkWebView.opaque = NO;
    self.wkWebView.multipleTouchEnabled= YES;
    self.wkWebView.backgroundColor=[UIColor whiteColor];
    [self.wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
    [self.view addSubview:self.wkWebView];
    [self.view addSubview:self.proBar];
    [self webSendRequest];
    
    UIBarButtonItem *backItemBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic_back"] style:UIBarButtonItemStyleDone target:self action:@selector(onWebBack:)];
    
    //UIBarButtonItem *reloadItemBtn = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload"] style:UIBarButtonItemStyleDone target:self action:@selector(onWebReload:)];
    
    UIBarButtonItem *reloadItemBtn = [[UIBarButtonItem alloc] initWithTitle:@"..." style:UIBarButtonItemStyleDone target:self action:@selector(rightBtnAction:)];
    
    self.navigationItem.leftBarButtonItem = backItemBtn;
    self.navigationItem.rightBarButtonItem = reloadItemBtn;
}

-(void)rightBtnAction:(UIBarButtonItem *)sender {
    if(self.uiActionSheet==nil || self.uiActionSheet==NULL){
        self.uiActionSheet = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:@"取消"
                              destructiveButtonTitle:@"清缓存并重新加载"
                              otherButtonTitles:@"浏览器打开",@"前进",@"后退", nil
                              ];
        self.uiActionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    }
    [self.uiActionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch(buttonIndex){
        case 0:
            [self onWebReload2];
            break;
        /*case 1:
            [self.wkWebView reload];
            break;*/
        case 1:
            [self onOpenNav];
            break;
        case 2:
            [self.wkWebView goForward];
            break;
        case 3:
            [self.wkWebView goBack];
            break;
    }
}
-(void)onOpenNav{

    NSString *jsTxt = @"document.location.href";
    [self.wkWebView evaluateJavaScript:jsTxt completionHandler:^(id val, NSError *error) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:val]];
        
    }];
}

-(void)dealloc{
    [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
}
-(nullable WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(nonnull WKWebViewConfiguration *)configuration forNavigationAction:(nonnull WKNavigationAction *)navigationAction windowFeatures:(nonnull WKWindowFeatures *)windowFeatures
{
    /*if(navigationAction.request.URL){
        NSURL *url = navigationAction.request.URL;
        NSString *urlPath = url.absoluteString;
        if([urlPath rangeOfString:@"https://"].location != NSNotFound || [urlPath rangeOfString:@"http://"].location != NSNotFound){
            [[UIApplication sharedApplication] openURL:url options:nil completionHandler:^(BOOL success){
                NSLog(@"success");
            }];
        }
    }*/
    if(!navigationAction.targetFrame.isMainFrame){
        [webView loadRequest:navigationAction.request];
/*
    self.dataSource = [NSMutableArray arrayWithArray:@[@{@"title":LocalizedString(@"Chatroom"),@"image":@"discover_chatroom",@"des":@"chatroom"},
        @{@"title":LocalizedString(@"Rebot"),@"image":@"rebot",@"des":@"rebot"},
        @{@"title":LocalizedString(@"Channel"),
          @"image":@"chat_channel",@"des":@"channel"},
        @{@"title":LocalizedString(@"DevDocs"),
          @"image":@"dev_docs",@"des":@"Dev"},@{@"title":@"Things",
          @"image":@"discover_things",@"des":@"Things"}]];
    
    if(NSClassFromString(@"SDTimeLineTableViewController")) {
        [self.dataSource insertObject:@{@"title":LocalizedString(@"Moments"),@"image":@"AlbumReflashIcon",@"des":@"moment"} atIndex:0];
        self.hasMoments = YES;
    } else {
        self.hasMoments = NO;
*/
    }
    if(navigationAction.targetFrame==nil){
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}
#pragma mark - WKNavingationDelegae mehod
-(void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {
    if(navigationAction.targetFrame == nil){
        [self.wkWebView loadRequest:navigationAction.request];
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

#pragma mark - event response
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if(object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        self.proBar.alpha = 1.0f;
        [self.proBar setProgress:newprogress animated:YES];
        if(newprogress >= 1.0f){
            
            [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self.proBar setProgress:0 animated:NO];
            } completion:^(BOOL finished){
                [self.proBar setProgress:0 animated:NO];
            }];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}








#pragma mark -- WKUIDelegate
// 显示一个按钮。点击后调用completionHandler回调
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
 
        completionHandler();
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
 
// 显示两个按钮，通过completionHandler回调判断用户点击的确定还是取消按钮
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(YES);
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(NO);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
 
// 显示一个带有输入框和一个确定按钮的，通过completionHandler回调用户输入的内容
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler{
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        completionHandler(alertController.textFields.lastObject.text);
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}








/*
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 0.01)];
    [self.tableView reloadData];
    self.tableView.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    [self.view addSubview:self.tableView];
    
#ifdef WFC_MOMENTS
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onReceiveComments:) name:kReceiveComments object:nil];
#endif
}

- (void)onReceiveComments:(NSNotification *)notification {
    [self.tableView reloadData];
}


*/
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)webSendRequest{
    NSDictionary *dict = [WFCBaseTabBarController getApiClient];
    self.main_url = dict[@"homeUrl"];
    
    NSString *uid = [WFCCNetworkService sharedInstance].userId;
    if(uid==nil || uid==NULL) uid = @"";
    
    self.main_url = [self.main_url stringByAppendingString: @"?uid="];
    self.main_url = [self.main_url stringByAppendingString: uid];
    
    [self.wkWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.main_url]]];
}

-(void)onWebBack:(UIBarButtonItem *)sender {
    [self.wkWebView goBack];
}
-(void)onWebReload:(UIBarButtonItem *)sender {
    [self onWebReload2];
}

-(void)onWebReload2{
    //clear cache
    NSArray *types = @[WKWebsiteDataTypeMemoryCache, WKWebsiteDataTypeDiskCache];
    NSSet *websiteDataTypes = [NSSet setWithArray:types];
    NSDate * dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
    [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        
    }];
    
    //look content
    NSString *jsTxt = @"document.body.innerText";
    [self.wkWebView evaluateJavaScript:jsTxt completionHandler:^(id val, NSError *error) {
        if(val==nil || val==NULL){
            [self webSendRequest];
            return;
        }else{
            NSUInteger len = [val length];
            if(len<=0){
                [self webSendRequest];
                return;
            }
        }
    }];
    [self.wkWebView reload];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUnreadStatus];
}

- (void)updateUnreadStatus {
    [self.tableView reloadData];
#ifdef WFC_MOMENTS
    [self.tabBarController.tabBar showBadgeOnItemIndex:2 badgeValue:[[WFMomentService sharedService] getUnreadCount]];
#endif
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 9)];
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 9;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 53;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSString *des = self.dataSource[indexPath.section][@"des"];
    if ([des isEqualToString:@"moment"]) {
         UIViewController *vc = [[NSClassFromString(@"SDTimeLineTableViewController") alloc] init];
                   vc.hidesBottomBarWhenPushed = YES;
                   [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"chatroom"]) {
        ChatroomListViewController *vc = [[ChatroomListViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
                  [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"channel"]) {
        WFCUFavChannelTableViewController *channelVC = [[WFCUFavChannelTableViewController alloc] init];;
        channelVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:channelVC animated:YES];
    }
    
    if ([des isEqualToString:@"rebot"]) {
            WFCUMessageListViewController *mvc = [[WFCUMessageListViewController alloc] init];
            mvc.conversation = [[WFCCConversation alloc] init];
            mvc.conversation.type = Single_Type;
            mvc.conversation.target = @"FireRobot";
            mvc.conversation.line = 0;
        
            mvc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:mvc animated:YES];
        
    }
    

    if ([des isEqualToString:@"Dev"]) {
        WFCUBrowserViewController *vc = [[WFCUBrowserViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.url = @"http://docs.wildfirechat.cn";
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    if ([des isEqualToString:@"Things"]) {
        DeviceTableViewController *vc = [[DeviceTableViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.section == 0 && self.hasMoments) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"momentsCell"];
        if (cell == nil) {
            cell = [[DiscoverMomentsTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"momentsCell"];
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"defaultCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"defaultCell"];
        }
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.textLabel.font = [UIFont pingFangSCWithWeight:FontWeightStyleRegular size:16];
    cell.textLabel.text = self.dataSource[indexPath.section][@"title"];
    cell.imageView.image = [UIImage imageNamed:self.dataSource[indexPath.section][@"image"]];
    if (indexPath.section == 0 && self.hasMoments) {
            DiscoverMomentsTableViewCell *momentsCell = (DiscoverMomentsTableViewCell *)cell;
            __weak typeof(self)ws = self;
#ifdef WFC_MOMENTS
            int unread = [[WFMomentService sharedService] getUnreadCount];
            if (unread) {
                momentsCell.bubbleView.hidden = NO;
                [momentsCell.bubbleView setBubbleTipNumber:unread];
            } else {
                momentsCell.bubbleView.hidden = YES;
            }
            NSMutableArray<WFMFeed *> *feeds = [[WFMomentService sharedService] restoreCache:nil];
            if (feeds.count > 0) {
                momentsCell.lastFeed = [feeds objectAtIndex:0];
            } else {
                [[WFMomentService sharedService] getFeeds:0 count:10 fromUser:nil success:^(NSArray<WFMFeed *> * _Nonnull feeds) {
                    if (feeds.count) {
                        [[WFMomentService sharedService] storeCache:feeds forUser:nil];
                        [ws.tableView reloadData];
                    }
                } error:^(int error_code) {
                    
                }];
            }
#endif
        }
    return cell;
}

@end
