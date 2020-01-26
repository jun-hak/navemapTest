
#import <Flutter/Flutter.h>
#import <NMapsMap/NMapsMap.h>
#import "NaverMapController.h"

// Defines marker UI options writable from Flutter.
@protocol FLTNaverMapMarkerOptionsSink
- (void)setPosition:(NMGLatLng)position;
- (void)setVisible:(BOOL)visible;
@end

// Defines marker controllable by Flutter.
@interface FLTNaverMapMarkerController : NSObject <FLTNaverMapMarkerOptionsSink>
@property(atomic, readonly) NSString *markerId;
- (instancetype)initMarkerWithPosition:(NMGLatLng)position
                              markerId:(NSString *)markerId
                               mapView:(NMFMapView *)mapView;
- (BOOL)consumeTapEvents;
- (void)removeMarker;
@end

@interface FLTMarkersController : NSObject
- (instancetype)init:(FlutterMethodChannel *)methodChannel
             mapView:(NMFMapView *)mapView
           registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)addMarkers:(NSArray *)markersToAdd;
- (void)changeMarkers:(NSArray *)markersToChange;
- (void)removeMarkerIds:(NSArray *)markerIdsToRemove;
- (BOOL)onMarkerTap:(NSString *)markerId;
- (void)onInfoWindowTap:(NSString *)markerId;
@end