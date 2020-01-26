part of naver_map_flutter;

typedef void MapCreateCallback(NaverMapController controller);

typedef void CameraPositionCallback(CameraPosition position);

typedef void OnMarkerTab(Marker marker, Map<String, int> iconSize);

typedef void OnMapTab(LatLng latLng);

typedef void OnMapLongTab(LatLng latLng);

typedef void OnMapDoubleTab(LatLng latLng);

typedef void OnMapTwoFingerTab(LatLng latLng);

typedef void OnCameraChange(LatLng latLng);

typedef void OnSymbolTab(LatLng position, String caption);
