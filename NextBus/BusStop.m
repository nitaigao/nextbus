#import "BusStop.h"

@implementation BusStop

@synthesize name, id, direction, latitude, longitude, indicator;

- (void)encodeWithCoder:(NSCoder *)encoder {
  [encoder encodeObject:self.name forKey:@"name"];
  [encoder encodeObject:self.id forKey:@"id"];
  [encoder encodeObject:self.direction forKey:@"direction"];
  [encoder encodeObject:self.indicator forKey:@"indicator"];
  [encoder encodeDouble:self.latitude forKey:@"latitude"];
  [encoder encodeDouble:self.longitude forKey:@"londitude"];
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
  
  NSData *encodedObject = [NSKeyedArchiver archivedDataWithRootObject:favorites];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:encodedObject forKey:@"favorites"];
  [defaults synchronize];
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

@end
