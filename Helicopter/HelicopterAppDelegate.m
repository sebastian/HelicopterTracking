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
@synthesize analysisView, captureView;

- (void)dealloc
{
    [captureView release];
    [analysisView release];
    [locationFinder release];
        
    [super dealloc];
}

- (id) init {
    self = [super init];
    if (self) {
        locationFinder = [[LocationFinder alloc] initWithDelegate:self];
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



@end
