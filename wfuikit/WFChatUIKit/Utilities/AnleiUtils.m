//
//  AnleiUtils.m
//  WFChatUIKit
//
//  Created by anlei on 2019/11/4.
//  Copyright © 2019 Tom Lee. All rights reserved.
//

#import <WFChatUIKit/WFChatUIKit.h>
#import "AnleiUtils.h"

@implementation AnleiUtils

static NSDictionary *apiclient;

+(NSDictionary*) getApiClient{
    return apiclient;
}
+(void) setApiClient:(NSDictionary*)dict{
    apiclient = dict;
}

@end
