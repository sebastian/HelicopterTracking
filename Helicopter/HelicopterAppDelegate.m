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
@synthesize lblSelfPosition, lblClientPosition, lblStatus, btnStartServer;

- (void)dealloc
{
    [captureView release];
    [analysisView release];
    [locationFinder release];
    [bonjourClient release];
    [bonjourServer release];
        
    [super dealloc];
}

- (void) updateStatus {
    NSString * status;
    if (isTracking) {
        if (isServer) {
            status = @"Is tracking as server";
        } else {
            status = @"Is tracking as client";
        }
    } else {
        if (isServer) {
            status = @"Currently not tracking. In server mode.";
        } else {
            status = @"Currently not tracking. In client mode.";
        }        
    }
    [lblStatus setTitleWithMnemonic:status];
}

- (id) init {
    self = [super init];
    if (self) {
        locationFinder = [[LocationFinder alloc] initWithDelegate:self];

        helicopterClient = [[HelicopterClient alloc] init];
        [helicopterClient setClientDelegate:self];
        helicopterServer = [[HelicopterServer alloc] init];
        [helicopterServer setHelicopterDelegate:self];
        
        clientX = 0;
        clientY = 0;
        selfX = 0;
        selfY = 0;
        
        isServer = NO;
        isTracking = NO;
    }
    return self;	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [locationFinder setAnalysisView:analysisView];
    [locationFinder setNormalView:captureView];
    [self updateStatus];
}

-(IBAction)toggleTracking:(id)sender {
    [locationFinder toggleTracking];
    isTracking = !isTracking;
    [self updateStatus];
}

-(void)newLocationWithX:(int)x andY:(int)y {
    NSString * selfPosition;
    [helicopterClient sendCoordinateX:x andY:y];
    if (x < 0 && y < 0) {
        selfPosition = @"Position unknown";        
    } else {
        selfX = x; selfY = y;
        selfPosition = [NSString stringWithFormat:@"x: %i, y: %i", x, y];
    };
    [lblSelfPosition setTitleWithMnemonic:selfPosition];
}

-(void)becomeServer:(id)sender {
    // If we want to become a server, then we can't also be a client
    [helicopterClient stopLooking];
    // Start the helicopter location server
    [helicopterServer startServer];
    [btnStartServer setEnabled:NO];
    isServer = YES;
    [self updateStatus];
}

//////////////////////////////////////////////////////////////////////
// HelicopterServerDelegate
- (void)clientUpdatesX:(int)x andY:(int)y {
    NSString * clientPosition;
    if (x < 0 && y < 0) {
        clientPosition = @"Position unknown";        
    } else {
        clientX = x; clientY = y;
        clientPosition = [NSString stringWithFormat:@"x: %i, y: %i", x, y];
    };
    [lblClientPosition setTitleWithMnemonic:clientPosition];
}

//////////////////////////////////////////////////////////////////////
// HelicopterClientDelegate
- (void)clientFoundServer {
    [btnStartServer setEnabled:NO];
}

@end
