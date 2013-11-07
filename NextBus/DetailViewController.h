#import <UIKit/UIKit.h>

#import "MapKit/MapKit.h"

@class BusStop;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) BusStop* detailItem;

@property (weak, nonatomic) IBOutlet MKMapView* mapView;
@property (weak, nonatomic) IBOutlet UITableView* listingsTableView;
@property (weak, nonatomic) IBOutlet UINavigationItem* titleNavigationItem;

@end
