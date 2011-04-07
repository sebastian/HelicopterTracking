//
//  LocationFinder.m
//  Helicopter
//
//  Created by Sebastian Probst Eide on 07.04.11.
//  Copyright 2011 Kle.io. All rights reserved.
//

#import "LocationFinder.h"


@implementation LocationFinder

@synthesize normalView, analysisView;
@synthesize delegate;

- (id) init {
    NSLog(@"in init");
    self = [super init];
    if (self) {
        isTracking = NO;
        isAnalysing = NO;
        
        bytesPerPixel = 4;
        
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
        _delegate = theDelegate;
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
    }
    
    NSLog(@"is starting tracking");
    isAnalysing = YES;
    
    // Start the session
    [mCaptureSession startRunning];
    
    [NSThread detachNewThreadSelector:@selector(analysisRunner:) toTarget:self withObject:nil];
}

-(void)stopLocating {
    isAnalysing = NO;
    NSLog(@"is stopping tracking");
    [mCaptureSession stopRunning];
}

-(void)toggleTracking {
    NSLog(@"called toggle tracking");
    if (isAnalysing) {
        [self stopLocating];
    } else {
        [self startLocating];
    }
}

-(int)minLocation:(int)a {
    if ((a - boundary) < 0) {
        return 0;
    }
    return a - boundary;
}

-(int)maxLocation:(int)a forMax:(int)b {
    if ((a + boundary) >= b) {
        return b - 1;
    }
    return a + boundary;
}

-(BOOL)isActivePointInData:(u_int8_t*)data atX:(int)x andY:(int)y {
    uint8 activeThreshold = 254 * 0.40;
    int valid_points = 0;
    int red, blue, green, magic;
    size_t index;
    for (int xd = [self minLocation:x]; xd < [self maxLocation:x forMax:size.width]; xd++){
        for (int yd = [self minLocation:y]; yd < [self maxLocation:y forMax:size.height]; yd++){
            index = bytesPerRow * yd + bytesPerPixel * xd;
            red = data[index];
            green = data[index+1];
            blue = data[index+2];
            magic = data[index+3];
            if (x == 10 & y == 10) { 
                NSLog(@"rgb? : %i %i %i %i", red, green, blue, magic);
                return YES;
            }
            if (red > activeThreshold && blue > activeThreshold && green > activeThreshold && magic > activeThreshold) {
                valid_points++;
            }
        }
    }
    return valid_points > (boundary * boundary) * 0.8;
}

-(void)setHighlight:(BOOL)highlight
             inData:(uint8_t*)data 
          forPixelX:(int)x 
               andY:(int)y 
{
    uint8 white = 254, black = 0;
    for (int xx = [self minLocation:x]; xx < [self maxLocation:x forMax:size.width]; xx++) {
        for (int yy = [self minLocation:y]; yy < [self maxLocation:y forMax:size.height]; yy++) {
            size_t index = bytesPerRow * yy + bytesPerPixel * xx;
            if (NO) {
                data[index] = white;
                data[index + 1] = white;
                data[index + 2] = white;
                data[index + 3] = white;
            } else {
                data[index] = black; // GREEN?
                data[index + 1] = black; // B
                data[index + 2] = black; // G
                data[index + 3] = black; // R
            }
            
        }
    }
}

-(void)relocateObjectIn:(uint8_t*)imageData 
      withReferenceData:(uint8_t*)reference
{
    NSLog(@"relocating");
    // This is just for visual joy... Mark all areas as not found
    for (int x = 0; x < size.width; x++) {
        for (int y = 0; y < size.height; y++) {
            [self setHighlight:NO inData:imageData forPixelX:x andY:y];
        }
    }
    BOOL hasFoundDot = NO;
    // Iterate over a region to find helicopter
    for (int x = [self minLocation:locationX]; x < [self maxLocation:locationX forMax:size.width]; x++) {
        for (int y = [self minLocation:locationY]; y < [self maxLocation:locationY forMax:size.height]; y++) {
            BOOL isActive = [self isActivePointInData:reference atX:x andY:y];
            if (isActive) {
                hasFoundDot = YES;
                locationX = x;
                locationY = y;
            }
            [self setHighlight:isActive inData:imageData forPixelX:x andY:y];
        }
    }
    isTracking = hasFoundDot;
}

-(void)locateObjectIn:(uint8_t*)imageData 
    withReferenceData:(uint8_t*)reference
{
    NSLog(@"locating");
    // Iterate over it to find helicopter
    for (int x = boundary; x < size.width - boundary; x++) {
        for (int y = boundary; y < size.height - boundary; y++) {
            BOOL isActive = [self isActivePointInData:reference atX:x andY:y];
            if (isActive) {
                isTracking = YES;
                locationX = x;
                locationY = y;
            }
            [self setHighlight: isActive inData:imageData forPixelX:x andY:y];
        }
    }
}

-(void)analysePicture {
    CVImageBufferRef imageBuffer;
    @synchronized (self) {
        imageBuffer = CVBufferRetain(mCurrentImageBuffer);
    }
    
    if (imageBuffer) {
        bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        
        size = CVImageBufferGetDisplaySize(imageBuffer);
                
        // Get the raw image data
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        uint8_t *imageData = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
        CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

        // Make a copy used for reference that we don't change
        int copyAmount = bytesPerRow * size.height;
        uint8_t *referenceData = malloc(copyAmount);
        memcpy(referenceData, imageData, copyAmount);
        
        //if (isTracking) {
        if (NO) {
            [self relocateObjectIn:imageData withReferenceData:referenceData];
        } else {
            [self locateObjectIn:imageData withReferenceData:referenceData];
        }
        free(referenceData);
        
        // Create an NSImage and add it to the movie
        NSCIImageRep *imageRep = [NSCIImageRep imageRepWithCIImage:[CIImage imageWithCVImageBuffer:imageBuffer]];
        NSImage *image = [[NSImage alloc] initWithSize:[imageRep size]];
        [image addRepresentation:imageRep];
        
        
        CVBufferRelease(imageBuffer);
        [analysisView setImage:image];
        [image release];
    }    
}

- (void) analysisRunner:(id)_ignore {
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    while (YES) {
        if (!isAnalysing) {
            break;
        }
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
    CVImageBufferRef imageBufferToRelease;
    CVBufferRetain(videoFrame);
    @synchronized (self) {
        imageBufferToRelease = mCurrentImageBuffer;
        mCurrentImageBuffer = videoFrame;
    }
    CVBufferRelease(imageBufferToRelease);
}

@end
