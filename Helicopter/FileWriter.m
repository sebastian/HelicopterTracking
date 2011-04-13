//
//  FileWriter.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 12.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "FileWriter.h"


@implementation FileWriter


-(void)writeX:(int)x andY:(int)y {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    [[NSString stringWithFormat:@"%i %i", x, y] writeToFile:@"~/Desktop/helilocation.dat" atomically:YES];    
    [pool drain];
}
@end
