//
//  HelicopterAppDelegate.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HelicopterAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
