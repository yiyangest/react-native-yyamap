package com.yiyang.reactnativeamap;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.drawable.Animatable;
import android.net.Uri;

import com.amap.api.maps2d.AMap;
import com.amap.api.maps2d.model.BitmapDescriptor;
import com.amap.api.maps2d.model.BitmapDescriptorFactory;
import com.amap.api.maps2d.model.LatLng;
import com.amap.api.maps2d.model.Marker;
import com.amap.api.maps2d.model.MarkerOptions;
import com.facebook.common.references.CloseableReference;
import com.facebook.datasource.DataSource;
import com.facebook.drawee.backends.pipeline.Fresco;
import com.facebook.drawee.controller.BaseControllerListener;
import com.facebook.drawee.controller.ControllerListener;
import com.facebook.drawee.drawable.ScalingUtils;
import com.facebook.drawee.generic.GenericDraweeHierarchy;
import com.facebook.drawee.generic.GenericDraweeHierarchyBuilder;
import com.facebook.drawee.interfaces.DraweeController;
import com.facebook.drawee.view.DraweeHolder;
import com.facebook.imagepipeline.core.ImagePipeline;
import com.facebook.imagepipeline.image.CloseableImage;
import com.facebook.imagepipeline.image.CloseableStaticBitmap;
import com.facebook.imagepipeline.image.ImageInfo;
import com.facebook.imagepipeline.request.ImageRequest;
import com.facebook.imagepipeline.request.ImageRequestBuilder;
import com.facebook.react.bridge.ReadableMap;

/**
 * Created by yiyang on 16/3/1.
 */
public class ReactMapMarker {
    private Marker mMarker;
    private MarkerOptions mOptions;

    private String id;

    private Context mContext;


    private BitmapDescriptor iconBitmapDescriptor;
    private final DraweeHolder mLogoHolder;
    private DataSource<CloseableReference<CloseableImage>> dataSource;

    private final ControllerListener<ImageInfo> mLogoControllerListener =
            new BaseControllerListener<ImageInfo>() {
                @Override
                public void onFinalImageSet(String id, ImageInfo imageInfo, Animatable animatable) {
                    CloseableReference<CloseableImage> imageReference = null;
                    try {
                        imageReference = dataSource.getResult();
                        if (imageReference != null) {
                            CloseableImage image = imageReference.get();
                            if (image != null && image instanceof CloseableStaticBitmap) {
                                CloseableStaticBitmap closeableStaticBitmap = (CloseableStaticBitmap)image;
                                Bitmap bitmap = closeableStaticBitmap.getUnderlyingBitmap();
                                if (bitmap != null) {
                                    bitmap = bitmap.copy(Bitmap.Config.ARGB_8888, true);
                                    iconBitmapDescriptor = BitmapDescriptorFactory.fromBitmap(bitmap);
                                }
                            }
                        }
                    } finally {
                        dataSource.close();
                        if (imageReference != null) {
                            CloseableReference.closeSafely(imageReference);
                        }
                    }
                    update();
                }
            };

    public ReactMapMarker(Context context) {
        this.mContext = context;
        mLogoHolder = DraweeHolder.create(createDraweeHierarchy(), null);
        mLogoHolder.onAttach();
    }

    public void buildMarker(ReadableMap annotation) throws Exception{
        if (annotation == null) {
            throw new Exception("marker annotation must not be null");
        }
        id = annotation.getString("id");
        MarkerOptions options = new MarkerOptions();
        double latitude = annotation.getDouble("latitude");
        double longitude = annotation.getDouble("longitude");

        options.position(new LatLng(latitude, longitude));

        if (annotation.hasKey("draggable")) {

            boolean draggable = annotation.getBoolean("draggable");
            options.draggable(draggable);
        }

        if (annotation.hasKey("title")) {
            options.title(annotation.getString("title"));
        }

        if (annotation.hasKey("subtitle")) {
            options.snippet(annotation.getString("subtitle"));
        }

        if (annotation.hasKey("image")) {
            String imgUri = annotation.getMap("image").getString("uri");
            if (imgUri != null && imgUri.length() > 0) {
                if (imgUri.startsWith("http://") || imgUri.startsWith("https://")) {
                    ImageRequest imageRequest = ImageRequestBuilder.newBuilderWithSource(Uri.parse(imgUri)).build();
                    ImagePipeline imagePipeline = Fresco.getImagePipeline();
                    dataSource = imagePipeline.fetchDecodedImage(imageRequest,this);
                    DraweeController controller = Fresco.newDraweeControllerBuilder()
                            .setImageRequest(imageRequest)
                            .setControllerListener(mLogoControllerListener)
                            .setOldController(mLogoHolder.getController())
                            .build();
                    mLogoHolder.setController(controller);
                } else {
                    options.icon(BitmapDescriptorFactory.fromPath(imgUri));
                }
            }
        }

        this.mOptions = options;

    }

    private GenericDraweeHierarchy createDraweeHierarchy() {
        return new GenericDraweeHierarchyBuilder(this.mContext.getResources())
                .setActualImageScaleType(ScalingUtils.ScaleType.FIT_CENTER)
                .setFadeDuration(0)
                .build();
    }

    public String getId() {return this.id;}
    public Marker getMarker() {return this.mMarker;}
    public MarkerOptions getOptions() {return this.mOptions;}

    public void addToMap(AMap map) {
        if (this.mMarker == null) {
            this.mMarker = map.addMarker(this.getOptions());
        }
    }

    private BitmapDescriptor getIcon() {
        if (iconBitmapDescriptor != null) {
            return iconBitmapDescriptor;
        } else {
            return BitmapDescriptorFactory.defaultMarker();
        }
    }

    public void update() {
        if (this.mMarker != null) {
            this.mMarker.setIcon(getIcon());
        } else {
            this.mOptions.icon(getIcon());
        }
    }



}
