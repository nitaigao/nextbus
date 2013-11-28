#import <UIKit/UIKit.h>

#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@class DetailViewController;
@class MMDrawerController;

@interface MasterViewController : UIViewController<CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) IBOutlet MKMapView* mapView;
@property (strong, nonatomic) DetailViewController *detailViewController;
@property (strong, nonatomic) MMDrawerController* drawerController;

@end
