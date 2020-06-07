
#import "WFCCMessageContent.h"
#import "WFCCMediaMessageContent.h"
#import <UIKit/UIKit.h>

/**
 文本消息
 */
@interface WFCCRedpackMessageContent : WFCCMediaMessageContent

/**
 缩略图，自动生成
 */
@property (nonatomic, strong)UIImage *thumbnail;

/**
 图片尺寸
 */
@property (nonatomic, assign, readonly)CGSize size;





/**
 @param text 文本
 @return 文本消息
 */
+ (instancetype)contentWith:(NSString *)text;

/**
 文本内容
 */
@property (nonatomic, strong)NSString *text;

@property (nonatomic, strong)NSDictionary *dict;

/**
 提醒类型，1，提醒部分对象（mentinedTarget）。2，提醒全部。其他不提醒
 */
@property (nonatomic, assign)int mentionedType;

/**
 提醒对象，mentionedType 1时有效
 */
@property (nonatomic, strong)NSArray<NSString *> *mentionedTargets;
@end
