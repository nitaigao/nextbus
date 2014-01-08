#import "MasterViewController.h"

#import "DetailViewController.h"

#import <RestKit/RestKit.h>
#import <RKXMLReaderSerialization.h>

#import "BusStop.h"
#import "BusStopButton.h"
#import "BusStopListing.h"

#import "MapAnnotation.h"

#import "BusStopAnnotation.h"

#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>

@interface MasterViewController () {
  NSInteger _locationUpdates;
  CLLocationManager* locationManager;
}
@end

@implementation MasterViewController

@synthesize mapView, drawerController;

- (void)leftDrawerButtonPress:(id)sender {
  [self.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
  [self.navigationItem setLeftBarButtonItem:leftDrawerButton animated:YES];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findUser) name:UIApplicationDidBecomeActiveNotification object:nil];
  
  self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
  
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
  }
  
  {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(51.507222,-0.1275);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.3, 0.3);
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:zoomRegion animated:NO];
  }
}

- (void)findUser {
  
  {
    _locationUpdates = 0;
  }
  
  {
    [locationManager startUpdatingLocation];
  }
}

- (void)mapView:(MKMapView *)theMapView regionDidChangeAnimated:(BOOL)animated {
  if (_locationUpdates >= 2) {
    [self refreshMap:theMapView.region.center];
  }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
  if([annotation isKindOfClass:[BusStopAnnotation class]]) {
    MKPinAnnotationView* annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BusStop"];
    
    BusStopAnnotation* stopAnnotation = (BusStopAnnotation*)annotation;
    
    BusStopButton *button = [BusStopButton buttonWithBusStop:stopAnnotation.busStop];
    
    [button addTarget:self action:@selector(stopSelected:) forControlEvents:UIControlEventTouchUpInside];
    annotationView.rightCalloutAccessoryView = button;
    annotationView.animatesDrop = YES;
    annotationView.canShowCallout = YES;
    
    return annotationView;
  }
  
  return nil;
}

- (void)stopSelected:(id)sender {
  [self performSegueWithIdentifier:@"showDetail" sender:sender];
}

- (void)refreshMap:(CLLocationCoordinate2D)position {
  // meters a way = 111km in a degree
  float metersToDegrees = 1.0f / 111000.0f;
  
  float degreesDelta = 1000.0f * metersToDegrees;
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
                                         parameters:nil
                                            success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                              NSArray* results = [mappingResult array];
                                              
                                              for (BusStop* stop in results) {
                                                BOOL foundStop = false;
                                                
                                                for (BusStopAnnotation* annotation in mapView.annotations) {
                                                  if ([annotation isKindOfClass:[BusStopAnnotation class]]) {
                                                    if (annotation.busStop.latitude == stop.latitude &&
                                                       annotation.busStop.longitude == stop.longitude) {
                                                      foundStop = true;
                                                      break;
                                                    }
                                                  }
                                                }
                                                
                                                if (!foundStop) {
                                                  CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(stop.latitude, stop.longitude);
                                                  NSString* title = stop.indicator ? [NSString stringWithFormat:@"%@ - %@", stop.indicator, stop.name] : stop.name;
                                                  BusStopAnnotation* annotation = [[BusStopAnnotation alloc] initWithCoordinate:coordinate andTitle:title andBusStop:stop];
                                                  [mapView addAnnotation:annotation];
                                                }
                                              }
                                              } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                              NSLog(@"Load failed");
                                              }];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  if (++_locationUpdates == 2) {

    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    
    {
      NSArray* favorites = [BusStop allFavorites];
      
      for (BusStop* stop in favorites) {
        float userDistanceFromStop = [stop distanceFromLocation:CGPointMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude)];
        if (userDistanceFromStop < 0.001f) {
          coordinate = CLLocationCoordinate2DMake(stop.latitude, stop.longitude);
          span = MKCoordinateSpanMake(0.001, 0.001);
          
          CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(stop.latitude, stop.longitude);
          NSString* title = stop.indicator ? [NSString stringWithFormat:@"%@ - %@", stop.indicator, stop.name] : stop.name;
          BusStopAnnotation* annotation = [[BusStopAnnotation alloc] initWithCoordinate:coordinate andTitle:title andBusStop:stop];
          [mapView addAnnotation:annotation];
          
          break;
        }
      }
    }

    {
      MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(coordinate, span);
      [mapView setRegion:zoomRegion animated:YES];
      [self refreshMap:coordinate];
    }
      
    [locationManager stopUpdatingLocation];
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  BusStopButton* button = (BusStopButton*)sender;
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    [[segue destinationViewController] setDetailItem:button.busStop];
  }
}

@end
