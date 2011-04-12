//
//  HelicopterAppDelegate.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QTKit/QTKit.h>
#import "LocationFinder.h"
#import "BonjourClient.h"
#import "BonjourServer.h"
#import "HelicopterClient.h"
#import "HelicopterServer.h"

@interface HelicopterAppDelegate : NSObject <NSApplicationDelegate, LocationFinderDelegate, HelicopterServerDelegate> {
@private
    NSWindow *window;
    NSTextField * position;

    // Shows live video feed
    QTCaptureView *captureView;
    
    // Shows result of analysis
    NSImageCell *analysisView;
    
    LocationFinder *locationFinder;
    
    BonjourClient * bonjourClient;
    BonjourServer * bonjourServer;
    HelicopterServer * helicopterServer;
    HelicopterClient * helicopterClient;
    
    int clientX, clientY, selfX, selfY;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet QTCaptureView *captureView;
@property (assign) IBOutlet NSImageCell *analysisView;
@property (assign) IBOutlet NSTextField *position;

-(IBAction)toggleTracking:(id)sender;
-(IBAction)becomeServer:(id)sender;

// HelicopterAppDelegate
-(void)newLocationWithX:(int)x andY:(int)y;

// HelicopterServerDelegate
- (void)clientUpdatesX:(int)x andY:(int)y;
@end
