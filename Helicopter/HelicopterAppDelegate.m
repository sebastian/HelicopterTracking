//
//  HelicopterAppDelegate.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "HelicopterAppDelegate.h"

@implementation HelicopterAppDelegate

@synthesize window;
@synthesize analysisView, captureView, position;

- (void)dealloc
{
    [captureView release];
    [analysisView release];
    [locationFinder release];
    [bonjourClient release];
    [bonjourServer release];
        
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        locationFinder = [[LocationFinder alloc] initWithDelegate:self];

        helicopterClient = [[HelicopterClient alloc] init];
        helicopterServer = [[HelicopterServer alloc] init];
        [helicopterServer setHelicopterDelegate:self];
        
        clientX = 0;
        clientY = 0;
        selfX = 0;
        selfY = 0;
    }
    return self;	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [locationFinder setAnalysisView:analysisView];
    [locationFinder setNormalView:captureView];
}

-(IBAction)toggleTracking:(id)sender {
    [locationFinder toggleTracking];
}

-(void)newLocationWithX:(int)x andY:(int)y {
    NSString * selfPosition;
    [helicopterClient sendCoordinateX:x andY:y];
    if (x < 0 && y < 0) {
        selfPosition = @"Position unknown";        
    } else {
        selfX = x; selfY = y;
        selfPosition = [NSString stringWithFormat:@"At position x: %i, y: %i", x, y];
    }
    NSString * mergedPosition = [NSString stringWithFormat:@"%@. Client position, x: %i, y: %i", selfPosition, clientX, clientY];
    [position setTitleWithMnemonic:mergedPosition];
}

-(void)becomeServer:(id)sender {
    [helicopterServer startServer];
}

//////////////////////////////////////////////////////////////////////
// HelicopterServerDelegate
- (void)clientUpdatesX:(int)x andY:(int)y {
    clientX = x;
    clientY = y;
}

@end
