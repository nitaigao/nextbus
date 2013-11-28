#import "FavoritesViewController.h"

#import <MMDrawerController/MMDrawerController.h>
#import <MMDrawerController/MMDrawerBarButtonItem.h>

#import "BusStop.h"

@interface FavoritesViewController () {
  NSMutableArray* favoriteStops;
}

@end

@implementation FavoritesViewController

@synthesize drawerController;

- (id)init {
  self = [super init];
  if (self) {
    favoriteStops = [NSMutableArray array];
  }
  return self;
}

- (void)leftDrawerButtonPress:(id)sender {
  [self.drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (void)viewDidLoad {
  MMDrawerBarButtonItem* leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
  self.navigationItem.leftBarButtonItem = leftDrawerButton;
}

- (void)viewWillAppear:(BOOL)animated {
  [favoriteStops removeAllObjects];
  
  NSArray* stops = [BusStop allFavorites];
  [favoriteStops addObjectsFromArray:stops];
  
  [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return favoriteStops.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  BusStop* stop = [favoriteStops objectAtIndex:indexPath.row];
  cell.textLabel.text = stop.name;
  
  return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
  return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    BusStop* stop =[favoriteStops objectAtIndex:indexPath.row];
    [BusStop deleteFavorite:stop];
    
    [favoriteStops removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) { }
}

@end
