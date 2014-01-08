#import "BusStop.h"

@interface BusStop()

+ (void)commitFavorites:(NSArray*)favorites;

@end

@implementation BusStop

@synthesize name, id, direction, latitude, longitude, indicator;

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.id forKey:@"id"];
  [encoder encodeObject:self.direction forKey:@"direction"];
  [encoder encodeObject:self.indicator forKey:@"indicator"];
  [encoder encodeDouble:self.latitude forKey:@"latitude"];
  [encoder encodeDouble:self.longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    self.name = [decoder decodeObjectForKey:@"name"];
    self.id = [decoder decodeObjectForKey:@"id"];
    self.direction = [decoder decodeObjectForKey:@"direction"];
    self.indicator = [decoder decodeObjectForKey:@"indicator"];
    self.latitude = [decoder decodeDoubleForKey:@"latitude"];
    self.longitude = [decoder decodeDoubleForKey:@"longitude"];
  }
  return self;
}

- (void)saveFavorite {
  NSArray* existingFavorites = [BusStop allFavorites];
  
  for (BusStop* stop in existingFavorites) {
    if ([stop.name compare:self.name] == NSOrderedSame) {
      return;
    }
  }
  
  NSMutableArray* favorites = [NSMutableArray arrayWithArray:existingFavorites];
  
  [favorites addObject:self];
  
  [BusStop commitFavorites:favorites];
}

+ (NSArray*)allFavorites {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData* favoritesData = [defaults objectForKey:@"favorites"];
  
  NSMutableArray* favorites = nil;
  
  if (NULL != favoritesData) {
    favorites = (NSMutableArray*)[NSKeyedUnarchiver unarchiveObjectWithData:favoritesData];
  }
  else {
    favorites = [NSMutableArray array];
  }
  
  return favorites;
}

+ (void)deleteFavorite:(BusStop*)stop {
  NSArray* existingFavorites = [BusStop allFavorites];
  NSMutableArray* finalFavorites = [NSMutableArray arrayWithArray:existingFavorites];
  
  for (BusStop* existingStop in existingFavorites) {
    if ([stop.name compare:existingStop.name] == NSOrderedSame) {
      [finalFavorites removeObject:existingStop];
    }
  }
  
  [self commitFavorites:finalFavorites];
}

+ (void)commitFavorites:(NSArray*)favorites {
  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:favorites];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:encodedObject forKey:@"favorites"];
  [defaults synchronize];
}

- (float)distanceFromLocation:(CGPoint)location {

  float x = latitude - location.x;
  float y = longitude - location.y;
  
  float length = sqrt(x * x + y * y);
  
  return length;
}

@end
