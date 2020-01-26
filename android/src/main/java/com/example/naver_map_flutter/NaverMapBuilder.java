package com.example.naver_map_flutter;

import android.content.Context;

import com.naver.maps.map.NaverMap;
import com.naver.maps.map.NaverMapOptions;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

import io.flutter.plugin.common.PluginRegistry;

/**
 * 안에 [setDevMode] 라는 메서드가 있는데, 핫 리로드시에 app crash 를 방지하기 위한 코드이다.
 *
 * true 일때 naver map 을 textureView 위에서 작동하게 하는 코드인데 false 로 실행하면 GLserfaceView
 * 위에서 실행하게 되고, 리로드시에 앱이 크래쉬된다.
 *
 * 릴리즈배포시에는 해당 값을 false로 바꿔주기 바란다!!
 */
public class NaverMapBuilder implements NaverMapOptionSink {
    private final NaverMapOptions options = new NaverMapOptions();
    private List initialMarkers;
    private int locationTrackingMode;

    NaverMapController build(int id, Context context, AtomicInteger state, PluginRegistry.Registrar registrar) {

        final NaverMapController controller = new NaverMapController(id, context, state, registrar, options,
                initialMarkers);
        controller.init();
        controller.setLocationTrackingMode(locationTrackingMode);
        return controller;
    }

    @Override
    public void setNightModeEnabled(boolean nightModeEnable) {
        options.nightModeEnabled(nightModeEnable);
    }

    public void setLiteModeEnabled(boolean liteModeEnable) {
        options.liteModeEnabled(liteModeEnable);
    }

    public void setIndoorEnabled(boolean indoorEnable) {
        options.indoorEnabled(indoorEnable);
    }

    public void setMapType(int typeIndex) {
        NaverMap.MapType type;
        switch (typeIndex) {
        case 1:
            type = NaverMap.MapType.Navi;
            break;
        case 2:
            type = NaverMap.MapType.Satellite;
            break;
        case 3:
            type = NaverMap.MapType.Hybrid;
            break;
        case 4:
            type = NaverMap.MapType.Terrain;
            break;
        default:
            type = NaverMap.MapType.Basic;
            break;
        }
        options.mapType(type);
    }

    public void setBuildingHeight(double buildingHeight) {
        options.buildingHeight((float) buildingHeight);
    }

    public void setSymbolScale(double symbolScale) {
        options.symbolScale((float) symbolScale);
    }

    @Override
    public void setSymbolPerspectiveRatio(double symbolPerspectiveRatio) {
        options.symbolPerspectiveRatio((float) symbolPerspectiveRatio);
    }

    @Override
    public void setActiveLayers(List activeLayers) {
        if (activeLayers.size() == 0)
            return;
        // 0~5까지의 길이 6개인 리스트 생성 (전체 레이어 타입들.)
        ArrayList<Integer> initList = new ArrayList<>();
        for (int i = 0; i < 6; i++)
            initList.add(i);

        // 받은 리스트에 있는 것들을 활성화후 initList에서 제거
        for (int i = 0; i < activeLayers.size(); i++) {
            int index = (int) activeLayers.get(i);
            if (initList.contains(index))
                initList.remove(Integer.valueOf(index));
            switch (index) {
            case 0:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_BUILDING);
                break;
            case 1:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_TRAFFIC);
                break;
            case 2:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_TRANSIT);
                break;
            case 3:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_BICYCLE);
                break;
            case 4:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_MOUNTAIN);
                break;
            case 5:
                options.enabledLayerGroups(NaverMap.LAYER_GROUP_CADASTRAL);
                break;
            }
        }

        // initList 에 남은 인덱스들로 레이어 disable.
        if (initList.size() == 0)
            return;
        for (Integer idx : initList) {
            switch (idx) {
            case 0:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_BUILDING);
                break;
            case 1:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_TRAFFIC);
                break;
            case 2:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_TRANSIT);
                break;
            case 3:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_BICYCLE);
                break;
            case 4:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_MOUNTAIN);
                break;
            case 5:
                options.disabledLayerGroups(NaverMap.LAYER_GROUP_CADASTRAL);
                break;
            }
        }
    }

    @Override
    public void setRotationGestureEnable(boolean rotationGestureEnable) {
        options.rotateGesturesEnabled(rotationGestureEnable);
    }

    @Override
    public void setScrollGestureEnable(boolean scrollGestureEnable) {
        options.scrollGesturesEnabled(scrollGestureEnable);
    }

    @Override
    public void setTiltGestureEnable(boolean tiltGestureEnable) {
        options.tiltGesturesEnabled(tiltGestureEnable);
    }

    @Override
    public void setZoomGestureEnable(boolean zoomGestureEnable) {
        options.zoomGesturesEnabled(zoomGestureEnable);
        if (!zoomGestureEnable)
            options.zoomControlEnabled(false);
    }

    @Override
    public void setLocationButtonEnable(boolean locationButtonEnable) {
        options.locationButtonEnabled(locationButtonEnable);
    }

    @Override
    public void setLocationTrackingMode(int locationTrackingMode) {
        this.locationTrackingMode = locationTrackingMode;
    }

    public void setInitialCameraPosition(Map<String, Object> cameraPosition) {
        options.camera(Convert.toCameraPosition(cameraPosition));
    }

    public void setDevMode(boolean isDevMode) {
        if (isDevMode)
            options.useTextureView(true);
        else
            options.useTextureView(false);
    }

    public void setInitialMarkers(List initialMarkers) {
        this.initialMarkers = initialMarkers;
    }

}
