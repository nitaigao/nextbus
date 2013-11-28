#import "AppDelegate.h"

#import <MMDrawerController/MMDrawerController.h>

#import "MasterViewController.h"

@implementation AppDelegate

@synthesize drawerController, centerController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//    Sliding Drawer
  {
    UIViewController * leftSideDrawerViewController = [[UIViewController alloc] init];
    UINavigationController * leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
    
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:navigationController
                             leftDrawerViewController:leftSideNavController];
    
    MasterViewController* masterController = (MasterViewController*)navigationController.visibleViewController;;
    masterController.drawerController = self.drawerController;
    
    [self.drawerController setShowsShadow:YES];
    [self.drawerController setCloseDrawerGestureModeMask:MMCloseDrawerGestureModeAll];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window setRootViewController:self.drawerController];
  }

//  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//    UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
//    UINavigationController *navigationController = [splitViewController.viewControllers lastObject];
//    splitViewController.delegate = (id)navigationController.topViewController;
//  }
  
  return YES;
}

@end
