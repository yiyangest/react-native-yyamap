//
//  RCTAMapManager.m
//  RCTAMap
//
//  Created by yiyang on 16/2/26.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import "RCTAMapManager.h"

#import "RCTBridge.h"
#import "RCTConvert+CoreLocation.h"
#import "RCTConvert+AMapKit.h"
#import "RCTEventDispatcher.h"
#import "RCTAMap.h"
#import "RCTUtils.h"
#import "UIView+React.h"
#import "RCTAMapAnnotation.h"
#import "RCTAMapOverlay.h"

#import <MAMapKit/MAMapKit.h>

static NSString *const RCTAMapViewKey = @"AMapView";

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_9_0

static NSString *const RCTAMapPinRed = @"#ff3b30";
static NSString *const RCTAMapPinGreen = @"#4cd964";
static NSString *const RCTAMapPinPurple = @"#c969e0";

@implementation RCTConvert (MAPinAnnotationColor)

RCT_ENUM_CONVERTER(MAPinAnnotationColor, (@{
                                            RCTAMapPinRed: @(MAPinAnnotationColorRed),
                                            RCTAMapPinGreen: @(MAPinAnnotationColorGreen),
                                            RCTAMapPinPurple: @(MAPinAnnotationColorPurple)
                                            }), MAPinAnnotationColorRed, unsignedIntegerValue)

@end

#endif

@interface RCTAMapAnnotationView : MAAnnotationView

@property (nonatomic, strong) UIView *contentView;

@end

@implementation RCTAMapAnnotationView

- (void)setContentView:(UIView *)contentView
{
    [_contentView removeFromSuperview];
    _contentView = contentView;
    [self addSubview:_contentView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.bounds = (CGRect){
        CGPointZero,
        _contentView.frame.size,
    };
}

@end

@interface RCTAMapManager () <MAMapViewDelegate>

@end

@implementation RCTAMapManager

RCT_EXPORT_MODULE()

- (UIView *)view
{
    RCTAMap *map = [RCTAMap new];
    map.delegate = self;
    return map;
}

RCT_EXPORT_VIEW_PROPERTY(showsUserLocation, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsPointsOfInterest, BOOL)
RCT_EXPORT_VIEW_PROPERTY(showsCompass, BOOL)
RCT_EXPORT_VIEW_PROPERTY(followUserLocation, BOOL)
RCT_EXPORT_VIEW_PROPERTY(zoomEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(rotateEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(pitchEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(scrollEnabled, BOOL)
RCT_EXPORT_VIEW_PROPERTY(maxDelta, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(minDelta, CGFloat)
RCT_EXPORT_VIEW_PROPERTY(legalLabelInsets, UIEdgeInsets)
RCT_EXPORT_VIEW_PROPERTY(mapType, MAMapType)
RCT_EXPORT_VIEW_PROPERTY(annotations, NSArray<RCTAMapAnnotation *>)
RCT_EXPORT_VIEW_PROPERTY(overlays, NSArray<RCTAMapOverlay *>)
RCT_EXPORT_VIEW_PROPERTY(onAnnotationDragStateChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAnnotationFocus, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onAnnotationBlur, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onChange, RCTBubblingEventBlock)
RCT_EXPORT_VIEW_PROPERTY(onPress, RCTBubblingEventBlock)
RCT_CUSTOM_VIEW_PROPERTY(region, MACoordinateRegion, RCTAMap)
{
    [view setRegion:json ? [RCTConvert MACoordinateRegion:json] : defaultView.region animated:YES];
}

- (NSDictionary<NSString *, id> *)constantsToExport
{
    NSUInteger red, green, purple;
    
    red = MAPinAnnotationColorRed;
    green = MAPinAnnotationColorGreen;
    purple = MAPinAnnotationColorPurple;
    

    return @{
             @"PinColors": @{
                     @"RED": @(red),
                     @"GREEN": @(green),
                     @"PURPLE": @(purple),
                     }
             };
    
}

#pragma mark - MAMapViewDelegate

- (void)mapView:(RCTAMap *)mapView didSelectAnnotationView:(MAAnnotationView *)view
{
    if (mapView.onPress && [view.annotation isKindOfClass:[RCTAMapAnnotation class]]) {
        RCTAMapAnnotation *annotation = (RCTAMapAnnotation *)view.annotation;
        mapView.onPress(@{
                          @"action": @"annotation-click",
                          @"annotation": @{
                                  @"id": annotation.identifier,
                                  @"title": annotation.title ?: @"",
                                  @"subtitle": annotation.subtitle ?: @"",
                                  @"latitude": @(annotation.coordinate.latitude),
                                  @"longitude": @(annotation.coordinate.longitude)
                                  }
                          });
    }
    
    if ([view.annotation isKindOfClass:[RCTAMapAnnotation class]]) {
        RCTAMapAnnotation *annotation = (RCTAMapAnnotation *)view.annotation;
        if (mapView.onAnnotationFocus) {
            mapView.onAnnotationFocus(@{
                                        @"annotationId": annotation.identifier
                                        });
        }
    }
}

- (void)mapView:(RCTAMap *)mapView didDeselectAnnotationView:(MAAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[RCTAMapAnnotation class]]) {
        RCTAMapAnnotation *annotation = (RCTAMapAnnotation *)view.annotation;
        if (mapView.onAnnotationBlur) {
            mapView.onAnnotationBlur(@{
                                        @"annotationId": annotation.identifier
                                        });
        }
    }
}

- (void)mapView:(RCTAMap *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState
{
    static NSArray *states;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        states = @[@"idle", @"starting", @"dragging", @"canceling", @"ending"];
    });
    
    if ([view.annotation isKindOfClass:[RCTAMapAnnotation class]]) {
        RCTAMapAnnotation *annotation = (RCTAMapAnnotation *)view.annotation;
        if (mapView.onAnnotationDragStateChange) {
            mapView.onAnnotationDragStateChange(@{
                                                  @"state": states[newState],
                                                  @"oldState": states[oldState],
                                                  @"annotationId": annotation.identifier,
                                                  @"latitude": @(annotation.coordinate.latitude),
                                                  @"longitude": @(annotation.coordinate.longitude),
                                                  });
        }
    }
}

- (MAAnnotationView *)mapView:(RCTAMap *)mapView viewForAnnotation:(RCTAMapAnnotation *)annotation
{
    if (![annotation isKindOfClass:[RCTAMapAnnotation class]]) {
        return nil;
    }
    
    MAAnnotationView *annotationView;
    if (annotation.viewIndex != NSNotFound) {
        NSString *reuseIdentifier = NSStringFromClass([RCTAMapAnnotationView class]);
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (!annotationView) {
            annotationView = [[RCTAMapAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        UIView *reactView = mapView.reactSubviews[annotation.viewIndex];
        ((RCTAMapAnnotationView *)annotationView).contentView = reactView;
    } else if (annotation.image) {
        NSString *reuseIdentifier = NSStringFromClass([MAAnnotationView class]);
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        if (!annotationView) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        annotationView.image = annotation.image;
    } else {
        
        NSString *reuseIdentifier = NSStringFromClass([MAPinAnnotationView class]);
        annotationView =
        [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier] ?:
        [[MAPinAnnotationView alloc] initWithAnnotation:annotation
                                        reuseIdentifier:reuseIdentifier];
        ((MAPinAnnotationView *)annotationView).animatesDrop = annotation.animateDrop;
        
        ((MAPinAnnotationView *)annotationView).pinColor = annotation.tintColor;
        
        
    }
    
    annotationView.canShowCallout = (annotation.title.length > 0);
    
    if (annotation.leftCalloutViewIndex != NSNotFound) {
        annotationView.leftCalloutAccessoryView = mapView.reactSubviews[annotation.leftCalloutViewIndex];
    } else if (annotation.hasLeftCallout) {
        annotationView.leftCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        annotationView.leftCalloutAccessoryView = nil;
    }
    
    if (annotation.rightCalloutViewIndex != NSNotFound) {
        annotationView.rightCalloutAccessoryView = mapView.reactSubviews[annotation.rightCalloutViewIndex];
    } else if (annotation.hasRightCallout) {
        annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    } else {
        annotationView.rightCalloutAccessoryView = nil;
    }
    
    annotationView.draggable = annotation.draggable;
    return annotationView;
}

- (MAOverlayRenderer *)mapView:(RCTAMap *)mapView rendererForOverlay:(RCTAMapOverlay *)overlay
{
    if ([overlay isKindOfClass:[RCTAMapOverlay class]]) {
        MAPolylineRenderer *polylineRenderer = [[MAPolylineRenderer alloc] initWithPolyline:overlay];
        polylineRenderer.strokeColor = overlay.strokeColor;
        polylineRenderer.lineWidth = overlay.lineWidth;
        return polylineRenderer;
    }
    
    return nil;
}

- (void)mapView:(RCTAMap *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if (mapView.onPress) {
        // Pass to JS
        RCTAMapAnnotation *annotation = (RCTAMapAnnotation *)view.annotation;
        mapView.onPress(@{
                          @"side": (control == view.leftCalloutAccessoryView) ? @"left" : @"right",
                          @"action": @"callout-click",
                          @"annotationId": annotation.identifier
                          });
    }
}

- (void)mapView:(RCTAMap *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (mapView.followUserLocation) {
        MACoordinateRegion region;
        region.span.latitudeDelta = RCTAMapDefaultSpan;
        region.span.longitudeDelta = RCTAMapDefaultSpan;
        region.center = userLocation.coordinate;
        [mapView setRegion:region animated:YES];
    }
}

- (void)mapView:(RCTAMap *)mapView regionWillChangeAnimated:(BOOL)animated
{
    [self _regionChanged:mapView];
    mapView.regionChangeObserveTimer = [NSTimer timerWithTimeInterval:RCTAMapRegionChangeObserveInterval target:self selector:@selector(_onTick:) userInfo:@{RCTAMapViewKey: mapView} repeats:YES];
    
    [[NSRunLoop mainRunLoop] addTimer:mapView.regionChangeObserveTimer forMode:NSRunLoopCommonModes];
}

- (void)mapView:(RCTAMap *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [mapView.regionChangeObserveTimer invalidate];
    mapView.regionChangeObserveTimer = nil;
    
    [self _regionChanged:mapView];
    
    if (mapView.hasStartedRendering) {
        [self _emitRegionChangeEvent:mapView continuous:NO];
    }
}

- (void)mapViewWillStartLoadingMap:(RCTAMap *)mapView
{
    mapView.hasStartedRendering = YES;
    [self _emitRegionChangeEvent:mapView continuous:NO];
}

#pragma mark - Private

- (void)_onTick:(NSTimer *)timer
{
    [self _regionChanged:timer.userInfo[RCTAMapViewKey]];
}

- (void)_regionChanged:(RCTAMap *)mapView
{
    BOOL needZoom = NO;
    CGFloat newLongitudeDelta = 0.0f;
    MACoordinateRegion region = mapView.region;
    
    if (!CLLocationCoordinate2DIsValid(region.center)) {
        return;
    }
    
    if (mapView.maxDelta > FLT_EPSILON && region.span.longitudeDelta > mapView.maxDelta) {
        needZoom = YES;
        newLongitudeDelta = mapView.maxDelta * (1 - RCTAMapZoomBoundBuffer);
    } else if (mapView.minDelta > FLT_EPSILON && region.span.longitudeDelta < mapView.minDelta) {
        needZoom = YES;
        newLongitudeDelta = mapView.minDelta * (1 + RCTAMapZoomBoundBuffer);
    }
    if (needZoom) {
        region.span.latitudeDelta = region.span.latitudeDelta / region.span.longitudeDelta * newLongitudeDelta;
        region.span.longitudeDelta = newLongitudeDelta;
        mapView.region = region;
    }
    
    [self _emitRegionChangeEvent:mapView continuous:YES];
}

- (void)_emitRegionChangeEvent:(RCTAMap *)mapView continuous:(BOOL)continuous
{
    if (mapView.onChange) {
        MACoordinateRegion region = mapView.region;
        if (!CLLocationCoordinate2DIsValid(region.center)) {
            return;
        }
        
        mapView.onChange(@{
                           @"continuous": @(continuous),
                           @"region": @{
                                   @"latitude": @(RCTZeroIfNaN(region.center.latitude)),
                                   @"longitude": @(RCTZeroIfNaN(region.center.longitude)),
                                   @"latitudeDelta": @(RCTZeroIfNaN(region.span.latitudeDelta)),
                                   @"longitudeDelta": @(RCTZeroIfNaN(region.span.longitudeDelta)),
                                   }
                           });
    }
}

@end
