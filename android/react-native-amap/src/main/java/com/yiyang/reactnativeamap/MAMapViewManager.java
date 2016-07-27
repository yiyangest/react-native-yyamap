package com.yiyang.reactnativeamap;

import android.content.Context;
import android.os.StrictMode;
import android.support.annotation.Nullable;
import android.util.Log;

import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.CameraUpdateFactory;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.model.CameraPosition;
import com.amap.api.maps2d.model.LatLng;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;
import com.facebook.react.uimanager.SimpleViewManager;
import com.facebook.react.uimanager.ThemedReactContext;
import com.facebook.react.uimanager.annotations.ReactProp;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by yiyang on 16/3/1.
 */
public class MAMapViewManager extends SimpleViewManager<ReactMapView> {
    public static final String RCT_CLASS = "RCTAMap";

    private ReactMapView mMapView;

    private Context mContext;


    @Override
    public String getName() {
        return RCT_CLASS;
    }

    @Override
    protected ReactMapView createViewInstance(ThemedReactContext themedReactContext) {
        mMapView = new ReactMapView(themedReactContext);
        this.mContext = themedReactContext;
        mMapView.onCreate(null);
        StrictMode.ThreadPolicy policy = new StrictMode.ThreadPolicy.Builder().permitAll().build();
        StrictMode.setThreadPolicy(policy);
        return mMapView;
    }

    public ReactMapView getMapView() {
        return mMapView;
    }

    @ReactProp(name="showsUserLocation", defaultBoolean = false)
    public void showsUserLocation(MapView mapView, Boolean show) {
        mapView.getMap().setMyLocationEnabled(show);
    }

    @ReactProp(name="showsCompass", defaultBoolean = false)
    public void showsCompass(MapView mapView, Boolean show) {
        mapView.getMap().getUiSettings().setCompassEnabled(show);
    }

    @ReactProp(name="zoomEnabled", defaultBoolean = true)
    public void setZoomEnabled(MapView mapView, Boolean enable) {
        mapView.getMap().getUiSettings().setZoomGesturesEnabled(enable);
    }

    @ReactProp(name="rotateEnabled", defaultBoolean = true)
    public void setRotateEnabled(MapView mapView, Boolean enable) {
//        mapView.getMap().getUiSettings().setRotateGesturesEnabled(enable);
    }

    @ReactProp(name="pitchEnabled", defaultBoolean = false)
    public void setTiltGestureEnabled(MapView mapView, Boolean enable) {
//        mapView.getMap().getUiSettings().setTiltGesturesEnabled(enable);
    }

    @ReactProp(name="scrollEnabled", defaultBoolean = false)
    public void setScrollEnabled(MapView mapView, Boolean enable) {
        mapView.getMap().getUiSettings().setScrollGesturesEnabled(enable);
    }

    @ReactProp(name = "mapType", defaultInt = AMap.MAP_TYPE_NORMAL)
    public void setMapType(MapView mapView, int mapType) {
        mapView.getMap().setMapType(mapType);
    }

    @ReactProp(name = "annotations")
    public void setAnnotations(ReactMapView mapView, @Nullable ReadableArray value) throws Exception{
        AMap map = mapView.getMap();
        if (value == null || value.size() == 0) {
            Log.e(RCT_CLASS, "Error: no annotation");
            return;
        }

        List<ReactMapMarker> markers = new ArrayList<ReactMapMarker>();
        int size = value.size();
        for (int i = 0; i < size; i++) {
            ReadableMap annotation = value.getMap(i);
            ReactMapMarker marker = new ReactMapMarker(this.mContext);
            marker.buildMarker(annotation);
            markers.add(marker);
        }

        mapView.setMarker(markers);

    }

    @ReactProp(name = "overlays")
    public void setOverlays(ReactMapView mapView, @Nullable ReadableArray value) throws Exception{
        if (value == null || value.size() == 0) {
            return;
        }

        List<ReactMapOverlay> overlays = new ArrayList<ReactMapOverlay>();
        int size = value.size();
        for(int i = 0; i < size; i++) {
            ReadableMap overlay = value.getMap(i);
            ReactMapOverlay polyline = new ReactMapOverlay(overlay);
            overlays.add(polyline);
        }

        mapView.setOverlays(overlays);
    }

    @ReactProp(name = "region")
    public void setRegion(ReactMapView mapView, @Nullable ReadableMap center) {
        if (center != null) {
            double latitude = center.getDouble("latitude");
            double longitude = center.getDouble("longitude");
            int zoomLevel = center.getInt("zoomLevel");
            CameraPosition cameraPosition = new CameraPosition.Builder()
                    .target(new LatLng(latitude, longitude)).zoom(zoomLevel)
                    .build();
            mapView.getMap().moveCamera(CameraUpdateFactory.newCameraPosition(cameraPosition));
        }
    }
}
