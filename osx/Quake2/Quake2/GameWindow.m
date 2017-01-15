//
//  GameWindow.m
//  Quake2
//
//  Created by Dave Kennedy on 11/01/2017.
//  Copyright © 2017 Dave Kennedy. All rights reserved.
//

#include "../../../client/client.h"
#import "GameWindow.h"

@implementation GameWindow

- (void) centerMouse {
    extern qboolean mouseactive;
    if (mouseactive) {
        NSSize screenSize = self.screen.frame.size;
        NSPoint center = NSMakePoint ((self.frame.origin.x + NSWidth(self.frame) / 2),
                                      screenSize.height - self.frame.origin.y - NSHeight(self.frame) / 2);
    
        CGWarpMouseCursorPosition(center);
    }
    
}

@end
