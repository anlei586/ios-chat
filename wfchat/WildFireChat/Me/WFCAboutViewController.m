//
//  WFCAboutViewController.m
//  WFChatUIKit
//
//  Created by heavyrain.lee on 2019/1/22.
//  Copyright © 2019 heavyrain.lee. All rights reserved.
//

#import "WFCAboutViewController.h"
#import <WebKit/WebKit.h>
#import "WFCBaseTabBarController.h"
#import "WFCConfig.h"


@interface WFCAboutViewController ()
@property(nonatomic, strong)WKWebView *webview;
@end

@implementation WFCAboutViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    NSDictionary *dict = [WFCBaseTabBarController getApiClient];
    NSString *_apiAdmin = dict[@"passwdsoupprt"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@", APP_SERVER_PHP, @"/yh/"];
    url = [NSString stringWithFormat:@"%@%@", url, _apiAdmin];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:self.webview];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
