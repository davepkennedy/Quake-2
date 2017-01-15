 //
//  AppDelegate.h
//  Quake2
//
//  Created by Dave Kennedy on 27/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QuakeDelegate : NSObject <NSApplicationDelegate>  {
    CVDisplayLinkRef displayLink;
}

- (void) handleKey:(short) key isDown:(BOOL) down;

@end

