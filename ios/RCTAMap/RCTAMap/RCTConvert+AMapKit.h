//
//  RCTConvert+AMapKit.h
//  RCTAMap
//
//  Created by yiyang on 16/2/29.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

#import <React/RCTConvert.h>

@class RCTAMapAnnotation;
@class RCTAMapOverlay;

@interface RCTConvert (AMapKit)

+ (MACoordinateSpan)MACoordinateSpan:(id)json;
+ (MACoordinateRegion)MACoordinateRegion:(id)json;
+ (MAMapType)MAMapType:(id)json;

+ (RCTAMapAnnotation *)RCTAMapAnnotation:(id)json;
+ (RCTAMapOverlay *)RCTAMapOverlay:(id)json;

+ (NSArray<RCTAMapAnnotation *> *)RCTAMapAnnotationArray:(id)json;
+ (NSArray<RCTAMapOverlay *> *)RCTAMapOverlayArray:(id)json;

@end
