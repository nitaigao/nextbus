#import <Foundation/Foundation.h>

@interface BusStopListing : NSObject

@property (nonatomic, strong) NSString* destination;
@property (nonatomic, strong) NSString* time;
@property (nonatomic, strong) NSString* route;
@property (nonatomic, strong) NSString* wait;

@end
