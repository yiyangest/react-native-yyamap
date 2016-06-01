//
//  RCTConvert+AMapKit.m
//  RCTAMap
//
//  Created by yiyang on 16/2/29.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import "RCTConvert+AMapKit.h"
#import "RCTConvert+CoreLocation.h"
#import "RCTAMapAnnotation.h"
#import "RCTAMapOverlay.h"

@implementation RCTConvert (AMapKit)

+ (MACoordinateSpan)MACoordinateSpan:(id)json
{
    json = [self NSDictionary:json];
    return (MACoordinateSpan){
        [self CLLocationDegrees:json[@"latitudeDelta"]],
        [self CLLocationDegrees:json[@"longitudeDelta"]]
    };
}

+ (MACoordinateRegion)MACoordinateRegion:(id)json
{
    return (MACoordinateRegion) {
        [self CLLocationCoordinate2D:json],
        [self MACoordinateSpan:json]
    };
}

RCT_ENUM_CONVERTER(MAMapType, (@{
                                 @"standard": @(MAMapTypeStandard),
                                 @"satellite": @(MAMapTypeSatellite),
                                 }), MAMapTypeStandard, integerValue)

+ (RCTAMapAnnotation *)RCTAMapAnnotation:(id)json
{
    json = [self NSDictionary:json];
    RCTAMapAnnotation *annotation = [RCTAMapAnnotation new];
    annotation.coordinate = [self CLLocationCoordinate2D:json];
    annotation.draggable = [self BOOL:json[@"draggable"]];
    annotation.title = [self NSString:json[@"title"]];
    annotation.subtitle = [self NSString:json[@"subtitle"]];
    annotation.identifier = [self NSString:json[@"id"]];
    annotation.hasLeftCallout = [self BOOL:json[@"hasLeftCallout"]];
    annotation.hasRightCallout = [self BOOL:json[@"hasRightCallout"]];
    annotation.animateDrop = [self BOOL:json[@"animateDrop"]];
    annotation.tintColor = [self NSUInteger:json[@"tintColor"]];
    annotation.image = [self UIImage:json[@"image"]];
    annotation.viewIndex = [self NSInteger:json[@"viewIndex"] ? :@(NSNotFound)];
    annotation.leftCalloutViewIndex =
    [self NSInteger:json[@"leftCalloutViewIndex"] ?: @(NSNotFound)];
    annotation.rightCalloutViewIndex =
    [self NSInteger:json[@"rightCalloutViewIndex"] ?: @(NSNotFound)];
    annotation.detailCalloutViewIndex =
    [self NSInteger:json[@"detailCalloutViewIndex"] ?: @(NSNotFound)];
    return annotation;
}

RCT_ARRAY_CONVERTER(RCTAMapAnnotation)

+ (RCTAMapOverlay *)RCTAMapOverlay:(id)json
{
    json = [self NSDictionary:json];
    
    NSArray<NSDictionary *> *locations = [self NSDictionaryArray:json[@"coordinates"]];
    CLLocationCoordinate2D coordinates[locations.count];
    NSUInteger index = 0;
    for (NSDictionary *location in locations) {
        coordinates[index++] = [self CLLocationCoordinate2D:location];
    }
    
    RCTAMapOverlay *overlay = [RCTAMapOverlay polylineWithCoordinates:coordinates
                                                              count:locations.count];
    
    overlay.strokeColor = [self UIColor:json[@"strokeColor"]];
    overlay.identifier = [self NSString:json[@"id"]];
    overlay.lineWidth = [self CGFloat:json[@"lineWidth"] ?: @1];
    return overlay;

}

RCT_ARRAY_CONVERTER(RCTAMapOverlay)

@end
