//
//  LocationFinder.h
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>

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
    
    int locationX, locationY;
    bool isTracking;
    bool isAnalysing;
    
    size_t bytesPerRow;
    int bytesPerPixel;
    int boundary;
    
    id _delegate;
    CGSize size;
}

@property (assign) IBOutlet id delegate;
@property (assign) IBOutlet QTCaptureView *normalView;
@property (assign) IBOutlet NSImageCell *analysisView;

-(void)startLocating;
-(void)stopLocating;
-(void)toggleTracking;

-(id)init;
-(id)initWithDelegate:(id)delegate;
@end
