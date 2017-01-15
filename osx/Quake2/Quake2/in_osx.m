//
//  in_osx.m
//  Quake2
//
//  Created by Dave Kennedy on 28/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#include "../../../client/client.h"
//#include "../../../qcommon/qcommon.h"
#import <Cocoa/Cocoa.h>

cvar_t	*in_mouse;
cvar_t	*in_joystick;

qboolean mouseactive = false;


// none of these cvars are saved over a session
// this means that advanced controller configuration needs to be executed
// each time.  this avoids any problems with getting back to a default usage
// or when changing from one controller to another.  this way at least something
// works.
cvar_t	*joy_name;
cvar_t	*joy_advanced;
cvar_t	*joy_advaxisx;
cvar_t	*joy_advaxisy;
cvar_t	*joy_advaxisz;
cvar_t	*joy_advaxisr;
cvar_t	*joy_advaxisu;
cvar_t	*joy_advaxisv;
cvar_t	*joy_forwardthreshold;
cvar_t	*joy_sidethreshold;
cvar_t	*joy_pitchthreshold;
cvar_t	*joy_yawthreshold;
cvar_t	*joy_forwardsensitivity;
cvar_t	*joy_sidesensitivity;
cvar_t	*joy_pitchsensitivity;
cvar_t	*joy_yawsensitivity;
cvar_t	*joy_upthreshold;
cvar_t	*joy_upsensitivity;

extern cvar_t  *sensitivity;
cvar_t	*v_centermove;
cvar_t	*v_centerspeed;

extern cvar_t  *m_pitch;

cvar_t	*m_filter;
extern cvar_t	*m_yaw;
extern cvar_t	*m_forward;
extern cvar_t	*m_side;
extern cvar_t  *freelook;
extern cvar_t  *lookstrafe;

extern 	kbutton_t 	in_strafe;

CGFloat window_center_x = 320, window_center_y = 240;
int mouse_x, mouse_y, old_mouse_x, old_mouse_y, mx_accum, my_accum;

qboolean	mlooking;

void IN_MLookDown (void) { mlooking = true; }
void IN_MLookUp (void) {
    mlooking = false;
    if (!freelook->value && lookspring->value)
        IN_CenterView ();
}

/*
 ===========
 IN_MouseMove
===========
*/
void IN_MouseMove (usercmd_t *cmd)
{
    int		mx, my;
    
    if (!mouseactive)
        return;
    
    // find mouse movement
    CGGetLastMouseDelta(&mx, &my);
    
    
    if (m_filter->value)
    {
        mouse_x = (mx + old_mouse_x) * 0.5;
        mouse_y = (my + old_mouse_y) * 0.5;
    }
    else
    {
        mouse_x = mx;
        mouse_y = my;
    }
    
    old_mouse_x = mx;
    old_mouse_y = my;
    
    mouse_x *= sensitivity->value;
    mouse_y *= sensitivity->value;
    
    // add mouse X/Y movement to cmd
    if ( (in_strafe.state & 1) || (lookstrafe->value && mlooking ))
        cmd->sidemove += m_side->value * mouse_x;
    else
        cl.viewangles[YAW] -= m_yaw->value * mouse_x;
    
    if ( (mlooking || freelook->value) && !(in_strafe.state & 1))
    {
        cl.viewangles[PITCH] += m_pitch->value * mouse_y;
    }
    else
    {
        cmd->forwardmove -= m_forward->value * mouse_y;
    }
}

void IN_Init (void)
{
    // mouse variables
    m_filter				= Cvar_Get ("m_filter",					"0",		0);
    in_mouse				= Cvar_Get ("in_mouse",					"1",		CVAR_ARCHIVE);
    
    // joystick variables
    in_joystick				= Cvar_Get ("in_joystick",				"0",		CVAR_ARCHIVE);
    joy_name				= Cvar_Get ("joy_name",					"joystick",	0);
    joy_advanced			= Cvar_Get ("joy_advanced",				"0",		0);
    joy_advaxisx			= Cvar_Get ("joy_advaxisx",				"0",		0);
    joy_advaxisy			= Cvar_Get ("joy_advaxisy",				"0",		0);
    joy_advaxisz			= Cvar_Get ("joy_advaxisz",				"0",		0);
    joy_advaxisr			= Cvar_Get ("joy_advaxisr",				"0",		0);
    joy_advaxisu			= Cvar_Get ("joy_advaxisu",				"0",		0);
    joy_advaxisv			= Cvar_Get ("joy_advaxisv",				"0",		0);
    joy_forwardthreshold	= Cvar_Get ("joy_forwardthreshold",		"0.15",		0);
    joy_sidethreshold		= Cvar_Get ("joy_sidethreshold",		"0.15",		0);
    joy_upthreshold  		= Cvar_Get ("joy_upthreshold",			"0.15",		0);
    joy_pitchthreshold		= Cvar_Get ("joy_pitchthreshold",		"0.15",		0);
    joy_yawthreshold		= Cvar_Get ("joy_yawthreshold",			"0.15",		0);
    joy_forwardsensitivity	= Cvar_Get ("joy_forwardsensitivity",	"-1",		0);
    joy_sidesensitivity		= Cvar_Get ("joy_sidesensitivity",		"-1",		0);
    joy_upsensitivity		= Cvar_Get ("joy_upsensitivity",		"-1",		0);
    joy_pitchsensitivity	= Cvar_Get ("joy_pitchsensitivity",		"1",		0);
    joy_yawsensitivity		= Cvar_Get ("joy_yawsensitivity",		"-1",		0);
    
    // centering
    v_centermove			= Cvar_Get ("v_centermove",				"0.15",		0);
    v_centerspeed			= Cvar_Get ("v_centerspeed",			"500",		0);
    
    // freelook		= Cvar_Get( "freelook", "0", 0 );
    // lookstrafe		= Cvar_Get ("lookstrafe", "0", 0);
    // m_pitch			= Cvar_Get ("m_pitch", "0.022", 0);
    // m_yaw			= Cvar_Get ("m_yaw", "0.022", 0);
    // m_forward		= Cvar_Get ("m_forward", "1", 0);
    // m_side			= Cvar_Get ("m_side", "0.8", 0);
    
    Cmd_AddCommand ("+mlook", IN_MLookDown);
    Cmd_AddCommand ("-mlook", IN_MLookUp);
    
    //Cmd_AddCommand ("joy_advancedupdate", Joy_AdvancedUpdate_f);
    
    //IN_StartupMouse ();
    //IN_StartupJoystick ();
}

void IN_Shutdown (void)
{
}

void IN_Commands (void)
{
}

void IN_Frame (void)
{
}

void IN_Move (usercmd_t *cmd)
{
    IN_MouseMove(cmd);
}

void IN_Activate (qboolean active)
{
}

void IN_ActivateMouse (void)
{
    mouseactive = true;
    CGDisplayHideCursor(kCGDirectMainDisplay);
}

void IN_DeactivateMouse (void)
{
    mouseactive = false;
    CGDisplayShowCursor(kCGDirectMainDisplay);
}
