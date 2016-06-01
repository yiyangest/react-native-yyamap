//
//  RCTAMapAnnotation.h
//  RCTAMap
//
//  Created by yiyang on 16/2/29.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface RCTAMapAnnotation : MAPointAnnotation <MAAnnotation>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, assign) BOOL hasLeftCallout;
@property (nonatomic, assign) BOOL hasRightCallout;
@property (nonatomic, assign) BOOL animateDrop;
@property (nonatomic, assign) MAPinAnnotationColor tintColor;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger viewIndex;
@property (nonatomic, assign) NSInteger leftCalloutViewIndex;
@property (nonatomic, assign) NSInteger rightCalloutViewIndex;
@property (nonatomic, assign) NSInteger detailCalloutViewIndex;
@property (nonatomic, assign) BOOL draggable;

@end
