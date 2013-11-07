#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@interface MapAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

@end
