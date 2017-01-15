//
//  vid_osx.m
//  Quake2
//
//  Created by Dave Kennedy on 28/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//
// vid_null.c -- null video driver to aid porting efforts
// this assumes that one of the refs is statically linked to the executable

#include "../../../client/client.h"
#include "../../../client/qmenu.h"

#include "QuakeDelegate.h"

#import <Cocoa/Cocoa.h>
#import <dlfcn.h>

// #import "QuakeDelegate.h"

extern cvar_t *gl_mode;


viddef_t	viddef;				// global video state

refexport_t	re;

#ifdef REF_HARD_LINKED
refexport_t GetRefAPI (refimport_t rimp);
#else
typedef refexport_t (*GetRefAPI_t) (refimport_t rimp);
#endif

/*
 ==========================================================================
 
 DIRECT LINK GLUE
 
 ==========================================================================
 */

#define	MAXPRINTMSG	4096
void VID_Printf (int print_level, char *fmt, ...)
{
    va_list		argptr;
    char		msg[MAXPRINTMSG];
    
    va_start (argptr,fmt);
    vsprintf (msg,fmt,argptr);
    va_end (argptr);
    
    if (print_level == PRINT_ALL)
        Com_Printf ("%s", msg);
    else
        Com_DPrintf ("%s", msg);
}

void VID_Error (int err_level, char *fmt, ...)
{
    va_list		argptr;
    char		msg[MAXPRINTMSG];
    
    va_start (argptr,fmt);
    vsprintf (msg,fmt,argptr);
    va_end (argptr);
    
    Com_Error (err_level, "%s", msg);
}

void VID_NewWindow (int width, int height)
{
    viddef.width = width;
    viddef.height = height;
}

/*
 ** VID_GetModeInfo
 */
typedef struct vidmode_s
{
    const char *description;
    int         width, height;
    int         mode;
} vidmode_t;

vidmode_t vid_modes[] =
{
    { "Mode 0: 320x240",   320, 240,   0 },
    { "Mode 1: 400x300",   400, 300,   1 },
    { "Mode 2: 512x384",   512, 384,   2 },
    { "Mode 3: 640x480",   640, 480,   3 },
    { "Mode 4: 800x600",   800, 600,   4 },
    { "Mode 5: 960x720",   960, 720,   5 },
    { "Mode 6: 1024x768",  1024, 768,  6 },
    { "Mode 7: 1152x864",  1152, 864,  7 },
    { "Mode 8: 1280x960",  1280, 960, 8 },
    { "Mode 9: 1600x1200", 1600, 1200, 9 }
};
#define VID_NUM_MODES ( sizeof( vid_modes ) / sizeof( vid_modes[0] ) )

static const char* resolutions [] = {
    "[320  240 ]",
    "[400  300 ]",
    "[512  384 ]",
    "[640  480 ]",
    "[800  600 ]",
    "[960  720 ]",
    "[1024 768 ]",
    "[1152 864 ]",
    "[1280 960 ]",
    "[1600 1200]",
    0
};

static menuframework_s	s_vid_menu;
static menulist_s		s_mode_list;
static menuslider_s		s_tq_slider;
static menuslider_s		s_screensize_slider;
static menulist_s  		s_fs_box;
static menulist_s  		s_paletted_texture_box;
static menulist_s  		s_finish_box;
static menuaction_s		s_cancel_action;
static menuaction_s		s_defaults_action;

qboolean VID_GetModeInfo( int *width, int *height, int mode )
{
    if ( mode < 0 || mode >= VID_NUM_MODES )
        return false;
    
    *width  = vid_modes[mode].width;
    *height = vid_modes[mode].height;
    
    return true;
}

#ifndef REF_HARD_LINKED
void* rendererHandle;

static void loadRenderer () {
    char cwd [MAX_OSPATH];
    char name [MAX_OSPATH];
    char* library = "libref_gl.dylib";
    getcwd(cwd, MAX_OSPATH);
    Com_sprintf (name, sizeof(name), "%s/%s", cwd, library);
    rendererHandle = dlopen(name, RTLD_LAZY);
}
#endif

NSWindow* getMainWindow () {
    QuakeDelegate* delegate = [NSApplication sharedApplication].delegate;
    return [delegate window];
}

void	VID_Init (void)
{
    refimport_t	ri;
    
    viddef.width = 320;
    viddef.height = 240;
    
    memset (&ri, 0, sizeof (refimport_t));
    ri.Cmd_AddCommand = Cmd_AddCommand;
    ri.Cmd_RemoveCommand = Cmd_RemoveCommand;
    ri.Cmd_Argc = Cmd_Argc;
    ri.Cmd_Argv = Cmd_Argv;
    ri.Cmd_ExecuteText = Cbuf_ExecuteText;
    ri.Con_Printf = VID_Printf;
    ri.Sys_Error = VID_Error;
    ri.FS_LoadFile = FS_LoadFile;
    ri.FS_FreeFile = FS_FreeFile;
    ri.FS_Gamedir = FS_Gamedir;
    ri.Vid_NewWindow = VID_NewWindow;
    ri.Cvar_Get = Cvar_Get;
    ri.Cvar_Set = Cvar_Set;
    ri.Cvar_SetValue = Cvar_SetValue;
    ri.Vid_GetModeInfo = VID_GetModeInfo;
    ri.Vid_MenuInit = VID_MenuInit;
    
    
#ifdef REF_HARD_LINKED
    re = GetRefAPI(ri);
#else
    loadRenderer ();
    GetRefAPI_t GetRefAPI = dlsym(rendererHandle, "GetRefAPI");
    re = GetRefAPI(ri);
    
    if (re.api_version != API_VERSION) {
        Com_Error (ERR_FATAL, "Re has incompatible api_version");
    }
#endif
    
    // call the init function
    
    if (re.Init (NULL, (__bridge void *)getMainWindow()) == -1)
        Com_Error (ERR_FATAL, "Couldn't start refresh");
}

void	VID_Shutdown (void)
{
    if (re.Shutdown)
        re.Shutdown ();
    
#ifndef REF_HARD_LINKED
    if (rendererHandle) {
        dlclose (rendererHandle);
        rendererHandle = NULL;
    }
#endif
}

void	VID_CheckChanges (void)
{
    if (gl_mode->modified) {
        gl_mode->modified = false;
        Com_Printf("Restart to update video settings");
    }
}

static void ScreenSizeCallback( void *s )
{
    menuslider_s *slider = ( menuslider_s * ) s;
    
    Cvar_SetValue( "viewsize", slider->curvalue * 10 );
}

static void ResetDefaults( void *unused )
{
    VID_MenuInit();
}

static void CancelChanges( void *unused )
{
    extern void M_PopMenu( void );
    
    M_PopMenu();
}

static void ApplyChanges( void *unused )
{
    float gamma;
    
    /*
     ** invert sense so greater = brighter, and scale to a range of 0.5 to 1.3
     */
    // gamma = ( 0.8 - ( s_brightness_slider[s_current_menu_index].curvalue/10.0 - 0.5 ) ) + 0.5;
    
    // Cvar_SetValue( "vid_gamma", gamma );
    // Cvar_SetValue( "sw_stipplealpha", s_stipple_box.curvalue );
    // Cvar_SetValue( "gl_picmip", 3 - s_tq_slider.curvalue );
    // Cvar_SetValue( "vid_fullscreen", s_fs_box[s_current_menu_index].curvalue );
    // Cvar_SetValue( "gl_ext_palettedtexture", s_paletted_texture_box.curvalue );
    // Cvar_SetValue( "gl_finish", s_finish_box.curvalue );
    Cvar_SetValue( "gl_mode", s_mode_list.curvalue );
    
    M_ForceMenuOff();
}

void	VID_MenuInit (void)
{
    static const char *yesno_names[] =
    {
        "no",
        "yes",
        0
    };
    
    s_mode_list.curvalue = gl_mode->value;
    
    if ( !scr_viewsize )
        scr_viewsize = Cvar_Get ("viewsize", "100", CVAR_ARCHIVE);
    
    s_screensize_slider.curvalue = scr_viewsize->value/10;
    
    s_vid_menu.x = viddef.width * 0.50;
    s_vid_menu.nitems = 0;
    
    s_mode_list.generic.type = MTYPE_SPINCONTROL;
    s_mode_list.generic.name = "video mode";
    s_mode_list.generic.x = 0;
    s_mode_list.generic.y = 10;
    s_mode_list.itemnames = resolutions;
        
    s_screensize_slider.generic.type	= MTYPE_SLIDER;
    s_screensize_slider.generic.x		= 0;
    s_screensize_slider.generic.y		= 20;
    s_screensize_slider.generic.name	= "screen size";
    s_screensize_slider.minvalue = 3;
    s_screensize_slider.maxvalue = 12;
    s_screensize_slider.generic.callback = ScreenSizeCallback;
    
    /*
    s_fs_box.generic.type = MTYPE_SPINCONTROL;
    s_fs_box.generic.x	= 0;
    s_fs_box.generic.y	= 30;
    s_fs_box.generic.name	= "fullscreen";
    s_fs_box.itemnames = yesno_names;
    s_fs_box.curvalue = vid_fullscreen->value;
    */
        
    s_defaults_action.generic.type = MTYPE_ACTION;
    s_defaults_action.generic.name = "reset to defaults";
    s_defaults_action.generic.x    = 0;
    s_defaults_action.generic.y    = 40;
    s_defaults_action.generic.callback = ResetDefaults;
        
    s_cancel_action.generic.type = MTYPE_ACTION;
    s_cancel_action.generic.name = "cancel";
    s_cancel_action.generic.x    = 0;
    s_cancel_action.generic.y    = 50;
    s_cancel_action.generic.callback = CancelChanges;
    
    /*
    s_tq_slider.generic.type	= MTYPE_SLIDER;
    s_tq_slider.generic.x		= 0;
    s_tq_slider.generic.y		= 60;
    s_tq_slider.generic.name	= "texture quality";
    s_tq_slider.minvalue = 0;
    s_tq_slider.maxvalue = 3;
    s_tq_slider.curvalue = 3-gl_picmip->value;
    */
    
    /*
    s_paletted_texture_box.generic.type = MTYPE_SPINCONTROL;
    s_paletted_texture_box.generic.x	= 0;
    s_paletted_texture_box.generic.y	= 70;
    s_paletted_texture_box.generic.name	= "8-bit textures";
    s_paletted_texture_box.itemnames = yesno_names;
    s_paletted_texture_box.curvalue = gl_ext_palettedtexture->value;
    */
    
    /*
    s_finish_box.generic.type = MTYPE_SPINCONTROL;
    s_finish_box.generic.x	= 0;
    s_finish_box.generic.y	= 80;
    s_finish_box.generic.name	= "sync every frame";
    s_finish_box.curvalue = gl_finish->value;
    s_finish_box.itemnames = yesno_names;
    */
    
    //Menu_AddItem( &s_vid_menu, ( void * ) &s_ref_list );
    Menu_AddItem( &s_vid_menu, ( void * ) &s_mode_list );
    Menu_AddItem( &s_vid_menu, ( void * ) &s_screensize_slider );
    // Menu_AddItem( &s_vid_menu, ( void * ) &s_brightness_slider );
    // Menu_AddItem( &s_vid_menu, ( void * ) &s_fs_box );
    // Menu_AddItem( &s_vid_menu, ( void * ) &s_tq_slider );
    // Menu_AddItem( &s_vid_menu, ( void * ) &s_paletted_texture_box );
    // Menu_AddItem( &s_vid_menu, ( void * ) &s_finish_box );
    
    Menu_AddItem( &s_vid_menu, ( void * ) &s_defaults_action );
    Menu_AddItem( &s_vid_menu, ( void * ) &s_cancel_action );
    
    Menu_Center( &s_vid_menu );
    s_vid_menu.x -= 8;
}

void	VID_MenuDraw (void)
{
    int w, h;
    
    /*
     ** draw the banner
     */
    re.DrawGetPicSize( &w, &h, "m_banner_video" );
    re.DrawPic( viddef.width / 2 - w / 2, viddef.height /2 - 110, "m_banner_video" );
    
    /*
     ** move cursor to a reasonable starting position
     */
    Menu_AdjustCursor( &s_vid_menu, 1 );
    
    /*
     ** draw the menu
     */
    Menu_Draw( &s_vid_menu );
}

const char *VID_MenuKey( int key)
{
    static const char *sound = "misc/menu1.wav";
    
    switch ( key )
    {
        case K_ESCAPE:
            ApplyChanges( 0 );
            return NULL;
        case K_KP_UPARROW:
        case K_UPARROW:
            s_vid_menu.cursor--;
            Menu_AdjustCursor( &s_vid_menu, -1 );
            break;
        case K_KP_DOWNARROW:
        case K_DOWNARROW:
            s_vid_menu.cursor++;
            Menu_AdjustCursor( &s_vid_menu, 1 );
            break;
        case K_KP_LEFTARROW:
        case K_LEFTARROW:
            Menu_SlideItem( &s_vid_menu, -1 );
            break;
        case K_KP_RIGHTARROW:
        case K_RIGHTARROW:
            Menu_SlideItem( &s_vid_menu, 1 );
            break;
        case K_KP_ENTER:
        case K_ENTER:
            if ( !Menu_SelectItem( &s_vid_menu ) )
                ApplyChanges( NULL );
            break;
    }
    
    return sound;
}
