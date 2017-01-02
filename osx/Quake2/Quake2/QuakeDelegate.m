//
//  AppDelegate.m
//  Quake2
//
//  Created by Dave Kennedy on 27/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#include "../../../qcommon/qcommon.h"
#import "QuakeDelegate.h"

@interface QuakeDelegate ()

@property (weak) IBOutlet NSWindow *window;

@end

@implementation QuakeDelegate

// static CVDisplayLinkRef displayLink;

- (void) setWindow:(NSWindow *)window {
    _window = window;
}

- (NSWindow*) window {
    return _window;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
}

- (void) initializeGame {
    NSArray<NSString*> *arguments = [[NSProcessInfo processInfo] arguments];
    int argc = arguments.count;
    char** argv = (char**)calloc(argc, sizeof(char*));
    for (int i = 0; i < argc; i++) {
        argv[i] = strdup ([arguments objectAtIndex:i].UTF8String);
    }
    Qcommon_Init (argc, argv);
    
    
    for (int i = 0; i < argc; i++) {
        free (argv[i]);
    }
    free (argv);
}

- (void) runDisplay {
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    __block double oldTime = Sys_Milliseconds();
    CVDisplayLinkSetOutputHandler(displayLink, ^CVReturn(CVDisplayLinkRef  _Nonnull displayLink,
                                                         const CVTimeStamp * _Nonnull inNow,
                                                         const CVTimeStamp * _Nonnull inOutputTime,
                                                         CVOptionFlags flagsIn,
                                                         CVOptionFlags * _Nonnull flagsOut) {
        double newTime = Sys_Milliseconds();
        double delta = newTime - oldTime;
        if (delta > 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                Qcommon_Frame((int)delta);
            });
            oldTime = newTime;
        }
        return kCVReturnSuccess;
    });
    CVDisplayLinkStart(displayLink);
}

- (void) awakeFromNib {
    NSLog (@"Window: %@", self.window);
    [self initializeGame];
    [self runDisplay];
}

- (void) handleKey:(short) key isDown:(BOOL) down {
    Key_Event (key, down, 0);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}
- (void) applicationDidResignActive:(NSNotification *)notification {
    IN_DeactivateMouse ();
}

- (void) applicationDidBecomeActive:(NSNotification *)notification {
    
    IN_ActivateMouse ();
}


@end
