#import <UIKit/UIKit.h>

@class MMDrawerController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController* centerController;
@property (strong, nonatomic) MMDrawerController* drawerController;

@end
