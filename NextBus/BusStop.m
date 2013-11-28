#import "BusStop.h"

@implementation BusStop

@synthesize name, id, direction, latitude, longitude, indicator;

- (void)encodeWithCoder:(NSCoder *)encoder {
  //Encode properties, other class variables, etc
//  [encoder encodeObject:self.question forKey:@"question"];
//  [encoder encodeObject:self.categoryName forKey:@"category"];
//  [encoder encodeObject:self.subCategoryName forKey:@"subcategory"];
}

- (id)initWithCoder:(NSCoder *)decoder {
  if((self = [super init])) {
    //decode properties, other class vars
//    self.question = [decoder decodeObjectForKey:@"question"];
//    self.categoryName = [decoder decodeObjectForKey:@"category"];
//    self.subCategoryName = [decoder decodeObjectForKey:@"subcategory"];
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
