//
//  AppDelegate.h
//  WildFireChat
//
//  Created by WF Chat on 2017/11/5.
//  Copyright © 2017年 WildFireChat. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+(NSString*)getMFS_hu;
+(NSString*)getMFS_http;
+(NSString*)getMFS_url;

+(void)setMFS_http:(NSString*)str;
+(void)setMFS_url:(NSString*)str;
+(void)setMFS_port:(NSString*)str;
    
@end

