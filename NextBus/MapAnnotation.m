#import "MapAnnotation.h"

@interface MapAnnotation() {
  CLLocationCoordinate2D _coordinate;
  NSString* _title;
}

@end

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title {
  self = [super init];
  if (self) {
    _coordinate = coordinate;
    _title = title;
  }
  return self;
}

- (CLLocationCoordinate2D)coordinate {
  return _coordinate;
}

- (NSString*)title {
  return _title;
}

@end
