//
//  CoordinateCalc.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 12.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FileWriter.h"

@interface CoordinateCalc : NSObject {
    double x, y, z;
    int imageWidth, imageHeight;
    FileWriter * fileWriter;
}

@property (assign) int imageWidth;
@property (assign) int imageHeight;

-(void)setX:(int)x y:(int)y clientX:(int)cx clientY:(int)cy;

@end
