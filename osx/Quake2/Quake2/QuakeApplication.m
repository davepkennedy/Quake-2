//
//  QuakeApplication.m
//  Quake2
//
//  Created by Dave Kennedy on 27/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#include "../../../client/client.h"
#import "QuakeApplication.h"
#import "QuakeDelegate.h"
#import <Carbon/Carbon.h>
#import "../../../client/keys.h"

typedef struct  {
    short virtual_key;
    short mapped_key;
    short shift_mapped_key;
}keymap_t ;

static keymap_t keymap[] = {
    {kVK_Return, K_ENTER},
    {kVK_Escape, 27},
    
    {kVK_ANSI_1, '1','!'},  {kVK_ANSI_2, '2','@'},  {kVK_ANSI_3, '3'},
    {kVK_ANSI_4, '4','$'},  {kVK_ANSI_5, '5','%'},  {kVK_ANSI_6, '6','^'},
    {kVK_ANSI_7, '7','&'},  {kVK_ANSI_8, '8','*'},  {kVK_ANSI_9, '9','('},
    {kVK_ANSI_0, '0',')'},

    {kVK_Tab, K_TAB},
    {kVK_Space, K_SPACE},
    {kVK_Delete, K_BACKSPACE},
    {kVK_Control, K_CTRL},
    {kVK_ANSI_Equal, '=', '+'},
    {kVK_ANSI_KeypadMinus, '-'},        {kVK_ANSI_KeypadPlus, '+'},
    {kVK_ANSI_LeftBracket, '[','{'},    {kVK_ANSI_RightBracket, ']', '}'},
    {kVK_ANSI_Semicolon, ';',':'},      {kVK_ANSI_Backslash,'\\','|'},
    {kVK_ANSI_Comma, ',','<'},          {kVK_ANSI_Period, '.','>'},
    {kVK_ANSI_Slash,'/','?'},
    {kVK_ANSI_Grave, '`','~'},
    
    {kVK_ANSI_A, 'a','A'},  {kVK_ANSI_B, 'b','B'},  {kVK_ANSI_C, 'c','C'},  {kVK_ANSI_D, 'd','D'},
    {kVK_ANSI_E, 'e','E'},  {kVK_ANSI_F, 'f','F'},  {kVK_ANSI_G, 'g','G'},  {kVK_ANSI_H, 'h','H'},
    {kVK_ANSI_I, 'i','I'},  {kVK_ANSI_J, 'j','J'},  {kVK_ANSI_K, 'k','K'},  {kVK_ANSI_L, 'l','L'},
    {kVK_ANSI_M, 'm','M'},  {kVK_ANSI_N, 'n','N'},  {kVK_ANSI_O, 'o','O'},  {kVK_ANSI_P, 'p','P'},
    {kVK_ANSI_Q, 'q','Q'},  {kVK_ANSI_R, 'r','R'},  {kVK_ANSI_S, 's','S'},  {kVK_ANSI_T, 't','T'},
    {kVK_ANSI_U, 'u','U'},  {kVK_ANSI_V, 'v','V'},  {kVK_ANSI_W, 'w','W'},  {kVK_ANSI_X, 'x','X'},
    {kVK_ANSI_Y, 'y','Y'},  {kVK_ANSI_Z, 'z','Z'},
    
    {kVK_UpArrow, K_UPARROW},       {kVK_DownArrow, K_DOWNARROW},
    {kVK_LeftArrow, K_LEFTARROW},   {kVK_RightArrow, K_RIGHTARROW},
    
    {kVK_PageUp, K_PGUP}, {kVK_PageDown, K_PGDN},
    {kVK_Home, K_HOME}, {kVK_End, K_END},
    
    {kVK_F1, K_F1},  {kVK_F2, K_F2},  {kVK_F3, K_F3},  {kVK_F4, K_F4},
    {kVK_F5, K_F5},  {kVK_F6, K_F6},  {kVK_F7, K_F7},  {kVK_F8, K_F8},
    {kVK_F9, K_F9},  {kVK_F10, K_F10}, {kVK_F11, K_F11}, {kVK_F12, K_F12},
    {0,0}
};

static short mapKey (short keycode, BOOL shift) {
    for (int i = 0; keymap[i].mapped_key != 0; i++) {
        if (keymap[i].virtual_key == keycode) {
            return shift && keymap[i].shift_mapped_key
            ? keymap[i].shift_mapped_key
            : keymap[i].mapped_key;
        }
    }
    return -1;
}

@implementation QuakeApplication

- (void) handleKeyEvent:(NSEvent*) event {
    QuakeDelegate* delegate = self.delegate;
    short mappedKey = mapKey (event.keyCode, (event.modifierFlags & NSEventModifierFlagShift) ||
                              event.modifierFlags & NSEventModifierFlagCapsLock);
    if (mappedKey >= 0) {
        [delegate handleKey:mappedKey isDown:event.type == NSEventTypeKeyDown];
    } else {
        [super sendEvent:event];
    }
}

- (void) handleFlagsChangedEvent:(NSEvent*) event {
    NSEventModifierFlags flags = event.modifierFlags;
    Key_Event(K_SHIFT, ((flags & NSEventModifierFlagShift) == NSEventModifierFlagShift), 0);
    //Key_Event(, ((flags & NSEventModifierFlagCommand) == NSEventModifierFlagCommand), 0);
    //Key_Event(K_SHIFT, ((flags & NSEventModifierFlagOption) == NSEventModifierFlagOption), 0);
    Key_Event(K_CTRL, ((flags & NSEventModifierFlagControl) == NSEventModifierFlagControl), 0);
}

- (void) handleMouseMovedEvent:(NSEvent*) event {
    
}

- (void) sendEvent:(NSEvent *)event {
    
    switch (event.type) {
        case NSEventTypeScrollWheel:
            // Ignore if scrolling delta == 0
            if (event.scrollingDeltaY > 0) {
                
                Key_Event( K_MWHEELDOWN, true, 0 );
                Key_Event( K_MWHEELDOWN, false, 0 );
            } else if (event.scrollingDeltaY < 0) {
                Key_Event( K_MWHEELUP, true, 0 );
                Key_Event( K_MWHEELUP, false, 0 );
            }
            break;
        case NSEventTypeMouseMoved:
        case NSEventTypeLeftMouseDragged:
        case NSEventTypeRightMouseDragged:
            [self handleMouseMovedEvent:event];
            break;
        case NSEventTypeFlagsChanged:
            [self handleFlagsChangedEvent:event];
            break;
        case NSEventTypeLeftMouseUp:
        case NSEventTypeLeftMouseDown:
            Key_Event(K_MOUSE1, event.type == NSEventTypeLeftMouseDown, 0);
            break;
        case NSEventTypeKeyUp:
        case NSEventTypeKeyDown:
            if (!event.isARepeat) {
                if ((event.modifierFlags & NSEventModifierFlagCommand) == NSEventModifierFlagCommand)
                {
                    [super sendEvent:event];
                } else {
                    [self handleKeyEvent:event];
                }
            }
            break;
        default:
            //NSLog(@"Event: %@", event);
            //NSLog (@"Event Type: %d", event.type);
            [super sendEvent:event];
    }
}

@end
