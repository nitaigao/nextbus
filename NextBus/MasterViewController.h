#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class DetailViewController;

@interface MasterViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>// UITableViewController<CLLocationManagerDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) DetailViewController *detailViewController;

@end
