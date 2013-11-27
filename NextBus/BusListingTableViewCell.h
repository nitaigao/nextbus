#import <UIKit/UIKit.h>

@interface BusListingTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel* route;
@property (nonatomic, strong) IBOutlet UILabel* destination;
@property (nonatomic, strong) IBOutlet UILabel* wait;

@end
