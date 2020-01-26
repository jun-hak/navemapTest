package com.example.naver_map_flutter;

import static io.flutter.plugin.common.PluginRegistry.Registrar;

import android.content.Context;
// import com.google.android.gms.maps.model.CameraPosition;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

import java.util.List;
import java.util.Map;
import java.util.concurrent.atomic.AtomicInteger;

public class NaverMapFactory extends PlatformViewFactory {
    private final AtomicInteger activityState;
    private final Registrar pluginRegistrar;

    public NaverMapFactory(AtomicInteger state, Registrar registrar) {
        super(StandardMessageCodec.INSTANCE);
        activityState = state;
        pluginRegistrar = registrar;
    }

    @SuppressWarnings({ "unchecked", "ConstantConditions" })
    @Override
    public PlatformView create(Context context, int id, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        final NaverMapBuilder builder = new NaverMapBuilder();

        // Convert.interpretGoogleMapOptions(params.get("options"), builder);
        if (params.containsKey("initialCameraPosition")) {

            Map<String, Object> initPosition = (Map<String, Object>) params.get("initialCameraPosition");
            if (initPosition != null)
                builder.setInitialCameraPosition(initPosition);
        }
        if (params.containsKey("options")) {
            Map<String, Object> options = (Map<String, Object>) params.get("options");
            if (options.containsKey("isDevMode")) {
                boolean isDevMode = (boolean) options.get("isDevMode");
                builder.setDevMode(isDevMode);
            }
            Convert.carveMapOptions(builder, options);
        }
        if (params.containsKey("markersToAdd")) {
            builder.setInitialMarkers((List) params.get("markersToAdd"));
        }

        return builder.build(id, context, activityState, pluginRegistrar);
    }
}
