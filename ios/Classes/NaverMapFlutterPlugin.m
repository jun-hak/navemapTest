#import "NaverMapFlutterPlugin.h"

@implementation NaverMapFlutterPlugin{
  NSObject<FlutterPluginRegistrar>* _registrar;
  FlutterMethodChannel* _channel;
  NSMutableDictionary* _mapControllers;
}

+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FLTNaverMapFactory* naverMapFactory = [[FLTNaverMapFactory alloc] initWithRegistrar:registrar];
  [registrar registerViewFactory:naverMapFactory withId:@"naver_map_flutter"];
}

- (FLTNaverMapController*)mapFromCall:(FlutterMethodCall*)call error:(FlutterError**)error {
  id mapId = call.arguments[@"map"];
  FLTNaverMapController* controller = _mapControllers[mapId];
  if (!controller && error) {
    *error = [FlutterError errorWithCode:@"unknown_map" message:nil details:mapId];
  }
  return controller;
}

@end
