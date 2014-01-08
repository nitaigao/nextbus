#import "BusStopButton.h"

@implementation BusStopButton

@synthesize busStop;

+ (id)buttonWithBusStop:(BusStop *)busStop {
  BusStopButton* button = (BusStopButton*)[super buttonWithType:UIButtonTypeDetailDisclosure];
  button.busStop = busStop;
  
  return button;
}

@end
