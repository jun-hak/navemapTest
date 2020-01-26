#import "NaverMapMarkerController.h"
#import "JsonConversions.h"


@implementation FLTNaverMapMarkerController {
  NMFMarker* _marker;
  NMFMapView* _mapView;
  BOOL _consumeTapEvents;
}
- (instancetype)initMarkerWithPosition:(NMGLatLng)position
                              markerId:(NSString*)markerId
                               mapView:(NMFMapView*)mapView {
  self = [super init];
  if (self) {
    _marker = [NMFMarker markerWithPosition:position];
    _mapView = mapView;
    _markerId = markerId;
    _marker.userData = @[ _markerId ];
    _consumeTapEvents = NO;
  }
  return self;
}