#import <UIKit/UIKit.h>

@class MMDrawerController;
@class FavoritesViewController;

@interface LeftBarViewController : UITableViewController<UITableViewDelegate>

@property (nonatomic, strong) MMDrawerController* drawController;

@property (nonatomic, strong) UINavigationController* favoritesViewController;
@property (nonatomic, strong) UINavigationController* mapViewController;

@end
