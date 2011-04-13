#import "HelicopterServer.h"

@implementation HelicopterServer

@synthesize helicopterDelegate;

#pragma mark -
#pragma mark Initialzation & Server startup

- (id) init {
  self = [super init];
  if (self) {
    running = NO;
    [self setType:@"_helicopter._tcp."];
  }
  return self;	
}

- (void)setupInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream {
  [istream retain];
  [ostream retain];
  [istream setDelegate:self];
  [ostream setDelegate:self];
  [istream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [ostream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  CFDictionarySetValue(connections, istream, ostream);
  [istream open];
  [ostream open];
  NSLog(@"Added connection.");
}

- (void)shutdownInputStream:(NSInputStream *)istream outputStream:(NSOutputStream *)ostream {
  [istream close];
  [ostream close];
  [istream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [ostream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
  [istream setDelegate:nil];
  [ostream setDelegate:nil];
  CFDictionaryRemoveValue(connections, istream);
  [istream release];
  [ostream release];
  NSLog(@"Connection closed.");
}

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr {
  if (!connections) {
    connections = CFDictionaryCreateMutable(NULL, 0, NULL, NULL);
  }
  [self setupInputStream:istr outputStream:ostr];
}

- (void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)streamEvent {
  NSInputStream * istream;
  NSOutputStream * ostream;
  switch(streamEvent) {
    case NSStreamEventHasBytesAvailable:;
      istream = (NSInputStream *)aStream;
      ostream = (NSOutputStream *)CFDictionaryGetValue(connections, istream);
      
      uint8_t buffer[2048];
      NSInteger actuallyRead = [istream read:(uint8_t *)buffer maxLength:2048];
      if (actuallyRead > 0) {
        
        NSString * content = [[NSString alloc] initWithBytes:buffer 
                                                      length:actuallyRead 
                                                    encoding:NSUTF8StringEncoding];
        NSArray * components = [content componentsSeparatedByString:@","];
        int x = [[components objectAtIndex:0] intValue];
        int y = [[components objectAtIndex:1] intValue];
        [content release];
        [helicopterDelegate clientUpdatesX:x andY:y];
      }
      break;
    case NSStreamEventEndEncountered:;
      istream = (NSInputStream *)aStream;
      ostream = nil;
      if (CFDictionaryGetValueIfPresent(connections, istream, (const void **)&ostream)) {
        [self shutdownInputStream:istream outputStream:ostream];
      }
      break;
    case NSStreamEventHasSpaceAvailable:
    case NSStreamEventErrorOccurred:
    case NSStreamEventOpenCompleted:
    case NSStreamEventNone:
    default:
      break;
  }
}

- (void)startServer {
  [NSThread detachNewThreadSelector:@selector(runServerInBackground:) 
                           toTarget:self 
                         withObject:nil];
}
- (void)runServerInBackground:(id)_ignore {
  NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
  NSRunLoop * rl = [NSRunLoop currentRunLoop];
  NSError * startError = nil;
  if (![self start:&startError] ) {
    NSLog(@"Error starting server: %@", startError);
  } else {
    NSLog(@"Starting server on port %d", [self port]);
  }
  [rl run];
  [pool release];
}

@end
