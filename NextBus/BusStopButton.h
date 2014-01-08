#import <UIKit/UIKit.h>

@class BusStop;

@interface BusStopButton : UIButton

- (id)initWithBusStop:(BusStop*)busStop;

@property (nonatomic, strong) BusStop* busStop;

+ (id)buttonWithBusStop:(BusStop*)busStop;

@end
