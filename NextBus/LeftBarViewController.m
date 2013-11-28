#import "LeftBarViewController.h"

#import <MMDrawerController/MMDrawerController.h>

#import "FavoritesViewController.h"

@implementation LeftBarViewController

@synthesize drawController, favoritesViewController, mapViewController;

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  switch (indexPath.row) {
    case 0:
        cell.textLabel.text = @"Stops";
      break;
    case 1:
        cell.textLabel.text = @"Favorites";
      break;
    default:
      break;
  }
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.row == 0) {
    [self.drawController setCenterViewController:self.mapViewController withCloseAnimation:YES completion:nil];
  }

  if (indexPath.row == 1) {
    [self.drawController setCenterViewController:self.favoritesViewController withCloseAnimation:YES completion:nil];
  }
  
  [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end