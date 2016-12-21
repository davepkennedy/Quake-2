 //
//  AppDelegate.h
//  Quake2
//
//  Created by Dave Kennedy on 27/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QuakeDelegate : NSObject <NSApplicationDelegate> {
    char keyStates [255];
    __weak NSWindow* _window;
}

- (void) keyDown:(short) keyCode;
- (void) keyUp:(short) keyCode;

- (void) handleKey:(short) keyCode isDown:(BOOL) down;

@end

