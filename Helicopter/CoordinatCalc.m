//
//  CoordinatCalc.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 12.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "CoordinatCalc.h"
#define A 3

@implementation CoordinatCalc
@synthesize imageWidth, imageHeight;

// Normalizes it between -50 to 50
-(int)normalizeX:(int)x {
    double value = (double) x / imageWidth;
    return ((int) value * 100) - 50;
}
// Normalizes it to between -37.5 and +37.5
-(int)normalizeY:(int)y {
    double value = (double) y / imageHeight;
    return ((int) value * 70) - 37.5;
}

-(void)setX:(int)x y:(int)y clientX:(int)cx clientY:(int)cy {
    int nsX, nsY, ncY, ncX;
    nsX = [self normalizeX:x];
    nsY = [self normalizeY:y];
    ncX = [self normalizeX:cx];
    ncY = [self normalizeY:cy];
}

@end
