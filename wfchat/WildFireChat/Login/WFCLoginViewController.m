//
//  WFCLoginViewController.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/7/9.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCLoginViewController.h"
#import <WFChatClient/WFCChatClient.h>
#import <WFChatUIKit/WFChatUIKit.h>
#import "AppDelegate.h"
#import "WFCBaseTabBarController.h"
#import "MBProgressHUD.h"
#import "UILabel+YBAttributeTextTapAction.h"
#import "WFCPrivacyViewController.h"
#import "AppService.h"
#import "AFHTTPSessionManager.h"
#import "WFCConfig.h"

#import "WFCBaseTabBarController.h"
#import "AppInitView.h"

#import "JPUSHService.h"


//是否iPhoneX YES:iPhoneX屏幕 NO:传统屏幕
#define kIs_iPhoneX ([UIScreen mainScreen].bounds.size.height == 812.0f ||[UIScreen mainScreen].bounds.size.height == 896.0f )

#define kStatusBarAndNavigationBarHeight (kIs_iPhoneX ? 88.f : 64.f)

#define  kTabbarSafeBottomMargin        (kIs_iPhoneX ? 34.f : 0.f)

#define HEXCOLOR(rgbValue)                                                                                             \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16)) / 255.0                                               \
green:((float)((rgbValue & 0xFF00) >> 8)) / 255.0                                                  \
blue:((float)(rgbValue & 0xFF)) / 255.0                                                           \
alpha:1.0]


#define NUM @"0123456789"
#define ALPHA @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
#define ALPHANUM @"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"


@interface WFCLoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) UILabel *hintLabel;
@property (strong, nonatomic) UITextField *userNameField;
@property (strong, nonatomic) UITextField *passwordField;


@property (strong, nonatomic) UITextField *reg_userNameField;
@property (strong, nonatomic) UITextField *reg_passwordField;
@property (strong, nonatomic) UITextField *reg_repasswordField;

@property (strong, nonatomic) UIButton *loginBtn;
@property (strong, nonatomic) UIButton *regExpBtn;
@property (strong, nonatomic) UIButton *rcodeBtn;

@property (strong, nonatomic) UIView *userNameLine;
@property (strong, nonatomic) UIView *passwordLine;

@property (strong, nonatomic) UIView *reg_userNameLine;
@property (strong, nonatomic) UIView *reg_passwordLine;
@property (strong, nonatomic) UIView *reg_repasswordLine;

@property (strong, nonatomic) UIButton *sendRegExpBtn;

//@property (strong, nonatomic) UIButton *sendCodeBtn;
@property (nonatomic, strong) NSTimer *countdownTimer;
@property (nonatomic, assign) NSTimeInterval sendCodeTime;
@property (nonatomic, strong) UILabel *privacyLabel;
@property (nonatomic, strong) UIScrollView *scroll;
@property (strong, nonatomic) WFCBaseTabBarController *tabBarVC;
@end

@implementation WFCLoginViewController


static NSInteger seq = 0;

BOOL isHideReg = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [WFCUConfigManager globalManager].backgroudColor;
    NSString *savedName = [[NSUserDefaults standardUserDefaults] stringForKey:@"savedName"];
   
    CGRect bgRect = self.view.bounds;
    CGFloat paddingEdge = 40;
    
    CGFloat paddingTF2Line = 12;
    CGFloat paddingLine2TF = 24;
    CGFloat sendCodeBtnwidth = 120;
    CGFloat paddingField2Code = 8;
    
    CGFloat topPos = kStatusBarAndNavigationBarHeight + 5;
    CGFloat fieldHeight = 25;
    
    self.scroll = [[UIScrollView alloc]initWithFrame:bgRect];
    
    NSDictionary *dc2 = [WFCBaseTabBarController getApiClient];
    
    self.hintLabel = [[UILabel alloc] initWithFrame:CGRectMake(paddingEdge, topPos, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight*2)];
    [self.hintLabel setText:dc2[@"autor"]];
    self.hintLabel.textAlignment = NSTextAlignmentCenter;
    self.hintLabel.font = [UIFont systemFontOfSize:fieldHeight];
    
    topPos += fieldHeight * 2 + 10;
    
    self.userNameLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.userNameLine.backgroundColor = [UIColor grayColor];
    
    
    self.userNameField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.userNameField.placeholder = @"用户名(6位字母或数字)";
    self.userNameField.returnKeyType = UIReturnKeyNext;
    self.userNameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.userNameField.delegate = self;
    self.userNameField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    

    self.passwordLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.passwordLine.backgroundColor = [UIColor grayColor];
    
    self.passwordField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.passwordField.placeholder = @"密码(6位字母或数字)";
    self.passwordField.returnKeyType = UIReturnKeyDone;
    self.passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.passwordField.delegate = self;
    self.passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [self.passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    /*
    self.sendCodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(bgRect.size.width - paddingEdge - sendCodeBtnwidth, topPos + paddingTF2Line + fieldHeight + paddingLine2TF, sendCodeBtnwidth, fieldHeight)];
    [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.sendCodeBtn addTarget:self action:@selector(onSendCode:) forControlEvents:UIControlEventTouchDown];
    self.sendCodeBtn.enabled = NO;
    */
    self.loginBtn = [[UIButton alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 20, bgRect.size.width - paddingEdge - paddingEdge, 36)];
    [self.loginBtn setBackgroundColor:[UIColor grayColor]];
    [self.loginBtn addTarget:self action:@selector(onLoginButton:) forControlEvents:UIControlEventTouchDown];
    self.loginBtn.layer.masksToBounds = YES;
    self.loginBtn.layer.cornerRadius = 5.f;
    [self.loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
    self.loginBtn.enabled = NO;
    
    
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    self.regExpBtn = [[UIButton alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 60, bgRect.size.width - paddingEdge - paddingEdge, 36)];
    [self.regExpBtn setTitle:@"注册" forState:UIControlStateNormal];
    [self.regExpBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.regExpBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.regExpBtn addTarget:self action:@selector(onExpRegContent:) forControlEvents:UIControlEventTouchDown];
    self.regExpBtn.enabled = YES;
    
    self.rcodeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 64, 36)];
    [self.rcodeBtn setTitle:@"邀请码" forState:UIControlStateNormal];
    [self.rcodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.rcodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateSelected];
    [self.rcodeBtn addTarget:self action:@selector(onOpenRcodeView:) forControlEvents:UIControlEventTouchDown];
    self.rcodeBtn.enabled = YES;
    
    
    
    self.reg_userNameField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 100, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.reg_userNameField.placeholder = @"用户名(6位字母或数字)";
    self.reg_userNameField.returnKeyType = UIReturnKeyNext;
    self.reg_userNameField.keyboardType = UIKeyboardTypeASCIICapable;
    self.reg_userNameField.delegate = self;
    [self.reg_userNameField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.reg_userNameLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 130, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.reg_userNameLine.backgroundColor = [UIColor grayColor];
    
    self.reg_passwordField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 150, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.reg_passwordField.placeholder = @"密码(6位字母或数字)";
    self.reg_passwordField.returnKeyType = UIReturnKeyNext;
    self.reg_passwordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.reg_passwordField.delegate = self;
    [self.reg_passwordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.reg_passwordLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 180, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.reg_passwordLine.backgroundColor = [UIColor grayColor];
    
    self.reg_repasswordField = [[UITextField alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 200, bgRect.size.width - paddingEdge - paddingEdge, fieldHeight)];
    self.reg_repasswordField.placeholder = @"重复密码";
    self.reg_repasswordField.returnKeyType = UIReturnKeyDone;
    self.reg_repasswordField.keyboardType = UIKeyboardTypeASCIICapable;
    self.reg_repasswordField.delegate = self;
    [self.reg_repasswordField addTarget:self action:@selector(textDidChange:) forControlEvents:UIControlEventEditingChanged];
    
    self.reg_repasswordLine = [[UIView alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 230, bgRect.size.width - paddingEdge - paddingEdge, 1.f)];
    self.reg_repasswordLine.backgroundColor = [UIColor grayColor];
    
    self.sendRegExpBtn = [[UIButton alloc] initWithFrame:CGRectMake(paddingEdge, topPos + paddingTF2Line + fieldHeight + paddingLine2TF + fieldHeight + paddingTF2Line + paddingLine2TF + 250, bgRect.size.width - paddingEdge - paddingEdge, 36)];
    [self.sendRegExpBtn setBackgroundColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]];
    [self.sendRegExpBtn addTarget:self action:@selector(onSendRegBtn:) forControlEvents:UIControlEventTouchDown];
    //self.sendRegExpBtn.layer.masksToBounds = YES;
    self.sendRegExpBtn.layer.cornerRadius = 5.f;
    [self.sendRegExpBtn setTitle:@"注册" forState:UIControlStateNormal];
    self.sendRegExpBtn.enabled = YES;
    
    
    [self visibleRegComp:NO];
    [self.scroll addSubview:self.regExpBtn];
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    
    
    
    
    
    
    [self.scroll addSubview:self.rcodeBtn];
    [self.scroll addSubview:self.hintLabel];
    
    [self.scroll addSubview:self.userNameLine];
    [self.scroll addSubview:self.userNameField];
    
    [self.scroll addSubview:self.passwordLine];
    [self.scroll addSubview:self.passwordField];
    //[self.scroll addSubview:self.sendCodeBtn];
    
    [self.scroll addSubview:self.loginBtn];
    
    [self.view addSubview:self.scroll];/////
    
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    //////////////////////////////////////////////////
    
    
    self.userNameField.text = savedName;
    
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resetKeyboard:)]];
    
    self.privacyLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, self.view.bounds.size.height - 28 - kTabbarSafeBottomMargin, self.view.bounds.size.width-32, 28)];
    self.privacyLabel.textAlignment = NSTextAlignmentCenter;
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"登陆即代表你已同意《野火IM用户协议》和《野火IM隐私政策》" attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],NSForegroundColorAttributeName : [UIColor darkGrayColor]}];
    [text setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                          NSForegroundColorAttributeName : [UIColor blueColor]} range:NSMakeRange(9, 10)];
    [text setAttributes:@{NSFontAttributeName : [UIFont systemFontOfSize:10],
                          NSForegroundColorAttributeName : [UIColor blueColor]} range:NSMakeRange(20, 10)];
    self.privacyLabel.attributedText = text ;
    __weak typeof(self)ws = self;
    [self.privacyLabel yb_addAttributeTapActionWithRanges:@[NSStringFromRange(NSMakeRange(9, 8)), NSStringFromRange(NSMakeRange(18, 8))] tapClicked:^(UILabel *label, NSString *string, NSRange range, NSInteger index) {
        WFCPrivacyViewController * pvc = [[WFCPrivacyViewController alloc] init];
        pvc.isPrivacy = (range.location == 18);
        [ws.navigationController pushViewController:pvc animated:YES];
    }];
    
    //[self.scroll addSubview:self.privacyLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)visibleRegComp:(BOOL) b{
    if(b){
        [self.scroll addSubview:self.reg_userNameField];
        [self.scroll addSubview:self.reg_userNameLine];
        [self.scroll addSubview:self.reg_passwordField];
        [self.scroll addSubview:self.reg_passwordLine];
        [self.scroll addSubview:self.reg_repasswordField];
        [self.scroll addSubview:self.reg_repasswordLine];
        [self.scroll addSubview:self.sendRegExpBtn];
    }else{
        [self.reg_userNameField removeFromSuperview];
        [self.reg_userNameLine removeFromSuperview];
        [self.reg_passwordField removeFromSuperview];
        [self.reg_passwordLine removeFromSuperview];
        [self.reg_repasswordField removeFromSuperview];
        [self.reg_repasswordLine removeFromSuperview];
        [self.sendRegExpBtn removeFromSuperview];
    }
    //self.sendRegExpBtn.enabled = YES;
    CGSize _size = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height + 160);
    self.scroll.contentSize  = _size;
}


-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSCharacterSet *cs;
    cs = [[NSCharacterSet characterSetWithCharactersInString:ALPHANUM]invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs]componentsJoinedByString:@""];
    //按cs分离出数组,数组按@""分离出字符串
    BOOL canChange = [string isEqualToString:filtered];
    return canChange;
}


- (NSInteger)seq {
  return ++ seq;
}

/*
- (void)onSendCode:(id)sender {
    self.sendCodeBtn.enabled = NO;
    [self.sendCodeBtn setTitle:@"短信发送中" forState:UIControlStateNormal];
    __weak typeof(self)ws = self;
    [[AppService sharedAppService] sendCode:self.userNameField.text success:^{
       [ws sendCodeDone:YES];
    } error:^(NSString * _Nonnull message) {
        [ws sendCodeDone:NO];
    }];
}
*/
- (void)onExpRegContent:(id)sender {
    isHideReg = !isHideReg;
    [self visibleRegComp:isHideReg];
    
}
- (void)onOpenRcodeView:(id)sender {
    AppInitView *aiv = [AppInitView alloc];
    [aiv viewInit];
    [UIApplication sharedApplication].delegate.window.rootViewController = [aiv init];
    [aiv onLoadCenterConfig:^{
        [self alert:@"已切换邀请码，请重启APP。"];
        [UIApplication sharedApplication].delegate.window.rootViewController = self;
    }];
    [aiv displayChild];
}

/*
- (void)updateCountdown:(id)sender {
    int second = (int)([NSDate date].timeIntervalSince1970 - self.sendCodeTime);
    [self.sendCodeBtn setTitle:[NSString stringWithFormat:@"%ds", 60-second] forState:UIControlStateNormal];
    if (second >= 60) {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
        self.sendCodeBtn.enabled = YES;
    }
}

- (void)sendCodeDone:(BOOL)success {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (success) {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送成功";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            self.sendCodeTime = [NSDate date].timeIntervalSince1970;
            self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1
                                                                target:self
                                                                 selector:@selector(updateCountdown:)
                                                              userInfo:nil
                                                               repeats:YES];
            [self.countdownTimer fire];
            
            
            [hud hideAnimated:YES afterDelay:1.f];
        } else {
            MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
            hud.mode = MBProgressHUDModeText;
            hud.label.text = @"发送失败";
            hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
            [hud hideAnimated:YES afterDelay:1.f];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.sendCodeBtn setTitle:@"发送验证码" forState:UIControlStateNormal];
                self.sendCodeBtn.enabled = YES;
            });
        }
    });
}
*/
- (void)resetKeyboard:(id)sender {
    [self.userNameField resignFirstResponder];
    self.userNameLine.backgroundColor = [UIColor grayColor];
    [self.passwordField resignFirstResponder];
    self.passwordLine.backgroundColor = [UIColor grayColor];
    
    [self.reg_userNameField resignFirstResponder];
    [self.reg_passwordField resignFirstResponder];
    [self.reg_repasswordField resignFirstResponder];
}

-(void)alert:(NSString*) text{
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:text delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
    [alert show];
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

- (void)onLoginButton:(id)sender {
    NSString *user = self.userNameField.text;
    NSString *password = self.passwordField.text;
  
    if (!user.length || !password.length) {
        return;
    }
    
    [self resetKeyboard:nil];
    
  MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
  hud.label.text = @"登陆中...";
  [hud showAnimated:YES];
  
    
    NSString *url = [NSString stringWithFormat:@"%@%@", APP_SERVER_PHP, @"/yh/apilogin.php"];
    NSDictionary*dict = @{@"mobile":user, @"passwd":password, @"clientId":[[WFCCNetworkService sharedInstance] getClientId]};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:dict progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSString *_data = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
        //NSLog(@"%@-%@",[responseObject class], _data);
        if([_data isEqualToString:@"OK"]){
            NSLog(@"好的");
    
    
    
    
            [[AppService sharedAppService] login:user password:password success:^(NSString *userId, NSString *token, BOOL newUser) {
                [[NSUserDefaults standardUserDefaults] setObject:user forKey:@"savedName"];
                [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"savedToken"];
                [[NSUserDefaults standardUserDefaults] setObject:userId forKey:@"savedUserId"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                [[WFCCNetworkService sharedInstance] connect:userId token:token];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                  [hud hideAnimated:YES];
                    WFCBaseTabBarController *tabBarVC = [WFCBaseTabBarController new];
                    tabBarVC.newUser = newUser;
                    [UIApplication sharedApplication].delegate.window.rootViewController =  tabBarVC;
                });
                
                NSString *uidAlias = [WFCLoginViewController hexStringFromString:userId];
                uidAlias = [uidAlias uppercaseString];
                [JPUSHService
                    setAlias:uidAlias
                    completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                  
                    }
                    seq:[self seq]];
                
                
                
                
                
                
            } error:^(int errCode, NSString *message) {
                NSLog(@"login error with code %d, message %@", errCode, message);
              dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                hud.label.text = @"登陆失败";
                hud.offset = CGPointMake(0.f, MBProgressMaxOffset);
                [hud hideAnimated:YES afterDelay:1.f];
              });
            }];
            
            
            
            
            
            
            

                }
                if([_data isEqualToString:@"PWDERROR"]){
                    [hud hideAnimated:YES];
                    [self alert:@"用户名或密码错误"];
                }
            }
                  failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      [hud hideAnimated:YES];
                NSLog(@"--%@",error);
                [self alert:@"网络PHP密码登陆出错"];
            }];
    
    
    
    
}
//普通字符串转换为十六进制的。

+(NSString *)hexStringFromString:(NSString *)string{
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSString *hexStr=@"";
    for(int i=0;i<[myD length];i++)
    {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",bytes[i]&0xff];///16进制数
        if([newHexStr length]==1)
            hexStr = [NSString stringWithFormat:@"%@0%@",hexStr,newHexStr];
        else
            hexStr = [NSString stringWithFormat:@"%@%@",hexStr,newHexStr];
    }
    return hexStr;
}
- (void)onSendRegBtn:(id)sender {
    
    NSString *_user = self.reg_userNameField.text;
    NSString *_pass = self.reg_passwordField.text;
    NSString *_repass = self.reg_repasswordField.text;
    if(_user.length<=0){
        [self alert:@"用户名不能为空"];
        return;
    }
    if(_user.length<=5){
        [self alert:@"用户名长度要5位以上"];
        return;
    }
    if(_pass.length<=0 || _repass.length<=0){
        [self alert:@"密码或重复密码不能为空"];
        return;
    }
    if(_pass.length<=5 || _repass.length<=5){
        [self alert:@"密码长度要5位以上"];
        return;
    }
    if([_pass isEqualToString:_repass]==NO){
        [self alert:@"密码要和重复密码相同"];
        return;
    }
    

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.label.text = @"注册中...";
    [hud showAnimated:YES];
    NSString *url = [NSString stringWithFormat:@"%@%@", APP_SERVER_PHP, @"/yh/apireg.php"];
    NSDictionary*dict = @{@"mobile":_user, @"passwd":_pass, @"clientId":[[WFCCNetworkService sharedInstance] getClientId]};
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    //manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager GET:url parameters:dict progress:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            [hud hideAnimated:YES];
            NSString *_data = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
            NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(err){
                [self alert:@"JSON解析出错"];
                [self alert:jsonData];
            }
            if([dict[@"code"] intValue] == -11023) {
                [self alert:@"用户名已经存在"];
            }else if([dict[@"code"] intValue] == 0) {
                //[self alert:@"注册成功"];
                self.userNameField.text = _user;
                self.passwordField.text = _pass;
                [self onLoginButton:nil];
           
            }

     }    failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            [hud hideAnimated:YES];
            NSLog(@"--%@",error);
            [self alert:@"网络PHP注册出错"];
    }];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
    } else if(textField == self.passwordField) {
        [self onLoginButton:nil];
    }
    if(textField == self.reg_userNameField){
        [self.reg_passwordField becomeFirstResponder];
    }else if(textField == self.reg_passwordField){
        [self.reg_repasswordField becomeFirstResponder];
    }else if(textField == self.reg_repasswordField){
        [self onSendRegBtn:nil];
    }
    return NO;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.userNameField) {
        self.userNameLine.backgroundColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9];
        self.passwordLine.backgroundColor = [UIColor grayColor];
    } else if (textField == self.passwordField) {
        self.userNameLine.backgroundColor = [UIColor grayColor];
        self.passwordLine.backgroundColor = [UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9];
    }
    return YES;
}
#pragma mark - UITextInputDelegate
- (void)textDidChange:(id<UITextInput>)textInput {
    if (textInput == self.userNameField) {
        [self updateBtn];
    } else if (textInput == self.passwordField) {
        [self updateBtn];
    }
}

- (void)updateBtn {
    if ([self isValidNumber]) {
        if (!self.countdownTimer) {
            //self.sendCodeBtn.enabled = YES;
            //[self.sendCodeBtn setTitleColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9] forState:UIControlStateNormal];
        } else {
            //self.sendCodeBtn.enabled = NO;
            //[self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        }
        
        if ([self isValidCode]) {
            [self.loginBtn setBackgroundColor:[UIColor colorWithRed:0.1 green:0.27 blue:0.9 alpha:0.9]];
            self.loginBtn.enabled = YES;
        } else {
            [self.loginBtn setBackgroundColor:[UIColor grayColor]];
            self.loginBtn.enabled = NO;
        }
    } else {
        //self.sendCodeBtn.enabled = NO;
        //[self.sendCodeBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        [self.loginBtn setBackgroundColor:[UIColor grayColor]];
        self.loginBtn.enabled = NO;
    }
}

- (BOOL)isValidNumber {
    return YES;
    NSString * MOBILE = @"^((1[34578]))\\d{9}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    if (self.userNameField.text.length == 11 && ([regextestmobile evaluateWithObject:self.userNameField.text] == YES)) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)isValidCode {
    if (self.passwordField.text.length >= 4) {
        return YES;
    } else {
        return NO;
    }
}
@end
