#import "BusStopButton.h"

@implementation BusStopButton

@synthesize busStop;

+ (id)buttonWithBusStop:(BusStop *)busStop {
  BusStopButton* button = [[BusStopButton alloc] initWithBusStop:busStop];
  
//  button.buttonType = UIButtonTypeInfoLight;
  
  return button;
}

- (id)initWithBusStop:(BusStop*)aBusStop {
  self = [super init];
  if (self) {
    self.busStop = aBusStop;
  }
  return self;
}

@end
