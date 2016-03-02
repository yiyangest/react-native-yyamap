package com.yiyang.reactnativeamap;

import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.Polyline;
import com.amap.api.maps2d.model.PolylineOptions;
import com.facebook.react.bridge.ReadableArray;
import com.facebook.react.bridge.ReadableMap;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by yiyang on 16/3/1.
 */
public class ReactMapOverlay {
    private Polyline mPolyline;
    private PolylineOptions mOptions;

    private String id;

    public ReactMapOverlay(ReadableMap overlay) throws Exception{
        if (overlay == null) {
            throw new Exception("overlay must not be null");
        }

        id = overlay.getString("id");

        mOptions = new PolylineOptions();

        if (overlay.hasKey("lineWidth")) {
            mOptions.width((float)overlay.getDouble("lineWidth"));
        }

        if (overlay.hasKey("strokeColor")) {
            mOptions.color(overlay.getInt("strokeColor"));
        }

        List<LatLng> coordinateList = new ArrayList<LatLng>();
        if (overlay.hasKey("coordinates")) {
            ReadableArray coordinates = overlay.getArray("coordinates");
            int size = coordinates.size();
            for (int i = 0; i < size; i++) {
                ReadableMap coordinate = coordinates.getMap(i);
                double latitude = coordinate.getDouble("latitude");
                double longitude = coordinate.getDouble("longitude");
                coordinateList.add(new LatLng(latitude, longitude));
            }
        }

        if (coordinateList.size() > 0) {
            mOptions.addAll(coordinateList);
        }
    }

    public String getId() {return this.id;}
    public Polyline getPolyline() {return this.mPolyline;}
    public PolylineOptions getOptions() {return this.mOptions;}

    public void addToMap(AMap map) {
        if (this.mPolyline == null) {
            this.mPolyline = map.addPolyline(this.mOptions);
        }
    }

}
