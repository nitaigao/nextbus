#import <Foundation/Foundation.h>

#import <MapKit/MapKit.h>

@class BusStop;

@interface BusStopAnnotation : NSObject<MKAnnotation>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString*)title andBusStop:(BusStop*)busStop;

@property (nonatomic, strong, readonly) BusStop* busStop;

@end
