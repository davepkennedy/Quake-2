/*
 Copyright (C) 1997-2001 Id Software, Inc.
 
 This program is free software; you can redistribute it and/or
 modify it under the terms of the GNU General Public License
 as published by the Free Software Foundation; either version 2
 of the License, or (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 
 See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 
 */

#include "../../ref_gl/gl_local.h"
#import <Cocoa/Cocoa.h>
#import "../Quake2/Quake2/GameWindow.h"

NSOpenGLContext* context = NULL;
NSWindow* mainWindow = NULL;
GameWindow* gameWindow = NULL;

static NSOpenGLPixelFormat* GLimp_pixelFormat () {
    NSOpenGLPixelFormatAttribute attribs[] =
    {
        /**
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFAAllowOfflineRenderers, // lets OpenGL know this context is offline renderer aware
        NSOpenGLPFAMultisample, 1,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 4,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFADepthSize, 24,
        //NSOpenGLPFAOpenGLProfile, NSOpenGLProfileVersion3_2Core, // Core Profile is the future
        0
        */
        /* */
        
         NSOpenGLPFANoRecovery,
        NSOpenGLPFAClosestPolicy,
        NSOpenGLPFAAccelerated,
        NSOpenGLPFADoubleBuffer,
        NSOpenGLPFADepthSize, 1,
        NSOpenGLPFAAlphaSize, 0,
        NSOpenGLPFAStencilSize, 0,
        NSOpenGLPFAAccumSize, 0,
        NSOpenGLPFAColorSize, 32,
        NSOpenGLPFASampleBuffers, 1,
        NSOpenGLPFASamples, 8,
        0
        /* */
    };
    
    NSOpenGLPixelFormat *pf = [[NSOpenGLPixelFormat alloc] initWithAttributes:attribs];
    if(!pf)
    {
        NSLog(@"Failed to create pixel format.");
        return nil;
    }
    return pf;
}

static NSOpenGLContext* GLimp_makeContext () {
    NSOpenGLContext* context = [[NSOpenGLContext alloc] initWithFormat:GLimp_pixelFormat() shareContext:nil];
    CGLEnable([context CGLContextObj], kCGLCECrashOnRemovedFunctions);
    return context;
}

void		GLimp_BeginFrame( float camera_separation )
{
    [context makeCurrentContext];
    CGLLockContext([context CGLContextObj]);
}

void		GLimp_EndFrame( void )
{
    CGLFlushDrawable([context CGLContextObj]);
    CGLUnlockContext([context CGLContextObj]);
    [gameWindow centerMouse];
}

int 		GLimp_Init( void *hinstance, void *hWnd )
{
    return true;
}

void		GLimp_Shutdown( void )
{
}

void GLimp_CreateGameWindow (NSRect frame, int* pwidth, int* pheight) {
    gameWindow = [[GameWindow alloc] initWithContentRect:frame
                                             styleMask:NSWindowStyleMaskTitled
                                               backing:NSBackingStoreRetained
                                                defer:NO];
    [gameWindow setTitle:@"Quake 2"];
    [gameWindow orderFront:nil];
    [gameWindow setAcceptsMouseMovedEvents:YES];
    
    context = GLimp_makeContext ();
    context.view = gameWindow.contentView;
    
    *pwidth = NSWidth(frame);
    *pheight = NSHeight(frame);
    
    [context makeCurrentContext];
    [context update];
    
}

int GLimp_SetMode( int *pwidth, int *pheight, int mode, qboolean fullscreen )
{
    int width, height, left, top;
    ri.Con_Printf(PRINT_ALL, "Creating GL Display");
    if (!ri.Vid_GetModeInfo (&width, &height, mode)) {
        return rserr_invalid_mode;
    }
    NSScreen* screen = [NSScreen mainScreen];
    NSRect screenFrame = [screen frame];
    left = (screenFrame.size.width - width) / 2;
    top = (screenFrame.size.height - height) / 2;
    
    NSRect windowFrame = NSMakeRect(left, top, width, height);
    GLimp_CreateGameWindow(windowFrame, pwidth, pheight);
    ri.Vid_NewWindow (width, height);
    return (rserr_ok);
}

void		GLimp_AppActivate( qboolean active )
{
}

