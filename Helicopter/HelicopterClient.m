#import "HelicopterClient.h"

@implementation HelicopterClient
@synthesize service, clientDelegate;

- (id) init {
  self = [super init];
  if (self) {
    serviceBrowser = [[NSNetServiceBrowser alloc] init];
    [serviceBrowser setDelegate:self];
    [self setService:nil];
    isLooking = YES;
    [serviceBrowser searchForServicesOfType:@"_helicopter._tcp." inDomain:@""];
  }
  return self;	
}

- (void)connectToService:(NSNetService*)newService {
  // Tell the client to disable the server button
  [clientDelegate clientFoundServer];
  
  [self setService:newService];
  if (inputStream && outputStream) {
    [self closeStreams];
  }
  
  if ([[self service] getInputStream:&inputStream outputStream:&outputStream]) {
    [self openStreams];
  }
}

#pragma mark -
#pragma mark NSNetServiceBrowser delegate methods

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
  NSLog(@"Service became available");
  [self connectToService:aNetService];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing {
  NSLog(@"Service became unavailable...");
  [self closeStreams];
}

#pragma mark -
#pragma mark Stream methods

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
  NSInputStream * istream;
  switch(streamEvent) {
    case NSStreamEventHasBytesAvailable:;
      uint8_t oneByte;
      NSInteger actuallyRead = 0;
      istream = (NSInputStream *)aStream;
      if (!dataBuffer) {
        dataBuffer = [[NSMutableData alloc] initWithCapacity:2048];
      }
      actuallyRead = [istream read:&oneByte maxLength:1];
      if (actuallyRead == 1) {
        [dataBuffer appendBytes:&oneByte length:1];
      }
      if (oneByte == '\n') {
        // We've got the carriage return at the end of the echo. Let's set the string.
        NSString * string = [[NSString alloc] initWithData:dataBuffer encoding:NSUTF8StringEncoding];
        NSLog(@"Client got: %@", string);
        [string release];
        [dataBuffer release];
        dataBuffer = nil;
      }
      break;
    case NSStreamEventEndEncountered:;
      [self closeStreams];
      break;
    case NSStreamEventHasSpaceAvailable:
    case NSStreamEventErrorOccurred:
    case NSStreamEventOpenCompleted:
    case NSStreamEventNone:
    default:
      break;
  }
}

- (void)openStreams {
  [inputStream retain];
  [outputStream retain];
  [inputStream setDelegate:self];
  [outputStream setDelegate:self];
  [inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [inputStream open];
  [outputStream open];
}

- (void)closeStreams {
  [inputStream close];
  [outputStream close];
  [inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [inputStream setDelegate:nil];
  [outputStream setDelegate:nil];
  [inputStream release];
  [outputStream release];
  inputStream = nil;
  outputStream = nil;
}

- (void)sendCoordinateX:(int)x andY:(int)y
{   
  // Ignore the data if we are not currently actively looking for a host,
  // or we haven't yet found one.
  if (!isLooking || ![self service]) {return;}
  
  // Send data to server as "x,y"
  NSString * stringToSend = [NSString stringWithFormat:@"%i,%i", x, y];
  NSData * dataToSend = [stringToSend dataUsingEncoding:NSUTF8StringEncoding];
  
  if (outputStream) {
    NSInteger remainingToWrite = [dataToSend length];
    void * marker = (void *)[dataToSend bytes];
    while (0 < remainingToWrite) {
      NSInteger actuallyWritten = 0;
      actuallyWritten = [outputStream write:marker maxLength:remainingToWrite];
      remainingToWrite -= actuallyWritten;
      marker += actuallyWritten;
    }
  } else {
    NSLog(@"No output stream to write data to");
  }
}

-(void) stopLooking {
  NSLog(@"Stopping to look");
  isLooking = NO;
  [serviceBrowser stop];
}

@end
