#import <Cocoa/Cocoa.h>

@protocol HelicopterClientDelegate
- (void)clientFoundServer;
@end

@interface HelicopterClient : NSObject <NSStreamDelegate, NSNetServiceBrowserDelegate>
{
  NSNetServiceBrowser * serviceBrowser;
  NSNetService * service;
  NSInputStream * inputStream;
  NSOutputStream * outputStream;
  NSMutableData * dataBuffer;
  
  id <HelicopterClientDelegate> clientDelegate;
  
  BOOL isLooking;
}
@property (assign) id <HelicopterClientDelegate> clientDelegate;
@property (retain) NSNetService * service;

- (void)sendCoordinateX:(int)x andY:(int)y;
- (void)stopLooking;
- (void)openStreams;
- (void)closeStreams;

@end
