part of naver_map_flutter;

class NaverMapController {
  NaverMapController._(
      this.channel, CameraPosition initialCameraPosition, this._naverMapState)
      : assert(channel != null) {
    channel.setMethodCallHandler(_handleMethodCall);
  }

  static Future<NaverMapController> init(int id,
      CameraPosition initalCameraPosition, _NaverMapState naverMapState) async {
    assert(id != null);
    final MethodChannel channel = MethodChannel(VIEW_TYPE + '_$id');
    await channel.invokeMethod<void>('map#waitForMap');

    return NaverMapController._(
      channel,
      initalCameraPosition,
      naverMapState,
    );
  }

  final MethodChannel channel;

  final _NaverMapState _naverMapState;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'marker#onTap':
        String markerId = call.arguments['markerId'];
        int iconWidth = call.arguments['iconWidth'];
        int iconHeight = call.arguments['iconHeight'];
        _naverMapState._markerTabbed(markerId, iconWidth, iconHeight);
        break;
      case 'map#onTap':
        LatLng latLng = LatLng._fromJson(call.arguments['position']);
        _naverMapState._mapTap(latLng);
        break;
      case 'map#onLongTap':
        LatLng latLng = LatLng._fromJson(call.arguments['position']);
        _naverMapState._mapLongTab(latLng);
        break;
      case 'map#onDoubleTap':
        LatLng latLng = LatLng._fromJson(call.arguments['position']);
        _naverMapState._mapDoubleTab(latLng);
        break;
      case 'map#onTwoFingerTap':
        LatLng latLng = LatLng._fromJson(call.arguments['position']);
        _naverMapState._mapTwoFingerTab(latLng);
        break;
      case 'map#onSymbolClick':
        LatLng position = LatLng._fromJson(call.arguments['position']);
        String caption = call.arguments['caption'];
        _naverMapState._symbolTab(position, caption);
        break;
      case 'camera#move':
        LatLng position = LatLng._fromJson(call.arguments['position']);
        _naverMapState._cameraMove(position);
        break;
      case 'camera#idle':
        _naverMapState._cameraIdle();
        break;
    }
  }

  Future<void> _updateMapOptions(Map<String, dynamic> optionsUpdate) async {
    assert(optionsUpdate != null);
    await channel.invokeMethod(
      'map#update',
      <String, dynamic>{
        'options': optionsUpdate,
      },
    );
  }

  Future<void> _updateMarkers(_MarkerUpdates markerUpdate) async {
    assert(markerUpdate != null);
    await channel.invokeMethod<void>(
      'markers#update',
      markerUpdate._toMap(),
    );
  }

  /// 현제 지도에 보여지는 영역에 대한 [LatLngBounds] 객체를 리턴.
  Future<LatLngBounds> getVisibleRegion() async {
    final Map<String, dynamic> latLngBounds =
        await channel.invokeMapMethod<String, dynamic>('map#getVisibleRegion');
    final LatLng southwest = LatLng._fromJson(latLngBounds['southwest']);
    final LatLng northeast = LatLng._fromJson(latLngBounds['northeast']);

    return LatLngBounds(northeast: northeast, southwest: southwest);
  }

  /// 현제 지도의 중심점 좌표에 대한 [CameraPosition] 객체를 리턴.
  Future<CameraPosition> getCameraPosition() async {
    final Map position = await channel.invokeMethod<Map>('map#getPosition');
    return CameraPosition(
      target: LatLng._fromJson(position['target']),
      zoom: position['zoom'],
      tilt: position['tilt'],
      bearing: position['bearing'],
    );
  }

  /// 지도가 보여지는 view 의 크기를 반환.
  /// Map<String, double>로 반환.
  ///
  /// ['width' : 가로 pixel, 'height' : 세로 pixel]
  Future<Map<String, int>> getSize() async {
    final Map size = await channel.invokeMethod<Map>('map#getSize');
    return <String, int>{'width': size['width'], 'height': size['height']};
  }

  Future<void> moveCamera(CameraUpdate cameraUpdate) async {
    await channel.invokeMethod<void>('camera#move', <String, dynamic>{
      'cameraUpdate': cameraUpdate._toJson(),
    });
  }

  Future<void> setLocationTrackingMode(LocationTrackingMode mode) async {
    if (mode == null) return;
    await channel.invokeMethod('tracking#mode', <String, dynamic>{
      'locationTrackingMode': mode.index,
    });
  }
}
