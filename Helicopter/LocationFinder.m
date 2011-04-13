//
//  LocationFinder.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "LocationFinder.h"

#define MIN_NUMBER_OF_POINTS 50

@implementation LocationFinder

enum pixelComponents { alpha, red, green, blue };

@synthesize normalView, analysisView;
@synthesize delegate;

- (id) init {
    NSLog(@"in init");
    self = [super init];
    if (self) {
        isTracking = NO;
        isAnalysing = NO;
        
        bytesPerPixelInInput = 2;
        bytesPerPixelInOutput = 4;
        
        // The boundary determines how many pixels
        // are used to check for a dot at each side of
        // a pixel.
        boundary = 1;
    }
    return self;	
}

- (id) initWithDelegate:(id)theDelegate {
    self = [self init];
    if (self) {
        delegate = theDelegate;
    }
    return self;	
}

- (void)dealloc
{
    [mCaptureSession release];
    [mCaptureDeviceInput release];
    [mCaptureOutput release];

    [normalView release];
    [analysisView release];
    
    [super dealloc];
}

-(void)startLocating {
    NSError *error = nil;
    if (!mCaptureSession) {
        // Set up a capture session that outputs raw frames
        BOOL success;
        
        mCaptureSession = [[QTCaptureSession alloc] init];
        
        // Find a video device
        QTCaptureDevice *device = [QTCaptureDevice defaultInputDeviceWithMediaType:QTMediaTypeVideo];
        success = [device open:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
        
        // Add a device input for that device to the capture session
        mCaptureDeviceInput = [[QTCaptureDeviceInput alloc] initWithDevice:device];
        success = [mCaptureSession addInput:mCaptureDeviceInput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
        
        // Add a decompressed video output that returns raw frames to the session
        mCaptureOutput = [[QTCaptureVideoPreviewOutput alloc] init];
        [mCaptureOutput setDelegate:self];
        success = [mCaptureSession addOutput:mCaptureOutput error:&error];
        if (!success) {
            [[NSAlert alertWithError:error] runModal];
            return;
        }
        
        // Preview the video from the session in the document
        [normalView setCaptureSession:mCaptureSession];
        
        // Start the session
        [mCaptureSession startRunning];
    }
    
    NSLog(@"is starting tracking");
    isAnalysing = YES;
    
    [NSThread detachNewThreadSelector:@selector(analysisRunner:) toTarget:self withObject:nil];
}

-(void)stopLocating {
    isAnalysing = NO;
    NSLog(@"is stopping tracking");
}

-(void)toggleTracking {
    NSLog(@"called toggle tracking");
    if (isAnalysing) {
        [self stopLocating];
    } else {
        [self startLocating];
    }
}

- (BOOL) differentAtX:(int)x 
                 andY:(int)y 
              between:(unsigned char *)image1 
                  and:(unsigned char *)image2 
{
    int a1, a2, b1, b2, c1, c2, d1, d2, a, b, c, d;
    size_t index = bytesPerRow * y + bytesPerPixelInInput * x;
    a1 = image1[index]; a2 = image2[index];
    b1 = image1[index + 1]; b2 = image2[index + 1];
    c1 = image1[index + 2]; c2 = image2[index + 2];
    d1 = image1[index + 3]; d2 = image2[index + 3];
    a = abs(a1 - a2);
    b = abs(b1 - b2);
    c = abs(c1 - c2);
    d = abs(d1 - d2);
    
    unsigned char threshold = 20;
    uint8 over_threshold = 0; 
    if (a > threshold) {over_threshold++;}
    if (b > threshold) {over_threshold++;}
    if (c > threshold) {over_threshold++;}
    if (d > threshold) {over_threshold++;}
    return over_threshold >= 2;
}

-(void)highlight:(BOOL)highlight withAlternateColor:(BOOL)altColor
        pixelAtX:(int)x 
            andY:(int)y 
           inPad:(unsigned char *)pad
{
    if (x < 0 || y < 0) {return;}
    
    size_t index = bytesPerRow * 2 * y + bytesPerPixelInOutput * x;
    unsigned char on = 0, off = 255;
    if (highlight) {
        pad[index + red] = on;
        pad[index + green] = on;
        pad[index + blue] = on;
        pad[index + alpha] = 255;
        if (altColor) {
            pad[index + red] = off;
        }
    } else {
        pad[index + alpha] = 0;
        pad[index + red] = off;
        pad[index + green] = off;
        pad[index + blue] = off;
    }
}
-(void)highlight:(BOOL)highlight pixelAtX:(int)x andY:(int)y inPad:(unsigned char *)pad {
    [self highlight:highlight withAlternateColor:NO pixelAtX:x andY:y inPad:pad];
}

-(void)fillCurrentRegionInScratchPad:(unsigned char*)pad
{
    if (locationX >= 0 && locationY >= 0) {
        int minX, minY, maxX, maxY;
        minX = locationX > 10 ? locationX - 10 : locationX;
        maxX = locationX + 10 > size.width ? size.width : locationX + 10;
        minY = locationY > 10 ? locationY - 10 : locationY;
        maxY = locationY + 10 > size.height ? size.height : locationY + 10;
        for (int x = minX; x < maxX; x++) { for (int y = minY; y < maxY; y++) {
            [self highlight:YES pixelAtX:x andY:y inPad:pad];  
        }}
    }
}

-(void)findDifferenceIn:(unsigned char *)image1 
                   from:(unsigned char *)image2 
         withScratchpad:(unsigned char *)scratchpad
{
    long sumX = 0, sumY = 0, countPoints = 1;
    
    // Set the tracking bounds conditionally on if we are currently
    // tracking an object or not. This in order to speed things up.
    int minX, maxX, minY, maxY;
    if (isTracking) {
        int tracking_area = size.height * 0.3;
        minX = locationX - tracking_area < 0 ? 0 : locationX - tracking_area;
        maxX = locationX + tracking_area >= size.width ? size.width - 1 : locationX + tracking_area;
        minY = locationY - tracking_area < 0 ? 0 : locationY - tracking_area;
        maxY = locationY + tracking_area >= size.height ? size.height - 1 : locationY + tracking_area;
    } else {
        minX = 0; maxX = size.width - 1;
        minY = 0; maxY = size.height - 1;
    }
    
    // Iterate over it to find helicopter
    for (int x = minX; x < maxX; x++) {
        for (int y = minY; y < maxY; y++) {
            BOOL isDifferent = [self differentAtX:x andY:y between:image1 and:image2];
            if (isDifferent) {
                sumX += x, sumY += y;
                countPoints++;
            }
            [self highlight:isDifferent withAlternateColor:YES pixelAtX:x andY:y inPad:scratchpad];
        }
    }
    if (countPoints > MIN_NUMBER_OF_POINTS) {
        isTracking = YES;
        locationX = (int) (sumX / countPoints);
        locationY = (int) (sumY / countPoints);
        [self fillCurrentRegionInScratchPad:scratchpad];
    } else {
        isTracking = NO;
        locationX = -1; locationY = -1;
    }
    [delegate newLocationWithX:locationX andY:locationY];
}

-(void)analysePicture {
    CVImageBufferRef currentImageBuffer, previousImageBuffer;
    @synchronized (self) {
        currentImageBuffer = CVBufferRetain(mCurrentImageBuffer);
        previousImageBuffer = CVBufferRetain(mPreviousImageBuffer);
    }
    
    if (currentImageBuffer && previousImageBuffer) {
        // Setup
        bytesPerRow = CVPixelBufferGetBytesPerRow(currentImageBuffer);
        size = CVImageBufferGetDisplaySize(currentImageBuffer);
        
        unsigned char * currentImageData, * previousImageData, * padData;
        
        // Get the raw image data
        CVPixelBufferLockBaseAddress(currentImageBuffer, 0);
        currentImageData = (unsigned char *)CVPixelBufferGetBaseAddress(currentImageBuffer);
        CVPixelBufferUnlockBaseAddress(currentImageBuffer, 0);
        
        CVPixelBufferLockBaseAddress(previousImageBuffer, 0);
        previousImageData = (unsigned char *)CVPixelBufferGetBaseAddress(previousImageBuffer);
        CVPixelBufferUnlockBaseAddress(previousImageBuffer, 0);        
                
        CVPixelBufferRef output;
        CVPixelBufferCreate (NULL, size.width, size.height, k32ARGBPixelFormat, NULL, &output);
        CVPixelBufferLockBaseAddress(output, 0);
        padData = (unsigned char *)CVPixelBufferGetBaseAddress(output);
        CVPixelBufferUnlockBaseAddress(output, 0);        
                
        [self findDifferenceIn:currentImageData from:previousImageData withScratchpad:padData];
    
        NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[[CIImage alloc] initWithCVImageBuffer:output]];
        NSImage *image = [[NSImage alloc] initWithSize:[imageRep size]];
        [image addRepresentation:imageRep];
        
        CVBufferRelease(currentImageBuffer);
        CVBufferRelease(previousImageBuffer);
        CVBufferRelease(output);
        [analysisView setImage:image];
    }    
}

- (void) analysisRunner:(id)_ignore {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    while (isAnalysing) {
        [self analysePicture];
        // sleep(1);
    }
    [pool release];
}

- (void)captureOutput:(QTCaptureOutput *)captureOutput 
  didOutputVideoFrame:(CVImageBufferRef)videoFrame 
     withSampleBuffer:(QTSampleBuffer *)sampleBuffer 
       fromConnection:(QTCaptureConnection *)connection
{
    // We keep two image buffers so that we can compare for changes
    CVImageBufferRef imageBufferToRelease;
    CVBufferRetain(videoFrame);
    @synchronized (self) {
        imageBufferToRelease = mPreviousImageBuffer;
        mPreviousImageBuffer = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    CVBufferRelease(imageBufferToRelease);
}

@end
