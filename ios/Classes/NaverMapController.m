

#import "NaverMapController.h"
#import "JsonConversions.h"

#pragma mark - Conversion of JSON-like values sent via platform channels. Forward declarations.

// GMSCoordinateBounds -> NMGLatLng
// GMSCameraPosition -> NMFCameraPosition
// GMSCameraUpdate -> NMFCameraUpdate
static NSDictionary* PositionToJson(NMFCameraUpdate* position);
static NSDictionary* PointToJson(CGPoint point);
static NSArray* LocationToJson(CLLocationCoordinate2D  position);
static CGPoint ToCGPoint(NSDictionary* json);
static NMFCameraUpdate* ToOptionalCameraPosition(NSDictionary* json);
static NMGBounds* ToOptionalBounds(NSArray* json);
static NMFCameraUpdate* ToCameraUpdate(NSArray* data);
static NSDictionary* NMGBoundsToJson(NMGBounds* bounds);
static void InterpretMapOptions(NSDictionary* data, id<FLTNaverMapOptionsSink> sink);
static double ToDouble(NSNumber* data) { return [FLTNaverMapJsonConversions toDouble:data]; }

@implementation FLTNaverMapFactory {
  NSObject<FlutterPluginRegistrar>* _registrar;
}

- (instancetype)initWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  self = [super init];
  if (self) {
    _registrar = registrar;
  }
  return self;
}

- (NSObject<FlutterMessageCodec>*)createArgsCodec {
  return [FlutterStandardMessageCodec sharedInstance];
}

- (NSObject<FlutterPlatformView>*)createWithFrame:(CGRect)frame
                                   viewIdentifier:(int64_t)viewId
                                        arguments:(id _Nullable)args {
  return [[FLTNaverMapController alloc] initWithFrame:frame
                                        viewIdentifier:viewId
                                             arguments:args
                                             registrar:_registrar];
}
@end

@implementation FLTNaverMapController {
  NMFMapView* _mapView;
  int64_t _viewId;
  FlutterMethodChannel* _channel;
  BOOL _trackCameraPosition;
  NSObject<FlutterPluginRegistrar>* _registrar;
  // Used for the temporary workaround for a bug that the camera is not properly positioned at
  // initialization. https://github.com/flutter/flutter/issues/24806
  // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
  // https://github.com/flutter/flutter/issues/27550
  BOOL _cameraDidInitialSetup;
  FLTMarkersController* _markersController;
  // FLTPolygonsController* _polygonsController;
  // FLTPolylinesController* _polylinesController;
  // FLTCirclesController* _circlesController;
}

- (instancetype)initWithFrame:(CGRect)frame
               viewIdentifier:(int64_t)viewId
                    arguments:(id _Nullable)args
                    registrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  if (self = [super init]) {
    _viewId = viewId;

    NMFCameraUpdate* camera = ToOptionalCameraPosition(args[@"initialCameraPosition"]);
    _mapView = [NMFMapView mapWithFrame:frame camera:camera];
    _mapView.accessibilityElementsHidden = NO;
    _trackCameraPosition = NO;
    InterpretMapOptions(args[@"options"], self);
    NSString* channelName =
        [NSString stringWithFormat:@"flutter_naver_map_%lld", viewId];
    _channel = [FlutterMethodChannel methodChannelWithName:channelName
                                           binaryMessenger:registrar.messenger];
    __weak __typeof__(self) weakSelf = self;
    [_channel setMethodCallHandler:^(FlutterMethodCall* call, FlutterResult result) {
      if (weakSelf) {
        [weakSelf onMethodCall:call result:result];
      }
    }];
    _mapView.delegate = weakSelf;
    _registrar = registrar;
    _cameraDidInitialSetup = NO;
    _markersController = [[FLTMarkersController alloc] init:_channel
                                                    mapView:_mapView
                                                  registrar:registrar];
    id markersToAdd = args[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [_markersController addMarkers:markersToAdd];
    }
  }
  return self;
}

- (UIView*)view {
  return _mapView;
}

- (void)onMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([call.method isEqualToString:@"camera#move"]) {
    [self moveWithCameraUpdate:ToCameraUpdate(call.arguments[@"cameraUpdate"])];
    result(nil);
  } else if ([call.method isEqualToString:@"map#update"]) {
    InterpretMapOptions(call.arguments[@"options"], self);
    result(PositionToJson([self cameraPosition]));
  } else if ([call.method isEqualToString:@"map#getVisibleRegion"]) {
    if (_mapView != nil) {
      GMSVisibleRegion visibleRegion = _mapView.projection.visibleRegion;
      NMGLatLngBounds* bounds = [[NMGLatLngBounds alloc] initWithRegion:visibleRegion];

      result(NMGLatLngBoundsToJson(bounds));
    } else {
      result([FlutterError errorWithCode:@"Naver uninitialized"
                                 message:@"getVisibleRegion called prior to map initialization"
                                 details:nil]);
    }
  }  else if ([call.method isEqualToString:@"map#waitForMap"]) {
    result(nil);
  } else if ([call.method isEqualToString:@"markers#update"]) {
    id markersToAdd = call.arguments[@"markersToAdd"];
    if ([markersToAdd isKindOfClass:[NSArray class]]) {
      [_markersController addMarkers:markersToAdd];
    }
    id markersToChange = call.arguments[@"markersToChange"];
    if ([markersToChange isKindOfClass:[NSArray class]]) {
      [_markersController changeMarkers:markersToChange];
    }
    id markerIdsToRemove = call.arguments[@"markerIdsToRemove"];
    if ([markerIdsToRemove isKindOfClass:[NSArray class]]) {
      [_markersController removeMarkerIds:markerIdsToRemove];
    }
    result(nil);
  } else {
    result(FlutterMethodNotImplemented);
  }
}


- (void)moveWithCameraUpdate:(NMFCameraUpdate*)cameraUpdate {
  [_mapView moveCamera:cameraUpdate];
}

- (NMFCameraUpdate*)cameraPosition {
  if (_trackCameraPosition) {
    return _mapView.camera;
  } else {
    return nil;
  }
}

#pragma mark - FLTNaverMapOptionsSink methods

- (void)setCamera:(NMFCameraUpdate*)camera {
  _mapView.camera = camera;
}

- (void)setCameraTargetBounds:(NMGLatLng*)bounds {
  _mapView.cameraTargetBounds = bounds;
}

- (void)setCompassEnabled:(BOOL)enabled {
  _mapView.settings.compassButton = enabled;
}

- (void)setIndoorEnabled:(BOOL)enabled {
  _mapView.indoorEnabled = enabled;
}

- (void)setTrafficEnabled:(BOOL)enabled {
  _mapView.trafficEnabled = enabled;
}

- (void)setBuildingsEnabled:(BOOL)enabled {
  _mapView.buildingsEnabled = enabled;
}

- (void)setMapType:(NMFMapViewType)mapType {
  _mapView.mapType = mapType;
}

- (void)setMinZoom:(float)minZoom maxZoom:(float)maxZoom {
  [_mapView setMinZoom:minZoom maxZoom:maxZoom];
}

- (void)setPaddingTop:(float)top left:(float)left bottom:(float)bottom right:(float)right {
  _mapView.padding = UIEdgeInsetsMake(top, left, bottom, right);
}

- (void)setRotateGesturesEnabled:(BOOL)enabled {
  _mapView.settings.rotateGestures = enabled;
}

- (void)setScrollGesturesEnabled:(BOOL)enabled {
  _mapView.settings.scrollGestures = enabled;
}

- (void)setTiltGesturesEnabled:(BOOL)enabled {
  _mapView.settings.tiltGestures = enabled;
}

- (void)setTrackCameraPosition:(BOOL)enabled {
  _trackCameraPosition = enabled;
}

- (void)setZoomGesturesEnabled:(BOOL)enabled {
  _mapView.settings.zoomGestures = enabled;
}

- (void)setMyLocationEnabled:(BOOL)enabled {
  _mapView.myLocationEnabled = enabled;
}

- (void)setMyLocationButtonEnabled:(BOOL)enabled {
  _mapView.settings.myLocationButton = enabled;
}

- (NSString*)setMapStyle:(NSString*)mapStyle {
  if (mapStyle == (id)[NSNull null] || mapStyle.length == 0) {
    _mapView.mapStyle = nil;
    return nil;
  }
  NSError* error;
  GMSMapStyle* style = [GMSMapStyle styleWithJSONString:mapStyle error:&error];
  if (!style) {
    return [error localizedDescription];
  } else {
    _mapView.mapStyle = style;
    return nil;
  }
}

#pragma mark - NMFMapViewDelegate methods

- (void)mapView:(NMFMapView*)mapView willMove:(BOOL)gesture {
  [_channel invokeMethod:@"camera#onMoveStarted" arguments:@{@"isGesture" : @(gesture)}];
}

- (void)mapView:(NMFMapView*)mapView didChangeCameraPosition:(NMFCameraUpdate*)position {
  if (!_cameraDidInitialSetup) {
    // We suspected a bug in the iOS Google Maps SDK caused the camera is not properly positioned at
    // initialization. https://github.com/flutter/flutter/issues/24806
    // This temporary workaround fix is provided while the actual fix in the Google Maps SDK is
    // still being investigated.
    // TODO(cyanglaz): Remove this temporary fix once the Maps SDK issue is resolved.
    // https://github.com/flutter/flutter/issues/27550
    _cameraDidInitialSetup = YES;
    [mapView moveCamera:[NMFCameraUpdate setCamera:_mapView.camera]];
  }
  if (_trackCameraPosition) {
    [_channel invokeMethod:@"camera#onMove" arguments:@{@"position" : PositionToJson(position)}];
  }
}

- (void)mapView:(NMFMapView*)mapView idleAtCameraPosition:(NMFCameraUpdate*)position {
  [_channel invokeMethod:@"camera#onIdle" arguments:@{}];
}

- (BOOL)mapView:(NMFMapView*)mapView didTapMarker:(NMFMarker*)marker {
  NSString* markerId = marker.userData[0];
  return [_markersController onMarkerTap:markerId];
}

- (void)mapView:(NMFMapView*)mapView didEndDraggingMarker:(NMFMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_markersController onMarkerDragEnd:markerId coordinate:marker.position];
}

- (void)mapView:(NMFMapView*)mapView didTapInfoWindowOfMarker:(NMFMarker*)marker {
  NSString* markerId = marker.userData[0];
  [_markersController onInfoWindowTap:markerId];
}

- (void)mapView:(NMFMapView*)mapView didTapAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [_channel invokeMethod:@"map#onTap" arguments:@{@"position" : LocationToJson(coordinate)}];
}

- (void)mapView:(NMFMapView*)mapView didLongPressAtCoordinate:(CLLocationCoordinate2D)coordinate {
  [_channel invokeMethod:@"map#onLongPress" arguments:@{@"position" : LocationToJson(coordinate)}];
}

@end

#pragma mark - Implementations of JSON conversion functions.

static NSArray* LocationToJson(CLLocationCoordinate2D position) {
  return @[ @(position.latitude), @(position.longitude) ];
}

static NSDictionary* PositionToJson(NMFCameraUpdate* position) {
  if (!position) {
    return nil;
  }
  return @{
    @"target" : LocationToJson([position target]),
    @"zoom" : @([position zoom]),
    @"bearing" : @([position bearing]),
    @"tilt" : @([position viewingAngle]),
  };
}

static NSDictionary* PointToJson(CGPoint point) {
  return @{
    @"x" : @((int)point.x),
    @"y" : @((int)point.y),
  };
}

static NSDictionary* NMGLatLngBoundsToJson(NMGLatLngBounds* bounds) {
  if (!bounds) {
    return nil;
  }
  return @{
    @"southwest" : LocationToJson([bounds southWest]),
    @"northeast" : LocationToJson([bounds northEast]),
  };
}

static float ToFloat(NSNumber* data) { return [FLTNaverMapJsonConversions toFloat:data]; }

static CLLocationCoordinate2D  ToLocation(NSArray* data) {
  return [FLTNaverMapJsonConversions toLocation:data];
}

static int ToInt(NSNumber* data) { return [FLTNaverMapJsonConversions toInt:data]; }

static BOOL ToBool(NSNumber* data) { return [FLTNaverMapJsonConversions toBool:data]; }

static CGPoint ToPoint(NSArray* data) { return [FLTNaverMapJsonConversions toPoint:data]; }

static NMFCameraPosition* ToCameraPosition(NSDictionary* data) {
  return [NMFCameraPosition cameraWithTarget:ToLocation(data[@"target"])
                                        zoom:ToFloat(data[@"zoom"])
                                     bearing:ToDouble(data[@"bearing"])
                                viewingAngle:ToDouble(data[@"tilt"])];
}

static NMFCameraPosition* ToOptionalCameraPosition(NSDictionary* json) {
  return json ? ToCameraPosition(json) : nil;
}

static CGPoint ToCGPoint(NSDictionary* json) {
  double x = ToDouble(json[@"x"]);
  double y = ToDouble(json[@"y"]);
  return CGPointMake(x, y);
}

static NMGBounds* ToBounds(NSArray* data) {
  return [[NMGBounds alloc] initWithCoordinate:ToLocation(data[0])
                                              coordinate:ToLocation(data[1])];
}

static NMGBounds* ToOptionalBounds(NSArray* data) {
  return (data[0] == [NSNull null]) ? nil : ToBounds(data[0]);
}

static NMFMapViewType ToMapViewType(NSNumber* json) {
  int value = ToInt(json);
  return (NMFMapViewType)(value == 0 ? 5 : value);
}

static NMFCameraUpdate* ToCameraUpdate(NSArray* data) {
  NSString* update = data[0];
  if ([update isEqualToString:@"newCameraPosition"]) {
    return [NMFCameraUpdate setCamera:ToCameraPosition(data[1])];
  } else if ([update isEqualToString:@"newLatLng"]) {
    return [NMFCameraUpdate setTarget:ToLocation(data[1])];
  } else if ([update isEqualToString:@"newLatLngBounds"]) {
    return [NMFCameraUpdate fitBounds:ToBounds(data[1]) withPadding:ToDouble(data[2])];
  } else if ([update isEqualToString:@"newLatLngZoom"]) {
    return [NMFCameraUpdate setTarget:ToLocation(data[1]) zoom:ToFloat(data[2])];
  } else if ([update isEqualToString:@"scrollBy"]) {
    return [NMFCameraUpdate scrollByX:ToDouble(data[1]) Y:ToDouble(data[2])];
  } else if ([update isEqualToString:@"zoomBy"]) {
    if (data.count == 2) {
      return [NMFCameraUpdate zoomBy:ToFloat(data[1])];
    } else {
      return [NMFCameraUpdate zoomBy:ToFloat(data[1]) atPoint:ToPoint(data[2])];
    }
  } else if ([update isEqualToString:@"zoomIn"]) {
    return [NMFCameraUpdate zoomIn];
  } else if ([update isEqualToString:@"zoomOut"]) {
    return [NMFCameraUpdate zoomOut];
  } else if ([update isEqualToString:@"zoomTo"]) {
    return [NMFCameraUpdate zoomTo:ToFloat(data[1])];
  }
  return nil;
}

static void InterpretMapOptions(NSDictionary* data, id<FLTNaverMapOptionsSink> sink) {
  NSArray* cameraTargetBounds = data[@"cameraTargetBounds"];
  if (cameraTargetBounds) {
    [sink setCameraTargetBounds:ToOptionalBounds(cameraTargetBounds)];
  }
  NSNumber* compassEnabled = data[@"compassEnabled"];
  if (compassEnabled != nil) {
    [sink setCompassEnabled:ToBool(compassEnabled)];
  }
  id indoorEnabled = data[@"indoorEnabled"];
  if (indoorEnabled) {
    [sink setIndoorEnabled:ToBool(indoorEnabled)];
  }
  id trafficEnabled = data[@"trafficEnabled"];
  if (trafficEnabled) {
    [sink setTrafficEnabled:ToBool(trafficEnabled)];
  }
  id buildingsEnabled = data[@"buildingsEnabled"];
  if (buildingsEnabled) {
    [sink setBuildingsEnabled:ToBool(buildingsEnabled)];
  }
  id mapType = data[@"mapType"];
  if (mapType) {
    [sink setMapType:ToMapViewType(mapType)];
  }
  NSArray* zoomData = data[@"minMaxZoomPreference"];
  if (zoomData) {
    float minZoom = (zoomData[0] == [NSNull null]) ? kGMSMinZoomLevel : ToFloat(zoomData[0]);
    float maxZoom = (zoomData[1] == [NSNull null]) ? kGMSMaxZoomLevel : ToFloat(zoomData[1]);
    [sink setMinZoom:minZoom maxZoom:maxZoom];
  }
  NSArray* paddingData = data[@"padding"];
  if (paddingData) {
    float top = (paddingData[0] == [NSNull null]) ? 0 : ToFloat(paddingData[0]);
    float left = (paddingData[1] == [NSNull null]) ? 0 : ToFloat(paddingData[1]);
    float bottom = (paddingData[2] == [NSNull null]) ? 0 : ToFloat(paddingData[2]);
    float right = (paddingData[3] == [NSNull null]) ? 0 : ToFloat(paddingData[3]);
    [sink setPaddingTop:top left:left bottom:bottom right:right];
  }

  NSNumber* rotateGesturesEnabled = data[@"rotateGesturesEnabled"];
  if (rotateGesturesEnabled != nil) {
    [sink setRotateGesturesEnabled:ToBool(rotateGesturesEnabled)];
  }
  NSNumber* scrollGesturesEnabled = data[@"scrollGesturesEnabled"];
  if (scrollGesturesEnabled != nil) {
    [sink setScrollGesturesEnabled:ToBool(scrollGesturesEnabled)];
  }
  NSNumber* tiltGesturesEnabled = data[@"tiltGesturesEnabled"];
  if (tiltGesturesEnabled != nil) {
    [sink setTiltGesturesEnabled:ToBool(tiltGesturesEnabled)];
  }
  NSNumber* trackCameraPosition = data[@"trackCameraPosition"];
  if (trackCameraPosition != nil) {
    [sink setTrackCameraPosition:ToBool(trackCameraPosition)];
  }
  NSNumber* zoomGesturesEnabled = data[@"zoomGesturesEnabled"];
  if (zoomGesturesEnabled != nil) {
    [sink setZoomGesturesEnabled:ToBool(zoomGesturesEnabled)];
  }
  NSNumber* myLocationEnabled = data[@"myLocationEnabled"];
  if (myLocationEnabled != nil) {
    [sink setMyLocationEnabled:ToBool(myLocationEnabled)];
  }
  NSNumber* myLocationButtonEnabled = data[@"myLocationButtonEnabled"];
  if (myLocationButtonEnabled != nil) {
    [sink setMyLocationButtonEnabled:ToBool(myLocationButtonEnabled)];
  }
}