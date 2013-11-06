#import <UIKit/UIKit.h>

@class BusStop;

@interface DetailViewController : UIViewController <UISplitViewControllerDelegate>

@property (strong, nonatomic) BusStop* detailItem;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
