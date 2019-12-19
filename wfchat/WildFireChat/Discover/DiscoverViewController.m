//
//  DiscoverViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/28.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "DiscoverViewController.h"
#import "ChatroomListViewController.h"
#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatClient/WFCCIMService.h>
#import <WebKit/WebKit.h>
#import "WFCBaseTabBarController.h"

#define HexColor(s) [UIColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s &0xFF))/255.0 alpha:1.0]

@interface DiscoverViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong)UITableView *tableView;

@property (nonatomic, strong)WKWebView *wkWebView;
@property (nonatomic, strong)UIProgressView *proBar;
@property (nonatomic, strong)UIActionSheet *uiActionSheet;

@property (nonatomic, strong)NSString *main_url;
@property (nonatomic, assign)BOOL hasMoments;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"发现";
    
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








- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)webSendRequest{
    NSDictionary *dict = [WFCBaseTabBarController getApiClient];
    self.main_url = dict[@"homeUrl"];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 48;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && indexPath.row == 0) {
        if(self.hasMoments) {
            UIViewController *vc = [[NSClassFromString(@"SDTimeLineTableViewController") alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            ChatroomListViewController *vc = [[ChatroomListViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
    } else if (indexPath.section == 1 && indexPath.row == 0) {
        if (self.hasMoments) {
            ChatroomListViewController *vc = [[ChatroomListViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        } else {
            WFCUBrowserViewController *vc = [[WFCUBrowserViewController alloc] init];
            vc.hidesBottomBarWhenPushed = YES;
            vc.url = @"http://docs.wildfirechat.cn";
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    } else if (indexPath.section == 2 && indexPath.row == 0) {
        WFCUBrowserViewController *vc = [[WFCUBrowserViewController alloc] init];
        vc.hidesBottomBarWhenPushed = YES;
        vc.url = @"http://docs.wildfirechat.cn";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.hasMoments) {
        return 3;
    }
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"styleDefault"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"styleDefault"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.accessoryView = nil;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == 0) {
        if (self.hasMoments) {
            cell.textLabel.text = LocalizedString(@"Moments");
            cell.imageView.image = [UIImage imageNamed:@"AlbumReflashIcon"];
        } else {
            cell.textLabel.text = LocalizedString(@"Chatroom");
            cell.imageView.image = [UIImage imageNamed:@"discover_chatroom"];
        }
    } else if(indexPath.section == 1) {
        if (self.hasMoments) {
            cell.textLabel.text = LocalizedString(@"Chatroom");
            cell.imageView.image = [UIImage imageNamed:@"discover_chatroom"];
        } else {
            cell.textLabel.text = LocalizedString(@"DevDocs");
            cell.imageView.image = [UIImage imageNamed:@"dev_docs"];
        }
    } else if(indexPath.section == 2) {
        if (self.hasMoments) {
            cell.textLabel.text = LocalizedString(@"DevDocs");
            cell.imageView.image = [UIImage imageNamed:@"dev_docs"];
        }
    }
    
    return cell;
}

@end
