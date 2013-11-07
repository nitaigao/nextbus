#import <Foundation/Foundation.h>

@interface BusStop : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* id;
@property (nonatomic, strong) NSString* direction;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end
