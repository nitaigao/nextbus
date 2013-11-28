#import "FavoritesViewController.h"

#import "BusStop.h"

@interface FavoritesViewController () {
  NSArray* favorites;
}

@end

@implementation FavoritesViewController

- (id)initWithStyle:(UITableViewStyle)style {
  self = [super initWithStyle:style];
  
  if (self) {
  
  }
  
  return self;
}

- (void)viewWillAppear:(BOOL)animated {
  favorites = [BusStop allFavorites];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return favorites.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  cell.textLabel.text = @"Hello World!";
    
  return cell;
}

@end
