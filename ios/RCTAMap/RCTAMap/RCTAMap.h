//
//  RCTAMap.h
//  RCTAMap
//
//  Created by yiyang on 16/2/26.
//  Copyright © 2016年 creditease. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>


#import "RCTConvert+AMapKit.h"
#import <React/RCTComponent.h>
#import "RCTAMapAnnotation.h"
#import "RCTAMapOverlay.h"

RCT_EXTERN const CLLocationDegrees RCTAMapDefaultSpan;
RCT_EXTERN const NSTimeInterval RCTAMapRegionChangeObserveInterval;
RCT_EXTERN const CGFloat RCTAMapZoomBoundBuffer;

@interface RCTAMap : MAMapView

@property (nonatomic, assign) BOOL followUserLocation;
@property (nonatomic, assign) BOOL hasStartedRendering;
@property (nonatomic, assign) CGFloat minDelta;
@property (nonatomic, assign) CGFloat maxDelta;
@property (nonatomic, assign) UIEdgeInsets legalLabelInsets;
@property (nonatomic, strong) NSTimer *regionChangeObserveTimer;
@property (nonatomic, copy) NSArray<NSString *> *annotationIDs;
@property (nonatomic, copy) NSArray<NSString *> *overlayIDs;

@property (nonatomic, copy) RCTBubblingEventBlock onChange;
@property (nonatomic, copy) RCTBubblingEventBlock onPress;
@property (nonatomic, copy) RCTBubblingEventBlock onAnnotationDragStateChange;
@property (nonatomic, copy) RCTBubblingEventBlock onAnnotationFocus;
@property (nonatomic, copy) RCTBubblingEventBlock onAnnotationBlur;

- (void)setAnnotations:(NSArray<RCTAMapAnnotation *> *)annotations;
- (void)setOverlays:(NSArray<RCTAMapOverlay *> *)overlays;

@end
