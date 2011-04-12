//
//  LocationFinder.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

@protocol LocationFinderDelegate
@required
-(void)newLocationWithX:(long)x andY:(long)y;
@end

@interface LocationFinder : NSObject {
    // Shows live video feed
    QTCaptureView *normalView;
    
    // Shows result of analysis
    NSImageCell *analysisView;
    
    QTCaptureSession *mCaptureSession;
    QTCaptureDeviceInput *mCaptureDeviceInput;
    QTCaptureVideoPreviewOutput *mCaptureOutput;
    
    // Stores the most recent camera image
    CVImageBufferRef mCurrentImageBuffer;
    CVImageBufferRef mPreviousImageBuffer;
    
    int locationX, locationY;
    bool isTracking;
    bool isAnalysing;
    
    size_t bytesPerRow;
    int bytesPerPixelInInput, bytesPerPixelInOutput;
    int boundary;
    
    id <LocationFinderDelegate> _delegate;
    CGSize size;
}

@property (assign) IBOutlet id <LocationFinderDelegate> delegate;
@property (assign) IBOutlet QTCaptureView *normalView;
@property (assign) IBOutlet NSImageCell *analysisView;

-(void)startLocating;
-(void)stopLocating;
-(void)toggleTracking;

-(id)init;
-(id)initWithDelegate:(id)delegate;
@end
