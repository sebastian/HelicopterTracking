#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TCPServer.h"

@protocol HelicopterServerDelegate
- (void)clientUpdatesX:(int)x andY:(int)y;
@end

@interface HelicopterServer : TCPServer <NSStreamDelegate>
{
    id <HelicopterServerDelegate> helicopterDelegate;
    CFMutableDictionaryRef connections;
    BOOL running;
}

@property (assign) id <HelicopterServerDelegate> helicopterDelegate;

- (void)handleNewConnectionFromAddress:(NSData *)addr inputStream:(NSInputStream *)istr outputStream:(NSOutputStream *)ostr;

//- (void)startServer;
- (void)startServer;
@end
