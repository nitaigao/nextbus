#import "MasterViewController.h"

#import "DetailViewController.h"

#import <RestKit/RestKit.h>
#import <RKXMLReaderSerialization.h>

#import "BusStop.h"
#import "BusStopListing.h"

@interface MasterViewController () {
  NSMutableArray *_stops;
  NSInteger _locationUpdates;
  CLLocationManager* locationManager;
}
@end

@implementation MasterViewController

- (void)awakeFromNib {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
      self.clearsSelectionOnViewWillAppear = NO;
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
    NSURL* host = [NSURL URLWithString:@"http://countdown.tfl.gov.uk"];
    
    RKObjectManager* objectManager = [RKObjectManager managerWithBaseURL:host];//[NSURL URLWithString:@"http://localhost:4567"]];
    [RKObjectManager setSharedManager:objectManager];
    
    [RKMIMETypeSerialization registerClass:[RKXMLReaderSerialization class] forMIMEType:@"text/xml"];
    [[RKObjectManager sharedManager] setAcceptHeaderWithMIMEType:RKMIMETypeTextXML];
  }
  
  {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
  }
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation {
  if (++_locationUpdates == 5) {
    
    RKObjectMapping* stopMapping = [RKObjectMapping mappingForClass:[BusStop class]];
    [stopMapping addAttributeMappingsFromDictionary:@{@"name": @"name"}];
    [stopMapping addAttributeMappingsFromDictionary:@{@"smsCode": @"id"}];
    [stopMapping addAttributeMappingsFromDictionary:@{@"direction": @"direction"}];
    [stopMapping addAttributeMappingsFromDictionary:@{@"lng": @"longitude"}];
    [stopMapping addAttributeMappingsFromDictionary:@{@"lat": @"latitude"}];
    
    
    float swLat = newLocation.coordinate.latitude - 0.01;
    float swLng = newLocation.coordinate.longitude - 0.01;
    float neLat = newLocation.coordinate.latitude + 0.01;
    float neLng = newLocation.coordinate.longitude + 0.01;
    
    NSString* pathPattern = [NSString stringWithFormat:@"/markers/swLat/%f/swLng/%f/neLat/%f/neLng/%f/", swLat, swLng, neLat, neLng];
    
    RKResponseDescriptor *stopDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:stopMapping
                                                                                        method:RKRequestMethodGET
                                                                                   pathPattern:pathPattern
                                                                                       keyPath:@"markers"
                                                                                   statusCodes:[NSIndexSet indexSetWithIndex:200]];
    
    [[RKObjectManager sharedManager] addResponseDescriptor:stopDescriptor];
    
    [[RKObjectManager sharedManager] getObjectsAtPath:pathPattern
                                           parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                             NSArray* results = [mappingResult array];
                                             [_stops addObjectsFromArray:results];
                                             [self.tableView reloadData];
                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                             NSLog(@"Load failed");
                                           }];
  }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _stops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

  BusStop* stop = _stops[indexPath.row];
  NSString* direction = [NSString stringWithFormat:@"(%@)", stop.direction];
  
  NSInteger spacesLeft = 4 - direction.length;
  
  for (int i = 0; i < spacesLeft; i++) {
    direction = [direction stringByAppendingString:@"  "];
  }

  cell.textLabel.text = [NSString stringWithFormat:@"%@ %@", direction, stop.name];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    BusStop* stop = _stops[indexPath.row];
    self.detailViewController.detailItem = stop;
  }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    BusStop* stop = _stops[indexPath.row];
    [[segue destinationViewController] setDetailItem:stop];
  }
}

@end
