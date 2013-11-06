#import "DetailViewController.h"

#import <RestKit/RestKit.h>

#import "BusStop.h"
#import "BusStopListing.h"

@interface DetailViewController () {
  NSMutableArray *_listings;
}

@property (strong, nonatomic) UIPopoverController *masterPopoverController;

- (void)configureView;

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    NSString* pathPattern = [NSString stringWithFormat:@"/stopBoard/%@/", _detailItem.id];

    
    {
      RKObjectMapping* listingMapping = [RKObjectMapping mappingForClass:[BusStopListing class]];
      [listingMapping addAttributeMappingsFromDictionary:@{@"destination": @"destination"}];
      [listingMapping addAttributeMappingsFromDictionary:@{@"scheduledTime": @"time"}];
      
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
                                                 for (BusStopListing* listing in _listings) {
                                                   NSLog(@"%@", listing.destination);
                                                 }
                                             } failure:^(RKObjectRequestOperation *operation, NSError *error) {
                                               NSLog(@"Load failed");
                                             }];
      
      
    }


    [self configureView];
    
    
    
  }

  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }        
}

- (void)configureView {
  if (self.detailItem) {
    self.detailDescriptionLabel.text = self.detailItem.id;
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
