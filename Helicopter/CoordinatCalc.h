//
//  CoordinatCalc.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 12.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CoordinatCalc : NSObject {
    int aX, aY, aZ;
    int bX, bY, bZ;
    
    int imageWidth, imageHeight;
}

@property (assign) int imageWidth;
@property (assign) int imageHeight;

-(void)setX:(int)x y:(int)y clientX:(int)cx clientY:(int)cy;

@end
