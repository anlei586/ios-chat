#import <WFChatUIKit/WFChatUIKit.h>
#import <WFChatUIKit/WFCUConfigManager.h>

#import "AFNetworking.h"
#import "MBProgressHUD.h"
#import "WFCConfig.h"

#import "AppInitView.h"

@interface AppInitView ()<UITextFieldDelegate>
@property (strong, nonatomic) UILabel *hintLabel;
@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UIView *userNameLine;
@property (strong, nonatomic) UIButton *loginBtn;
@property(strong, nonatomic) UIAlertAction *_okAction;
@property(strong, nonatomic) UIAlertAction *_cancelAction;


typedef void(^onLoadComp)(void);
@property(nonatomic, copy) onLoadComp onLoadComplete;


@end

@implementation AppInitView

NSInteger *isExec = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
-(void) viewInit{
    CGRect bgRect = [UIScreen mainScreen].bounds;
    CGFloat paddingEdge = 40;
    
    CGFloat paddingTF2Line = 12;
    CGFloat paddingLine2TF = 24;
    CGFloat sendCodeBtnwidth = 120;
    CGFloat paddingField2Code = 8;
    
    CGFloat topPos = 70;
    CGFloat fieldHeight = 25;
    
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingEdge, topPos, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight*2)];
    [self.hintLabel setText:@"请输入官码"];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont systemFontOfSize:fieldHeight];
    
    topPos += fieldHeight * 2 + 10;
    
    self.userNameLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.userNameLine.backgroundColor = [UIColor grayColor];
    
    
    self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.userNameField.placeholder = @"官码";
    [self.userNameField setText:@""];
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *rcode = [userDefaults objectForKey:@"rcode"];
    if(rcode){
        [self.userNameField setText:rcode];
    }
    
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 20, bgRect.size.width - paddingEdge - paddingEdge, 36)];
    [self.loginBtn setBackgroundColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]];
    [self.loginBtn addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 5.f;
    [self.loginBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.loginBtn.enabled = YES;
    
    
    //[self onLoadCenterConfig];
}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{

-(void) displayChild {
    isExec = 1;
    [self.view addSubview:self.hintLabel];
    [self.view addSubview:self.userNameLine];
    [self.view addSubview:self.userNameField];
    [self.view addSubview:self.loginBtn];
}

-(void) onLoadCenterConfig:(void(^)())testBlock{
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"加载官码配置中...";
    [hud showAnimated:YES];
    
    NSString *url = CENTER_URL;
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/json"];
    [manager GET:url parameters:nil progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud hideAnimated:YES];
            NSString *_data = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            
        
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *txtPath = [docPath stringByAppendingPathComponent:@"rconfig.txt"]; // 此时仅存在路径，文件并没有真实存在
        [_data writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
        // 字符串读取的方法
        NSString *resultStr = [NSString stringWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
        NSLog(@"resultStr is %@", resultStr);
        
        NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];

        NSError *err;
        NSDictionary *dict3 = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
        if(err){
            [self alert:@"官码JSON解析出错"];
            [self alert:_data];
        }
        NSString *zidb = dict3[@"0"][@"bai"];
        RCODE_ONF= [zidb intValue];

        if(isExec==0){
            testBlock();
        }else{
            _onLoadComplete = testBlock;
        }
            
     }    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            NSLog(@"--%@",error);
            //[self alert:@"加载配置出错"];
            // 初始化对话框
            UIAlertController *_alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"也许您的网络遇到了问题，请尝试切换4G或WIFI" preferredStyle:UIAlertControllerStyleAlert];
            // 确定注销
            self._okAction = [UIAlertAction actionWithTitle:@"再试一次" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
                [self onLoadCenterConfig:^{}];
            }];
             self._cancelAction =[UIAlertAction actionWithTitle:@"退出" style:UIAlertActionStyleCancel handler:^(UIAlertAction *_Nonnull action) {
                 exit(0);
             }];

            [_alert addAction:self._okAction];
            [_alert addAction:self._cancelAction];

            // 弹出对话框
            [self.view.window.rootViewController presentViewController:_alert animated:true completion:nil];
            
    }];
}

- (void)onLoginButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSLog(user);

    
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
    
    BOOL *onf = NO;
    int *len = [dict count];
    for(int i=0;i<len;i++){

        NSString *istr = [NSString stringWithFormat:@"%d",i];
        NSDictionary *larr = dict[istr];
        
        NSString *bai = larr[@"bai"];
        NSString *bid = larr[@"id"];
        if([bai isEqualToString:@"1"] && [bid isEqualToString:user] ){
            onf = YES;
 
            
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:user forKey:@"rcode"];
            
            break;
        }else{
            onf = NO;
        }
        
    }
    if(onf==NO){
        [self alert:@"该码已下架"];
    }else if(onf){
        NSLog(@"很好");
        _onLoadComplete();
    }
    

}

-(void)alert:(NSString*) text{
    UIAlertView *_alert = [[UIAlertView alloc]initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [_alert show];
}

@end
