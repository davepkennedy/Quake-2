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

@synthesize window=_window;

/*
static CVReturn MyDisplayLinkCallback(CVDisplayLinkRef displayLink,
                                      const CVTimeStamp* now,           // Current time
                                      const CVTimeStamp* outputTime,    // Displayed at time
                                      CVOptionFlags flagsIn,            // unused
                                      CVOptionFlags* flagsOut,          // unused
                                      void* displayLinkContext)         // Context object
{
    QuakeDelegate* delegate = (__bridge QuakeDelegate*)displayLinkContext;
    [delegate frame];
    return kCVReturnSuccess;
}

static int oldtime;
- (void) frame {
    int time, newtime;
    
    static dispatch_once_t onceToken;
    
    if (self.window == NULL) {
        return;
    }
    
    dispatch_once(&onceToken, ^{
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

    });
    
    do
    {
        newtime = Sys_Milliseconds ();
        time = newtime - oldtime;
    } while (time < 1);
    dispatch_async(dispatch_get_main_queue(), ^{
        Qcommon_Frame (time);
    });
    
    oldtime = newtime;
}
*/

static CVDisplayLinkRef displayLink;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    /**/
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
     /**/
    
    /**
    CVDisplayLinkCreateWithActiveCGDisplays(&displayLink);
    CVDisplayLinkSetOutputCallback(displayLink, &MyDisplayLinkCallback, (__bridge void * _Nullable)(self));
    CVDisplayLinkStart(displayLink);
     /**/
    
    __block double oldtime = Sys_Milliseconds();
    [NSTimer scheduledTimerWithTimeInterval:1.0/30.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        double newtime, delta;
        do
        {
            newtime = Sys_Milliseconds ();
            delta = newtime - oldtime;
        } while (delta < 1);
        dispatch_async(dispatch_get_main_queue(), ^{
            [self sendKeyStates];
            Qcommon_Frame (delta);
        });
        
        oldtime = newtime;

    }];
    
    NSLog(@"Launch Complete");
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
    
}

- (void) keyDown:(short) keyCode {
    
}

- (void) keyUp:(short) keyCode {
    
}


- (void) handleKey:(short) keyCode isDown:(BOOL) down {
    keyStates[keyCode] = down;
    Key_Event (keyCode, down, 0);
}

- (void) sendKeyStates {
    double time = Sys_Milliseconds();
    for (int i = 0; i < 255; i++) {
        if (keyStates[i]) {
            // Key_Event (i, false, time);
            // Key_Event (i, true, time);
        }
    }
}

- (void) applicationDidResignActive:(NSNotification *)notification {
    IN_DeactivateMouse ();
}

- (void) applicationDidBecomeActive:(NSNotification *)notification {
    IN_ActivateMouse ();
}


@end
