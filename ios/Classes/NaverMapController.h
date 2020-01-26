
#import <Flutter/Flutter.h>
#import <NMapsMap/NMapsMap.h>
#import "NaverMapMarkerController.h"

NS_ASSUME_NONNULL_BEGIN

// Defines map UI options writable from Flutter.
@protocol FLTNaverMapOptionsSink
- (void)setMapType(ubtn typeIdx)enable;
// - (void)setCameraTargetBounds:(nullable GMSCoordinateBounds *)bounds;
// - (void)setCompassEnabled:(BOOL)enabled;
// - (void)setIndoorEnabled:(BOOL)enabled;
// - (void)setTrafficEnabled:(BOOL)enabled;
// - (void)setBuildingsEnabled:(BOOL)enabled;
// - (void)setMapType:(GMSMapViewType)type;
// - (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom;
// - (void)setPaddingTop:(float)top left:(float)left bottom:(float)bottom right:(float)right;
// - (void)setRotateGesturesEnabled:(BOOL)enabled;
// - (void)setScrollGesturesEnabled:(BOOL)enabled;
// - (void)setTiltGesturesEnabled:(BOOL)enabled;
// - (void)setTrackCameraPosition:(BOOL)enabled;
// - (void)setZoomGesturesEnabled:(BOOL)enabled;
// - (void)setMyLocationEnabled:(BOOL)enabled;
// - (void)setMyLocationButtonEnabled:(BOOL)enabled;
- (nullable NSString *)setMapStyle:(NSString *)mapStyle;
@end

// Defines map overlay controllable from Flutter.
@interface FLTNaverMapController
    : NSObject <GMSMapViewDelegate, FLTNaverMapOptionsSink, FlutterPlatformView>
- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(nullable id)args
                    registrar:(NSObject<FlutterPluginRegistrar> *)registrar;
- (void)showAtX:(CGFloat)x Y:(CGFloat)y;
- (void)hide;
- (void)animateWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate;
- (void)moveWithCameraUpdate:(GMSCameraUpdate *)cameraUpdate;
- (nullable GMSCameraPosition *)cameraPosition;
@end

// Allows the engine to create new Naver Map instances.
@interface FLTNaverMapFactory : NSObject <FlutterPlatformViewFactory>
- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar> *)registrar;
@end

NS_ASSUME_NONNULL_END
