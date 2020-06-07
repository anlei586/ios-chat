
#import "WFCURedpackCell.h"
#import <WFChatClient/WFCChatClient.h>
#import "WFCUUtilities.h"
#import "AttributedLabel.h"
#import "WFCUConfigManager.h"
#import "WFCUBrowserViewController.h"

#define TEXT_LABEL_TOP_PADDING 3
#define TEXT_LABEL_BUTTOM_PADDING 5

@interface WFCURedpackCell () <AttributedLabelDelegate>

@end

@implementation WFCURedpackCell
+ (CGSize)sizeForClientArea:(WFCUMessageModel *)msgModel withViewWidth:(CGFloat)width {
  WFCCRedpackMessageContent *txtContent = (WFCCRedpackMessageContent *)msgModel.message.content;
    CGSize size = CGSizeMake(120, 120);
    if(txtContent.thumbnail) {
        size = txtContent.thumbnail.size;
    } else {
        size = [WFCCUtilities imageScaleSize:txtContent.size targetSize:CGSizeMake(120, 120) thumbnailPoint:nil];
    }
    
    
    if (size.height > width || size.width > width) {
        float scale = MIN(width/size.height, width/size.width);
        size = CGSizeMake(size.width * scale, size.height * scale);
    }
    return size;
}

- (void)setModel:(WFCUMessageModel *)model {
  [super setModel:model];
    
  WFCCRedpackMessageContent *txtContent = (WFCCRedpackMessageContent *)model.message.content;
    CGRect frame = self.contentArea.bounds;
    self.textLabel.frame = CGRectMake(0, TEXT_LABEL_TOP_PADDING, frame.size.width, 220);
    self.textLabel.textAlignment = NSTextAlignmentCenter;
    [self.textLabel setText:txtContent.text];
    
    
    UIImage *img = [UIImage imageNamed:@"chat_input_plugin_redpack"];
    self.bubbleView.image = img;//txtContent.thumbnail;
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onClickImageView)];
    [self.bubbleView addGestureRecognizer:singleTap];
    
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [[UIImageView alloc] init];
        [self.contentArea addSubview:_thumbnailView];
    }
    return _thumbnailView;
}

-(void)onClickImageView{

    
    WFCCRedpackMessageContent *txtContent = (WFCCRedpackMessageContent *)super.model.message.content;
    NSString *rpid = txtContent.dict[@"id"];
    
    WFCCConversation *conversation =(WFCCConversation *)super.model.message.conversation;
    
    int *cline = conversation.line;
    WFCCConversationType *type = conversation.type;
    NSString *ctarget=conversation.target;
    
    NSString *ctype = @"";
    if(type==Single_Type){
        ctype = @"Single";
    }else if(type==Group_Type){
        ctype = @"Group";
    }
    
    NSString *clientId = [[WFCCNetworkService sharedInstance] getClientId];
    NSString *userId =[[WFCCNetworkService sharedInstance] userId];
    
    
    NSDictionary *dict = [WFCUConfigManager getApiClient];
    NSString *url = dict[@"openredpack"];
    
    
    
    url = [NSString stringWithFormat:@"%@%@", url, @"?cid="];
    url = [NSString stringWithFormat:@"%@%@", url, clientId];
    url = [NSString stringWithFormat:@"%@%@", url, @"&uid="];
    url = [NSString stringWithFormat:@"%@%@", url, userId];
    url = [NSString stringWithFormat:@"%@%@", url, @"&rpid="];
    url = [NSString stringWithFormat:@"%@%@", url, rpid];
    url = [NSString stringWithFormat:@"%@%@", url, @"&ctype="];
    url = [NSString stringWithFormat:@"%@%@", url, ctype];
    url = [NSString stringWithFormat:@"%@%@", url, @"&ctarget="];
    url = [NSString stringWithFormat:@"%@%@", url, ctarget];
    url = [NSString stringWithFormat:@"%@%@", url, @"&cline="];
    url = [NSString stringWithFormat:@"%@%@", url, cline];
    
    
    
    WFCUBrowserViewController *bvc = [[WFCUBrowserViewController alloc] init];
    bvc.url = url;
    
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:bvc];
    
    //[[UIApplication sharedApplication].keyWindow.rootViewController
    
    UINavigationController *navi = [UIApplication sharedApplication].keyWindow.rootViewController;
    [navi presentViewController:nav animated:NO completion:^{
        [bvc removeRightItem];
    }];
    
}

- (UILabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[AttributedLabel alloc] init];
        //((AttributedLabel*)_textLabel).attributedLabelDelegate = self;
        _textLabel.numberOfLines = 1;
        _textLabel.font = [UIFont systemFontOfSize:12];
        _textLabel.textColor = [UIColor whiteColor];
        //_textLabel.userInteractionEnabled = YES;
        [self.contentArea addSubview:_textLabel];
    }
    return _textLabel;
}
#pragma mark - AttributedLabelDelegate
- (void)didSelectUrl:(NSString *)urlString {
    [self.delegate didSelectUrl:self withModel:self.model withUrl:urlString];
}
- (void)didSelectPhoneNumber:(NSString *)phoneNumberString {
    [self.delegate didSelectPhoneNumber:self withModel:self.model withPhoneNumber:phoneNumberString];
}
@end
