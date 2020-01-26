package com.example.naver_map_flutter;

import android.content.Context;
import android.graphics.PointF;
import android.util.Log;

import androidx.annotation.NonNull;

import com.naver.maps.geometry.LatLng;
import com.naver.maps.map.NaverMap;
import com.naver.maps.map.Symbol;
import com.naver.maps.map.overlay.InfoWindow;
import com.naver.maps.map.overlay.Marker;
import com.naver.maps.map.overlay.Overlay;

import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

public class Listeners implements NaverMap.OnMapClickListener, NaverMap.OnMapLongClickListener,
        NaverMap.OnMapDoubleTapListener, NaverMap.OnMapTwoFingerTapListener, NaverMap.OnSymbolClickListener,
        NaverMap.OnCameraChangeListener, NaverMap.OnCameraIdleListener, Overlay.OnClickListener {

    // member variable
    private final MethodChannel channel;
    private final Context context;
    private static boolean originalBehaviorDisable = false;
    private InfoWindow window;
    private boolean isMarkerTab = false;
    private NaverMap naverMap;

    Listeners(MethodChannel channel, Context context, NaverMap naverMap) {
        this.channel = channel;
        this.context = context;
        this.naverMap = naverMap;
        window = new InfoWindow();
    }

    static void setOriginalBehaviorDisable(boolean originalBehaviorDisable) {
        Listeners.originalBehaviorDisable = originalBehaviorDisable;
    }

    @Override
    public void onMapClick(@NonNull PointF pointF, @NonNull LatLng latLng) {
        if (!isMarkerTab) {
            window.close();
        }
        isMarkerTab = false;
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("position", Convert.latLngToJson(latLng));
        channel.invokeMethod("map#onTap", arguments);
    }

    @Override
    public boolean onMapDoubleTap(@NonNull PointF pointF, @NonNull LatLng latLng) {
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("position", Convert.latLngToJson(latLng));
        channel.invokeMethod("map#onDoubleTap", arguments);
        return originalBehaviorDisable;
    }

    @Override
    public void onMapLongClick(@NonNull PointF pointF, @NonNull LatLng latLng) {
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("position", Convert.latLngToJson(latLng));
        channel.invokeMethod("map#onLongTap", arguments);
    }

    @Override
    public boolean onMapTwoFingerTap(@NonNull PointF pointF, @NonNull LatLng latLng) {
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("position", Convert.latLngToJson(latLng));
        channel.invokeMethod("map#onTwoFingerTap", arguments);
        return originalBehaviorDisable;
    }

    @Override
    public boolean onSymbolClick(@NonNull Symbol symbol) {
        final Map<String, Object> arguments = new HashMap<>(2);
        arguments.put("position", Convert.latLngToJson(symbol.getPosition()));
        arguments.put("caption", symbol.getCaption());
        channel.invokeMethod("map#onSymbolClick", arguments);
        return false;
    }

    @Override
    public void onCameraChange(int i, boolean b) {
        final Map<String, Object> arguments = new HashMap<>(2);
        LatLng latLng = naverMap.getCameraPosition().target;
        arguments.put("position", Convert.latLngToJson(latLng));
        channel.invokeMethod("camera#move", arguments);
    }

    @Override
    public void onCameraIdle() {
        channel.invokeMethod("camera#idle", null);
    }

    @Override
    public boolean onClick(@NonNull Overlay overlay) {
        if (overlay instanceof Marker) {
            isMarkerTab = true;
            Marker marker = (Marker) overlay;
            marker.setZIndex(marker.getZIndex() + 1);
            String markerId = MarkerBuilder.getMarkerId(marker);

            final Map<String, Object> arguments = new HashMap<>(2);
            arguments.put("markerId", markerId);
            arguments.put("iconWidth", marker.getIcon().getIntrinsicWidth(context));
            arguments.put("iconHeight", marker.getIcon().getIntrinsicHeight(context));

            channel.invokeMethod("marker#onTap", arguments);

            final String infoTitle = MarkerBuilder.getInfoWindow(marker);
            if (infoTitle != null) {
                window.setAdapter(new InfoWindow.DefaultTextAdapter(context) {
                    @NonNull
                    @Override
                    public CharSequence getText(@NonNull InfoWindow infoWindow) {
                        return infoTitle;
                    }
                });
                if (marker.getInfoWindow() == null) {
                    window.open(marker);
                } else {
                    window.close();
                }
            }
            return MarkerBuilder.getConsumeTabEvent((Marker) overlay);
        }
        return false;
    }
}
