//
//  Config.m
//  Wildfire Chat
//
//  Created by WF Chat on 2017/10/21.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import "WFCConfig.h"
#import "AppDelegate.h"

NSInteger *RCODE_ONF = 0;
NSString *RCODE_IDK = @"1011";
//NSString *CENTER_URL = @"https://apple.6b6.me/apple.json";
NSString *CENTER_URL = @"https://apple2.6b6.me/apple.json";

//请到AppDelegate.m修改端口，Info.plist修改domain or ip

//可以是IP，可以是域名，如果是域名的话只支持主域名或www域名，二级域名不支持！
//例如：example.com或www.example.com是支持的；xx.example.com或xx.yy.example.com是不支持的。
NSString *IM_SERVER_HOST = @"";//@"110.34.181.127";
//最好是80，如果是其他端口，七牛云存储将不被支持。
int IM_SERVER_PORT = 80;
//正式商用时，建议用https，确保token安全
NSString *APP_SERVER_ADDRESS = @"";//@"http://110.34.181.127:8888";
NSString *APP_SERVER_PHP = @"";//@"http://110.34.181.127:81";

NSString *ICE_ADDRESS = @"turn:turn.wildfirechat.cn:3478";
NSString *ICE_USERNAME = @"wfchat";
NSString *ICE_PASSWORD = @"wfchat";

NSString *jg_channel = @"default_developer";
NSString *jg_appKey = @"b5e48e765391b87f904e1461";
//NSString *jg_appKey = @"7843e27741cce9ebe6c090fc";
