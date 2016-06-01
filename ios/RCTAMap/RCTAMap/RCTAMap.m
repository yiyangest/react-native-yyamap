//
//  RCTAMap.m
//  RCTAMap
//
//  Created by yiyang on 16/2/26.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import "RCTAMap.h"

#import "RCTEventDispatcher.h"
#import "RCTLog.h"
#import "RCTAMapAnnotation.h"
#import "RCTAMapOverlay.h"
#import "RCTUtils.h"

const CLLocationDegrees RCTAMapDefaultSpan = 0.005;
const NSTimeInterval RCTAMapRegionChangeObserveInterval = 0.1;
const CGFloat RCTAMapZoomBoundBuffer = 0.01;

@implementation RCTAMap
{
    UIView *_legalLabel;
    CLLocationManager *_locationManager;
    NSMutableArray<UIView *> *_reactSubviews;
}

- (instancetype)init
{
    if ((self = [super init])) {
        _hasStartedRendering = NO;
        _reactSubviews = [NSMutableArray new];
        
        for (UIView *subview in self.subviews) {
            if ([NSStringFromClass(subview.class) isEqualToString:@"MKAttributionLabel"]) {
                _legalLabel = subview;
                break;
            }
        }
    }
    return self;
}

- (void)dealloc
{
    [_regionChangeObserveTimer invalidate];
}

- (void)insertReactSubview:(UIView *)subview atIndex:(NSInteger)atIndex
{
    [_reactSubviews insertObject:subview atIndex:atIndex];
}

- (void)removeReactSubviews: (UIView *)subview
{
    [_reactSubviews removeObject:subview];
}

- (NSArray<UIView *> *)reactSubviews
{
    return _reactSubviews;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (_legalLabel) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CGRect frame = _legalLabel.frame;
            if (_legalLabelInsets.left) {
                frame.origin.x = _legalLabelInsets.left;
            } else if (_legalLabelInsets.right) {
                frame.origin.x = self.frame.size.width - _legalLabelInsets.right - frame.size.width;
            }
            if (_legalLabelInsets.top) {
                frame.origin.y = _legalLabelInsets.top;
            } else if (_legalLabelInsets.bottom) {
                frame.origin.y = self.frame.size.height - _legalLabelInsets.bottom - frame.size.height;
            }
            _legalLabel.frame = frame;
        });
    }
}

#pragma mark - Accessors

- (void)setShowsUserLocation:(BOOL)showsUserLocation
{
    if (self.showsUserLocation != showsUserLocation) {
        if (showsUserLocation && !_locationManager) {
            _locationManager = [CLLocationManager new];
            if ([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
                [_locationManager requestWhenInUseAuthorization];
            }
        }
        super.showsUserLocation = showsUserLocation;
    }
}

- (void)setRegion:(MACoordinateRegion)region animated:(BOOL)animated
{
    if (!CLLocationCoordinate2DIsValid(region.center)) {
        return;
    }
    
    if (!region.span.latitudeDelta) {
        region.span.latitudeDelta = self.region.span.latitudeDelta;
    }
    if (!region.span.longitudeDelta) {
        region.span.longitudeDelta = self.region.span.longitudeDelta;
    }
    
    [super setRegion:region animated:animated];
}

- (void)setAnnotations:(NSArray<RCTAMapAnnotation *> *)annotations
{
    NSMutableArray<NSString *> *newAnnotationIDs = [NSMutableArray new];
    NSMutableArray<RCTAMapAnnotation *> *annotationsToDelete = [NSMutableArray new];
    NSMutableArray<RCTAMapAnnotation *> *annotationsToAdd = [NSMutableArray new];
    
    for (RCTAMapAnnotation *annotation in annotations) {
        if (![annotation isKindOfClass:[RCTAMapAnnotation class]]) {
            continue;
        }
        
        [newAnnotationIDs addObject:annotation.identifier];
        
        if (![_annotationIDs containsObject:annotation.identifier]) {
            [annotationsToAdd addObject:annotation];
        }
    }
    for (RCTAMapAnnotation *annotation in self.annotations) {
        if (![annotations isKindOfClass:[RCTAMapAnnotation class]]) {
            continue;
        }
        
        if (![newAnnotationIDs containsObject:annotation.identifier]) {
            [annotationsToDelete addObject:annotation];
        }
    }
    
    if (annotationsToDelete.count > 0) {
        [self removeAnnotations:(NSArray<id<MAAnnotation>> *)annotationsToDelete];
    }
    
    if (annotationsToAdd.count > 0) {
        [self addAnnotations:(NSArray<id<MAAnnotation>> *)annotationsToAdd];
    }
    
    self.annotationIDs = newAnnotationIDs;
}

- (void)setOverlays:(NSArray<RCTAMapOverlay *> *)overlays
{
    NSMutableArray<NSString *> *newOverlayIDs = [NSMutableArray new];
    NSMutableArray<RCTAMapOverlay *> *overlaysToDelete = [NSMutableArray new];
    NSMutableArray<RCTAMapOverlay *> *overlaysToAdd = [NSMutableArray new];
    
    for (RCTAMapOverlay *overlay in overlays) {
        if (![overlay isKindOfClass:[RCTAMapOverlay class]]) {
            continue;
        }
        
        [newOverlayIDs addObject:overlay.identifier];
        
        if (![_overlayIDs containsObject:overlay.identifier]) {
            [overlaysToAdd addObject:overlay];
        }
    }
    
    for (RCTAMapOverlay *overlay in self.overlays) {
        if (![overlay isKindOfClass:[RCTAMapOverlay class]]) {
            continue;
        }
        
        if (![newOverlayIDs containsObject:overlay.identifier]) {
            [overlaysToDelete addObject:overlay];
        }
    }
    
    if (overlaysToDelete.count > 0) {
        [self removeOverlays:(NSArray<id<MAOverlay>> *)overlaysToDelete];
    }
    if (overlaysToAdd.count > 0) {
        [self addOverlays:(NSArray<id<MAOverlay>> *)overlaysToAdd];
    }
    
    self.overlayIDs = newOverlayIDs;
}

- (BOOL)showsCompass {
    if ([MAMapView instancesRespondToSelector:@selector(showsCompass)]) {
        return super.showsCompass;
    }
    return NO;
}

- (void)setShowsCompass:(BOOL)showsCompass {
    if ([MAMapView instancesRespondToSelector:@selector(setShowsCompass:)]) {
        super.showsCompass = showsCompass;
    }
}


@end
