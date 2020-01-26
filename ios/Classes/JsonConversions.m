
#import "JsonConversions.h"

@implementation FLTNaverMapJsonConversions

+ (bool)toBool:(NSNumber*)data {
  return data.boolValue;
}

+ (int)toInt:(NSNumber*)data {
  return data.intValue;
}

+ (double)toDouble:(NSNumber*)data {
  return data.doubleValue;
}

+ (float)toFloat:(NSNumber*)data {
  return data.floatValue;
}

+ (NMGLatLng*)toLocation:(NSArray*)data {
  return NMGLatLngMake([FLTNaverMapJsonConversions toDouble:data[0]],
                                    [FLTNaverMapJsonConversions toDouble:data[1]]);
}

+ (CGPoint)toPoint:(NSArray*)data {
  return CGPointMake([FLTNaverMapJsonConversions toDouble:data[0]],
                     [FLTNaverMapJsonConversions toDouble:data[1]]);
}

+ (NSArray*)positionToJson:(NMGLatLng*)position {
  return @[ @(position.latitude), @(position.longitude) ];
}

+ (UIColor*)toColor:(NSNumber*)numberColor {
  unsigned long value = [numberColor unsignedLongValue];
  return [UIColor colorWithRed:((float)((value & 0xFF0000) >> 16)) / 255.0
                         green:((float)((value & 0xFF00) >> 8)) / 255.0
                          blue:((float)(value & 0xFF)) / 255.0
                         alpha:((float)((value & 0xFF000000) >> 24)) / 255.0];
}

+ (NSArray<CLLocation*>*)toPoints:(NSArray*)data {
  NSMutableArray* points = [[NSMutableArray alloc] init];
  for (unsigned i = 0; i < [data count]; i++) {
    NSNumber* latitude = data[i][0];
    NSNumber* longitude = data[i][1];
    CLLocation* point =
        [[CLLocation alloc] initWithLatitude:[FLTNaverMapJsonConversions toDouble:latitude]
                                   longitude:[FLTNaverMapJsonConversions toDouble:longitude]];
    [points addObject:point];
  }

  return points;
}

@end