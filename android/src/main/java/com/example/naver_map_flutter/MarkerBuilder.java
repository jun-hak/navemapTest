package com.example.naver_map_flutter;

import com.naver.maps.map.overlay.Marker;

import java.util.HashMap;
import java.util.Map;

public class MarkerBuilder {

    private MarkerBuilder() {
    }

    @SuppressWarnings("ConstantConditions")
    static Marker build(Map<String, Object> data) {
        if (!data.containsKey("markerId") || !data.containsKey("position") || !data.containsKey("consumeTapEvents"))
            throw new AssertionError();

        Marker marker = new Marker();
        HashMap<String, Object> tags = new HashMap<>();
        tags.put("markerId", data.get("markerId"));
        tags.put("consumeTapEvents", data.get("consumeTapEvents"));
        if (data.containsKey("infoWindow")) {
            tags.put("infoWindow", data.get("infoWindow"));
        }
        marker.setTag(tags);

        marker.setPosition(Convert.toLatLng(data.get("position")));

        if (data.containsKey("alpha"))
            marker.setAlpha(Convert.toFloat(data.get("alpha")));
        if (data.containsKey("flat"))
            marker.setFlat((Boolean) data.get("flat"));
        if (data.containsKey("visible"))
            marker.setVisible((Boolean) data.get("visible"));
        if (data.containsKey("captionText"))
            marker.setCaptionText((String) data.get("captionText"));
        if (data.containsKey("captionTextSize"))
            marker.setCaptionTextSize(Convert.toFloat(data.get("captionTextSize")));
        if (data.containsKey("captionColor"))
            marker.setCaptionColor((Integer) data.get("captionColor"));
        if (data.containsKey("width"))
            marker.setWidth((Integer) data.get("width"));
        if (data.containsKey("height"))
            marker.setHeight((Integer) data.get("height"));
        if (data.containsKey("maxZoom"))
            marker.setMaxZoom((Double) data.get("maxZoom"));
        if (data.containsKey("minZoom"))
            marker.setMinZoom((Double) data.get("minZoom"));
        if (data.containsKey("angle"))
            marker.setAngle(Convert.toFloat(data.get("angle")));
        if (data.containsKey("captionRequestedWidth"))
            marker.setCaptionRequestedWidth((Integer) data.get("captionRequestedWidth"));
        if (data.containsKey("captionMaxZoom"))
            marker.setCaptionMaxZoom((Double) data.get("captionMaxZoom"));
        if (data.containsKey("captionMinZoom"))
            marker.setCaptionMinZoom((Double) data.get("captionMinZoom"));
        if (data.containsKey("captionOffset"))
            marker.setCaptionOffset((Integer) data.get("captionOffset"));
        if (data.containsKey("captionPerspectiveEnabled"))
            marker.setCaptionPerspectiveEnabled((Boolean) data.get("captionPerspectiveEnabled"));
        if (data.containsKey("zIndex"))
            marker.setZIndex((Integer) data.get("zIndex"));
        if (data.containsKey("globalZIndex"))
            marker.setGlobalZIndex((Integer) data.get("globalZIndex"));
        if (data.containsKey("iconTintColor"))
            marker.setIconTintColor((Integer) data.get("iconTintColor"));
        if (data.containsKey("subCaptionText"))
            marker.setSubCaptionText((String) data.get("subCaptionText"));
        if (data.containsKey("subCaptionTextSize"))
            marker.setSubCaptionTextSize(Convert.toFloat(data.get("subCaptionTextSize")));
        if (data.containsKey("subCaptionColor"))
            marker.setSubCaptionColor((Integer) data.get("subCaptionColor"));
        if (data.containsKey("subCaptionHaloColor"))
            marker.setSubCaptionHaloColor((Integer) data.get("subCaptionHaloColor"));
        if (data.containsKey("subCaptionRequestedWidth"))
            marker.setSubCaptionRequestedWidth((Integer) data.get("subCaptionRequestedWidth"));
        if (data.containsKey("icon")) {
            marker.setIcon(Convert.toOverlayImage(data.get("icon")));
        }

        return marker;
    }

    @SuppressWarnings("unchecked")
    static String getMarkerId(Marker marker) {
        Map<String, Object> tags = (Map<String, Object>) marker.getTag();
        if (tags == null || !tags.containsKey("markerId"))
            throw new AssertionError();
        return (String) tags.get("markerId");
    }

    @SuppressWarnings("unchecked")
    static boolean getConsumeTabEvent(Marker marker) {
        Map<String, Object> tags = (Map<String, Object>) marker.getTag();
        if (tags == null || !tags.containsKey("consumeTapEvents"))
            throw new AssertionError();
        return (boolean) tags.get("consumeTapEvents");
    }

    @SuppressWarnings("unchecked")
    static String getInfoWindow(Marker marker) {
        Map<String, Object> tags = (Map<String, Object>) marker.getTag();
        if (tags == null || !tags.containsKey("infoWindow"))
            return null;
        return (String) tags.get("infoWindow");
    }

}
