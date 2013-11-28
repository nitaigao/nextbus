#import "DetailViewController.h"

#import <RestKit/RestKit.h>

#import "BusStop.h"
#import "BusStopListing.h"
#import "BusListingTableViewCell.h"

#import "MapAnnotation.h"

@interface DetailViewController () {
  NSMutableArray *_listings;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation DetailViewController

@synthesize mapView, listingsTableView, titleNavigationItem;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
  }

  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }        
}

- (void)viewWillAppear:(BOOL)animated {
  {
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(_detailItem.latitude, _detailItem.longitude);
    MapAnnotation* annotation = [[MapAnnotation alloc] initWithCoordinate:coordinate andTitle:_detailItem.indicator];
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
      titleNavigationItem.title = [NSString stringWithFormat:@"%@ - %@", _detailItem.indicator, _detailItem.name];
    }
    
    [self refreshStops:nil];
  }
}

- (void)refreshStops:(NSTimer*)timer {
  if (self.navigationController.topViewController == self) {
    NSString* pathPattern = [NSString stringWithFormat:@"/stopBoard/%@/", _detailItem.id];
    [[RKObjectManager sharedManager] getObjectsAtPath:pathPattern
                                           parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
                                             NSArray* results = [mappingResult array];
                                             [_listings removeAllObjects];
                                             [_listings addObjectsFromArray:results];
                                             [listingsTableView reloadData];
                                           } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                             NSLog(@"Load failed");
                                           }];
  
    [NSTimer scheduledTimerWithTimeInterval:30 target:self selector:@selector(refreshStops:) userInfo:nil repeats:NO];
  }
}

- (void)viewDidLoad {
  [super viewDidLoad];
  _listings = [NSMutableArray array];
  self.navigationController.navigationItem.rightBarButtonItem.image = [[UIImage imageNamed:@"favorite.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return _listings.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  BusListingTableViewCell* cell = (BusListingTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
  
  BusStopListing* listing = [_listings objectAtIndex:indexPath.row];
  
  cell.route.text = listing.route;
  cell.wait.text = listing.wait;
  cell.destination.text = listing.destination;
  
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

- (IBAction)addFavorite:(id)sender {
  [self.detailItem saveFavorite];
}

@end
