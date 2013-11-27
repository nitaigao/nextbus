#import "DetailViewController.h"

#import <RestKit/RestKit.h>

#import "BusStop.h"
#import "BusStopListing.h"

#import "MapAnnotation.h"

@interface DetailViewController () {
  NSMutableArray *_listings;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation DetailViewController

@synthesize mapView, listingsTableView, titleNavigationItem;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    [self configureView];
  }

  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }        
}

- (void)viewWillAppear:(BOOL)animated {
  {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_detailItem.latitude, _detailItem.longitude);
    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:coordinate];
    [mapView addAnnotation:annotation];
  }
  
  {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_detailItem.latitude, _detailItem.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(0.01, 0.01);
    MKCoordinateRegion zoomRegion = MKCoordinateRegionMake(coordinate, span);
    [mapView setRegion:zoomRegion animated:NO];
  }
  {
    NSString* pathPattern = [NSString stringWithFormat:@"/stopBoard/%@/", _detailItem.id];
    
    
    {
      RKObjectMapping* listingMapping = [RKObjectMapping mappingForClass:[BusStopListing class]];
      [listingMapping addAttributeMappingsFromDictionary:@{@"destination": @"destination"}];
      [listingMapping addAttributeMappingsFromDictionary:@{@"scheduledTime": @"time"}];
      [listingMapping addAttributeMappingsFromDictionary:@{@"routeName": @"route"}];
      [listingMapping addAttributeMappingsFromDictionary:@{@"estimatedWait": @"wait"}];
      
      RKResponseDescriptor *listingDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:listingMapping
                                                                                             method:RKRequestMethodGET
                                                                                        pathPattern:pathPattern
                                                                                            keyPath:@"arrivals"
                                                                                        statusCodes:[NSIndexSet indexSetWithIndex:200]];
      
      [[RKObjectManager sharedManager] addResponseDescriptor:listingDescriptor];
      
    }
    
    {
      [[RKObjectManager sharedManager] getObjectsAtPath:pathPattern
                                             parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                               NSArray* results = [mappingResult array];
                                               [_listings addObjectsFromArray:results];
                                               [listingsTableView reloadData];
                                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               NSLog(@"Load failed");
                                             }];
      
      
    }
    
    {
      titleNavigationItem.title = _detailItem.name;
    }

  }
}

- (void)configureView {
  if (self.detailItem) {

  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _listings = [NSMutableArray array];
  [self configureView];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _listings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  BusStopListing* listing = [_listings objectAtIndex:indexPath.row];
  cell.textLabel.text = [NSString stringWithFormat:@"%@ %@ %@", listing.route, listing.destination, listing.wait];
  
  return cell;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController {
  barButtonItem.title = NSLocalizedString(@"Master", @"Master");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

@end
