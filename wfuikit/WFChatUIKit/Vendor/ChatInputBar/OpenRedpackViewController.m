#import "WFCUConfigManager.h"
#import <WebKit/WebKit.h>


@interface OpenRedpackViewController ()
@property(nonatomic, strong)WKWebView *webview;
@end

@implementation OpenRedpackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.webview = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    NSDictionary *dict = [WFCUConfigManager getApiClient];
    NSString *url = dict[@"sendredpack"];
    
    [self.webview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
    [self.view addSubview:self.webview];
}
