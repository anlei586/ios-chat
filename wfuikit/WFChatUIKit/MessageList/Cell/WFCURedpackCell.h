
#import "WFCUMessageCell.h"
#import "WFCUMediaMessageCell.h"

//@interface WFCURedpackCell : WFCUMessageCell
@interface WFCURedpackCell : WFCUMediaMessageCell
@property (strong, nonatomic)UILabel *textLabel;
@property (nonatomic, strong)UIImageView *thumbnailView;
@end
