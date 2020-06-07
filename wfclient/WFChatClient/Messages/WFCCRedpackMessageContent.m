
#import "WFCCRedpackMessageContent.h"
#import "WFCCIMService.h"
#import "Common.h"

@implementation WFCCRedpackMessageContent
- (WFCCMessagePayload *)encode {
    WFCCMessagePayload *payload = [super encode];
    
    payload.contentType = [self.class getContentType];
    payload.searchableContent = self.text;
    payload.mentionedType = self.mentionedType;
    payload.mentionedTargets = self.mentionedTargets;
    return payload;
}

- (void)decode:(WFCCMessagePayload *)payload {
    [super decode:payload];
    
    
    NSString *_data = payload.searchableContent;
    NSData *jsonData = [_data dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    self.dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    
    NSString *str;
    if(err){
        str = @"错误红包";
    }else{
        str = self.dict[@"desc"];
    }
    
    self.text = str;//payload.searchableContent;
    self.mentionedType = payload.mentionedType;
    self.mentionedTargets = payload.mentionedTargets;
    
}

+ (int)getContentType {
    return MESSAGE_CONTENT_TYPE_REDPACK;
}

+ (int)getContentFlags {
    return WFCCPersistFlag_PERSIST_AND_COUNT;
}

+ (instancetype)contentWith:(NSString *)text {
    WFCCRedpackMessageContent *content = [[WFCCRedpackMessageContent alloc] init];
    content.text = text;
    return content;
}

+ (void)load {
    [[WFCCIMService sharedWFCIMService] registerMessageContent:self];
}

- (NSString *)digest:(WFCCMessage *)message {
  return @"[红包]";
}
@end
