/**
 * 
 */
package com.yiyang.reactnativeamap;

import com.amap.api.maps2d.model.LatLng;

/**
 * @author iDay
 *
 */
public abstract class LatLngUtils {

	private static final double MERCATOR_OFFSET = 268435456;
	private static final double MERCATOR_RADIUS = 85445659.44705395;

	public static double longitudeToPixelSpaceX(double longitude) {
		return Math.round(MERCATOR_OFFSET + MERCATOR_RADIUS * longitude * Math.PI / 180.0);
	}

	public static double latitudeToPixelSpaceY(double latitude) {
		return Math
				.round(MERCATOR_OFFSET - MERCATOR_RADIUS
						* Math.log(
								(1 + Math.sin(latitude * Math.PI / 180.0)) / (1 - Math.sin(latitude * Math.PI / 180.0)))
						/ 2.0);
	}

	public static double pixelSpaceXToLongitude(double pixelX) {
		return ((Math.round(pixelX) - MERCATOR_OFFSET) / MERCATOR_RADIUS) * 180.0 / Math.PI;
	}

	public static double pixelSpaceYToLatitude(double pixelY) {
		return (Math.PI / 2.0 - 2.0 * Math.atan(Math.exp((Math.round(pixelY) - MERCATOR_OFFSET) / MERCATOR_RADIUS)))
				* 180.0 / Math.PI;
	}
	
	public static LatLng zoomToDelta(float zoom, LatLng center, int width, int height) {
		double centerPixelX = longitudeToPixelSpaceX(center.longitude);
		double centerPixelY = latitudeToPixelSpaceY(center.latitude);
		float zoomExponent = 20 - zoom;
		double zoomScale = Math.pow(2, zoomExponent);
		double scaledMapWidth = zoomScale * width;
		double scaledMapHeight = zoomScale * height;
		double topLeftPixelX = centerPixelX - (scaledMapWidth / 2);
		double topLeftPixelY = centerPixelY - (scaledMapHeight / 2);
		double minLng = pixelSpaceXToLongitude(topLeftPixelX);
		double maxLng = pixelSpaceXToLongitude(topLeftPixelX + scaledMapWidth);
		double longitudeDelta = maxLng - minLng;
		double minLat = pixelSpaceYToLatitude(topLeftPixelY);
		double maxLat = pixelSpaceYToLatitude(topLeftPixelY + scaledMapHeight);
		double latitudeDelta = -1 * (maxLat - minLat);
		return new LatLng(latitudeDelta, longitudeDelta);
	}
	
	public static float deltaToZoom(LatLng delta, LatLng center, int width, int height) {
		double centerPixelX = longitudeToPixelSpaceX(center.longitude);
		double topLeftPixelX = (longitudeToPixelSpaceX(center.longitude - delta.longitude / 2));
		double scaledMapWidth = (centerPixelX - topLeftPixelX) * 2;
		double zoomScale = scaledMapWidth / width;
		double zoomExponent = Math.log(zoomScale) / Math.log(2);
		float zoomLevel = (float) (20 - zoomExponent);
		return zoomLevel;
	}
}
