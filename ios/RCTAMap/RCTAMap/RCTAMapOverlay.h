//
//  RCTAMapOverlay.h
//  RCTAMap
//
//  Created by yiyang on 16/2/29.
//  Copyright © 2016年 creditease. All rights reserved.
//

#import <MAMapKit/MAMapKit.h>

@interface RCTAMapOverlay : MAPolyline<MAAnnotation>

@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, strong) UIColor *strokeColor;
@property (nonatomic, assign) CGFloat lineWidth;

@end
