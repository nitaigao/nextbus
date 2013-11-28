#import "AppDelegate.h"

#import <MMDrawerController/MMDrawerController.h>

#import "LeftBarViewController.h"

#import "FavoritesViewController.h"
#import "MasterViewController.h"

@implementation AppDelegate

@synthesize drawerController, centerController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  {
    FavoritesViewController* favoritesViewController = [[FavoritesViewController alloc] init];
    UINavigationController* favoritesController = [[UINavigationController alloc] initWithRootViewController:favoritesViewController];

    LeftBarViewController* leftSideDrawerViewController = [[LeftBarViewController alloc] init];
    leftSideDrawerViewController.favoritesViewController = favoritesController;
    
    UINavigationController* leftSideNavController = [[UINavigationController alloc] initWithRootViewController:leftSideDrawerViewController];
    
    UINavigationController* navigationController = (UINavigationController*)self.window.rootViewController;
    
    self.drawerController = [[MMDrawerController alloc]
                             initWithCenterViewController:navigationController
                             leftDrawerViewController:leftSideNavController];
    
    leftSideDrawerViewController.drawController = self.drawerController;
    
    MasterViewController* masterController = (MasterViewController*)navigationController.visibleViewController;;
    masterController.drawerController = self.drawerController;
    favoritesViewController.drawerController = self.drawerController;
    leftSideDrawerViewController.mapViewController = masterController.navigationController;
    
    [self.drawerController setShowsShadow:NO];
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
