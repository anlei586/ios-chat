
#import <UIKit/UIKit.h>

@interface AppInitView : UITabBarController
-(void) displayChild;
-(void) viewInit;
-(void)onLoadCenterConfig:(void(^)())testBlock;
@end
