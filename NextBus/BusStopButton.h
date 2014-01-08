#import <UIKit/UIKit.h>

@class BusStop;

@interface BusStopButton : UIButton

@property (nonatomic, strong) BusStop* busStop;

+ (id)buttonWithBusStop:(BusStop*)busStop;

@end
