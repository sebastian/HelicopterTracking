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

@interface HelicopterAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;

    // Shows live video feed
    QTCaptureView *captureView;
    
    // Shows result of analysis
    NSImageCell *analysisView;
    
    LocationFinder *locationFinder;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet QTCaptureView *captureView;
@property (assign) IBOutlet NSImageCell *analysisView;

-(IBAction)toggleTracking:(id)sender;

@end
