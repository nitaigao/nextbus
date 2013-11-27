#import "BusStopAnnotation.h"

@interface BusStopAnnotation() {
  CLLocationCoordinate2D _coordinate;
  NSString* _title;
  BusStop* _busStop;
}

@end

@implementation BusStopAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title andBusStop:(BusStop*)busStop {
  self = [super init];
  if (self) {
    _coordinate = coordinate;
    _title = title;
    _busStop = busStop;
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {
  return _coordinate;
}

- (NSString*)title {
  return _title;
}

- (BusStop*)busStop {
  return _busStop;
}

@end
