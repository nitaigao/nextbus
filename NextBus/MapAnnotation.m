#import "MapAnnotation.h"

@interface MapAnnotation() {
  CLLocationCoordinate2D _coordinate;
}

@end

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    _coordinate = coordinate;
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {
  return _coordinate;
}

@end
