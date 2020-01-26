part of naver_map_flutter;

/// [MapType.Basic], [MapType.Navi], [MapType.Satellite], [MapType.Hybrid], [MapType.Terrain]

enum MapType {
  /// 일반 지도
  Basic,

  /// 차량용 내비
  Navi,

  /// 위성 지도
  Satellite,

  /// 하이브리드 지도(위성 사진과 도로, 심벌)
  Hybrid,

  /// 지형도
  Terrain,
}

enum MapLayer {
  /// 건물 그룹입니다. 활성화할 경우 건물 형상, 주소 심벌 등 건물과 관련된 요소가 노출됩니다. 기본적으로 활성화됩니다.
  LAYER_GROUP_BUILDING,

  /// 실시간 교통정보 그룹입니다. 활성화할 경우 실시간 교통정보가 노출됩니다.
  LAYER_GROUP_TRAFFIC,

  /// 대중교통 그룹입니다. 활성화할 경우 철도, 지하철 노선, 버스정류장 등 대중교통과 관련된 요소가 노출됩니다.
  LAYER_GROUP_TRANSIT,

  /// 자전거 그룹입니다. 활성화할 경우 자전거 도로, 자전거 주차대 등 자전거와 관련된 요소가 노출됩니다.
  LAYER_GROUP_BICYCLE,

  /// 등산로 그룹입니다. 활성화할 경우 등산로, 등고선 등 등산과 관련된 요소가 노출됩니다.
  LAYER_GROUP_MOUNTAIN,

  /// 지적편집도 그룹입니다. 활성화할 경우 지적편집도가 노출됩니다.
  LAYER_GROUP_CADASTRAL,
}
