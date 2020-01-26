package com.example.naver_map_flutter;

import java.util.List;

interface NaverMapOptionSink {

    void setMapType(int typeIndex);

    void setBuildingHeight(double buildingHeight);

    void setSymbolScale(double symbolScale);

    void setSymbolPerspectiveRatio(double symbolPerspectiveRatio);

    void setActiveLayers(List activeLayers);

    void setRotationGestureEnable(boolean rotationGestureEnable);

    void setScrollGestureEnable(boolean scrollGestureEnable);

    void setTiltGestureEnable(boolean tiltGestureEnable);

    void setZoomGestureEnable(boolean zoomGestureEnable);

    void setLocationButtonEnable(boolean locationButtonEnable);

    void setLocationTrackingMode(int locationTrackingMode);

    void setNightModeEnabled(boolean nightModeEnable);

    void setLiteModeEnabled(boolean liteModeEnable);

    void setIndoorEnabled(boolean indoorEnable);

}
