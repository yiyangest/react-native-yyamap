package com.yiyang.reactnativeamap;

import java.util.ArrayList;
import java.util.List;

import com.amap.api.maps2d.AMap.OnCameraChangeListener;
import com.amap.api.maps2d.MapView;
import com.amap.api.maps2d.model.CameraPosition;
import com.amap.api.maps2d.model.LatLng;
import com.facebook.react.bridge.Arguments;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.WritableMap;
import com.facebook.react.uimanager.events.RCTEventEmitter;

import android.content.Context;

/**
 * Created by yiyang on 16/2/29.
 */
public class ReactMapView extends MapView implements OnCameraChangeListener {
	private List<ReactMapMarker> mMarkers = new ArrayList<ReactMapMarker>();
	private List<String> mMarkerIds = new ArrayList<String>();

	private List<ReactMapOverlay> mOverlays = new ArrayList<ReactMapOverlay>();
	private List<String> mOverlayIds = new ArrayList<String>();

	public ReactMapView(Context context) {
		super(context);
		this.getMap().setOnCameraChangeListener(this);
	}

	public void setOverlays(List<ReactMapOverlay> overlays) {
		List<String> newOverlayIds = new ArrayList<String>();
		List<ReactMapOverlay> overlaysToDelete = new ArrayList<ReactMapOverlay>();
		List<ReactMapOverlay> overlaysToAdd = new ArrayList<ReactMapOverlay>();

		for (ReactMapOverlay overlay : overlays) {
			if (overlay instanceof ReactMapOverlay == false) {
				continue;
			}

			newOverlayIds.add(overlay.getId());

			if (!mOverlayIds.contains(overlay.getId())) {
				overlaysToAdd.add(overlay);
			}
		}

		for (ReactMapOverlay overlay : this.mOverlays) {
			if (overlay instanceof ReactMapOverlay == false) {
				continue;
			}

			if (!newOverlayIds.contains(overlay.getId())) {
				overlaysToDelete.add(overlay);
			}
		}

		if (!overlaysToDelete.isEmpty()) {
			for (ReactMapOverlay overlay : overlaysToDelete) {
				overlay.getPolyline().remove();
				this.mOverlays.remove(overlay);
			}
		}

		if (!overlaysToAdd.isEmpty()) {
			for (ReactMapOverlay overlay : overlaysToAdd) {
				if (overlay.getOptions() != null) {
					overlay.addToMap(this.getMap());
					this.mOverlays.add(overlay);
				}
			}
		}

		this.mOverlayIds = newOverlayIds;

	}

	public void setMarker(List<ReactMapMarker> markers) {

		List<String> newMarkerIds = new ArrayList<String>();
		List<ReactMapMarker> markersToDelete = new ArrayList<ReactMapMarker>();
		List<ReactMapMarker> markersToAdd = new ArrayList<ReactMapMarker>();

		for (ReactMapMarker marker : markers) {
			if (marker instanceof ReactMapMarker == false) {
				continue;
			}

			newMarkerIds.add(marker.getId());

			if (!mMarkerIds.contains(marker.getId())) {
				markersToAdd.add(marker);
			}
		}

		for (ReactMapMarker marker : this.mMarkers) {
			if (marker instanceof ReactMapMarker == false) {
				continue;
			}

			if (!newMarkerIds.contains(marker.getId())) {
				markersToDelete.add(marker);
			}
		}

		if (!markersToDelete.isEmpty()) {
			for (ReactMapMarker marker : markersToDelete) {
				marker.getMarker().destroy();
				this.mMarkers.remove(marker);
			}
		}

		if (!markersToAdd.isEmpty()) {
			for (ReactMapMarker marker : markersToAdd) {
				if (marker.getOptions() != null) {
					marker.addToMap(this.getMap());
					this.mMarkers.add(marker);
				}
			}
		}

		this.mMarkerIds = newMarkerIds;
	}

	public void onNativeEvent(String eventName, WritableMap eventData) {
		ReactContext reactContext = (ReactContext) getContext();
		reactContext.getJSModule(RCTEventEmitter.class).receiveEvent(getId(), eventName, eventData);
	}

	@Override
	public void onCameraChange(CameraPosition position) {
		LatLng delta = LatLngUtils.zoomToDelta(position.zoom, position.target, this.getWidth(), this.getHeight());
		WritableMap eventData = Arguments.createMap();
		WritableMap region = Arguments.createMap();
		eventData.putBoolean("continuous", true);
		region.putDouble("latitude", position.target.latitude);
		region.putDouble("longitude", position.target.longitude);
		region.putDouble("latitudeDelta", delta.latitude);
		region.putDouble("longitudeDelta", delta.longitude);
		eventData.putMap("region", region);
		this.onNativeEvent("topChange", eventData);
	}

	@Override
	public void onCameraChangeFinish(CameraPosition position) {
		LatLng delta = LatLngUtils.zoomToDelta(position.zoom, position.target, this.getWidth(), this.getHeight());
		WritableMap eventData = Arguments.createMap();
		WritableMap region = Arguments.createMap();
		eventData.putBoolean("continuous", false);
		region.putDouble("latitude", position.target.latitude);
		region.putDouble("longitude", position.target.longitude);
		region.putDouble("latitudeDelta", delta.latitude);
		region.putDouble("longitudeDelta", delta.longitude);
		eventData.putMap("region", region);
		this.onNativeEvent("topChange", eventData);
	}

}
