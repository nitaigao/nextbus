#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;

@end
