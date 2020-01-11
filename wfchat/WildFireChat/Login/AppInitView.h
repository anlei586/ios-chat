
#import <UIKit/UIKit.h>

@interface AppInitView : UITabBarController
-(void) displayChild;
-(void)onLoadCenterConfig:(void(^)())testBlock;
@end
