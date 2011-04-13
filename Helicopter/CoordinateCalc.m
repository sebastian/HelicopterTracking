//
//  CoordinatCalc.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 12.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "CoordinateCalc.h"
#define A 3

@implementation CoordinateCalc
@synthesize imageWidth, imageHeight;

-(id)init {
    self = [super init];
    if (self) {
        fileWriter = [[FileWriter alloc] init];
    }
    return self;
}

-(void)dealloc {
    [fileWriter release];
}

// Normalizes it between -50 to 50
-(double)normalizeX:(int)_x {
    double value = (double) _x / imageWidth;
    return ((int) value * 100) - 50;
}
// Normalizes it to between -37.5 and +37.5
-(double)normalizeY:(int)_y {
    double value = (double) _y / imageHeight;
    return ((int) value * 70) - 37.5;
}

-(void)setX:(int)_x y:(int)_y clientX:(int)cx clientY:(int)cy {
    double nsX, nsY, ncY, ncX;
    nsX = [self normalizeX:_x];
    nsY = [self normalizeY:_y];
    ncX = [self normalizeX:cx];
    ncY = [self normalizeY:cy];
    
    x = (1 / ((tan(45 - 0.564 * nsX) / tan(45 + 0.564 * ncX)) + 1)) * A;
    y = tan(45 - 0.564 * nsX) * x;
    z = tan(0.564 * nsY)*(sqrt(x*x + y*y));
    
    [fileWriter writeX:(int)x andY:(int)y andZ:(int)z];
}

@end
