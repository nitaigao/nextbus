#import "MasterViewController.h"

#import "DetailViewController.h"

#import <RestKit/RestKit.h>
#import <RKXMLReaderSerialization.h>

#import "BusStop.h"
#import "BusStopListing.h"

#import "MapAnnotation.h"

#import "BusStopAnnotation.h"

@interface MasterViewController () {
  NSMutableArray *_stops;
  NSInteger _locationUpdates;
  CLLocationManager* locationManager;
}
@end

@implementation MasterViewController

@synthesize mapView;

- (void)awakeFromNib {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
//      self.clearsSelectionOnViewWillAppear = NO;
      self.preferredContentSize = CGSizeMake(320.0, 600.0);
  }
  
  [super awakeFromNib];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
  _stops = [[NSMutableArray alloc] init];
  _locationUpdates = 0;
  
  {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.507222,-0.1275);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:zoomRegion animated:NO];
  }
  
  {
    NSURL* host = [NSURL URLWithString:@"http://countdown.tfl.gov.uk"];
    
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:host];//[NSURL URLWithString:@"http://localhost:4567"]];
    [RKObjectManager setSharedManager:objectManager];
    
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
  }

  {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
#ifndef TARGET_IPHONE_SIMULATOR
    [locationManager startUpdatingLocation];
#endif
  }
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated {
  [self refreshMap:theMapView.region.center];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(BusStopAnnotation*)annotation {
  MKAnnotationView *annotationView =  [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BusStop"];
  
  UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
  button.frame = CGRectMake(0, 0, 23, 23);
  button.tag = [_stops indexOfObject:annotation.busStop];
  [button addTarget:self action:@selector(stopSelected:) forControlEvents:UIControlEventTouchUpInside];
  annotationView.rightCalloutAccessoryView = button;
  
  annotationView.canShowCallout = YES;
  
  return annotationView;
}

- (void)stopSelected:(id)sender {
  [self performSegueWithIdentifier:@"showDetail" sender:sender];
}

- (void)refreshMap:(CLLocationCoordinate2D)position {
  // meters a way = 111km in a degree
  float metersToDegrees = 1.0f / 111000.0f;
  
  float degreesDelta = 300.0f * metersToDegrees;
  float swLat = position.latitude - degreesDelta;
  float swLng = position.longitude - degreesDelta;
  float neLat = position.latitude + degreesDelta;
  float neLng = position.longitude + degreesDelta;

  
  NSString* pathPattern = [NSString stringWithFormat:@"/markers/swLat/%f/swLng/%f/neLat/%f/neLng/%f/", swLat, swLng, neLat, neLng];
  
  RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[BusStop class]];
  [stopMapping addAttributeMappingsFromDictionary:@{@"name": @"name"}];
  [stopMapping addAttributeMappingsFromDictionary:@{@"smsCode": @"id"}];
  [stopMapping addAttributeMappingsFromDictionary:@{@"direction": @"direction"}];
  [stopMapping addAttributeMappingsFromDictionary:@{@"lng": @"longitude"}];
  [stopMapping addAttributeMappingsFromDictionary:@{@"lat": @"latitude"}];
  [stopMapping addAttributeMappingsFromDictionary:@{@"stopIndicator": @"indicator"}];
  
  RKResponseDescriptor *stopDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stopMapping
                                                                                      method:RKRequestMethodGET
                                                                                 pathPattern:pathPattern
                                                                                     keyPath:@"markers"
                                                                                 statusCodes:[NSIndexSet indexSetWithIndex:200]];
  
  [[RKObjectManager sharedManager] addResponseDescriptor:stopDescriptor];
  
  [[RKObjectManager sharedManager] getObjectsAtPath:pathPattern
                                         parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                           NSArray* results = [mappingResult array];
                                           [_stops removeAllObjects];
                                           [_stops addObjectsFromArray:results];
                                           
                                           for (id annotation in mapView.annotations) {
                                             [mapView removeAnnotation:annotation];
                                           }
                                           
                                           for (BusStop* stop in _stops) {
                                             CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(stop.latitude, stop.longitude);
                                             NSString* title = stop.indicator ? [NSString stringWithFormat:@"%@ - %@", stop.indicator, stop.name] : stop.name;
                                             BusStopAnnotation* annotation = [[BusStopAnnotation alloc] initWithCoordinate:coordinate andTitle:title andBusStop:stop];
                                             [mapView addAnnotation:annotation];
                                           }
                                           
                                         } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                           NSLog(@"Load failed");
                                         }];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  if (++_locationUpdates == 2) {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:zoomRegion animated:NO];
    
    [self refreshMap:coordinate];
  }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    BusStop* stop = _stops[indexPath.row];
    self.detailViewController.detailItem = stop;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  UIButton* button = (UIButton*)sender;
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    BusStop* stop = _stops[button.tag];
    [[segue destinationViewController] setDetailItem:stop];
  }
}

@end
