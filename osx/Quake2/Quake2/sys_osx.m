//
//  sys_osx.m
//  Quake2
//
//  Created by Dave Kennedy on 28/11/2016.
//  Copyright © 2016 Dave Kennedy. All rights reserved.
//

#include "../../../qcommon/qcommon.h"
#include "errno.h"
#include <sys/time.h>
#include <dlfcn.h>

#import <Foundation/Foundation.h>

int	curtime;

unsigned	sys_frame_time;
void* gameHandle = NULL;


void Sys_mkdir (char *path)
{
}

void Sys_Error (char *error, ...)
{
    va_list		argptr;
    
    printf ("Sys_Error: ");
    va_start (argptr,error);
    vprintf (error,argptr);
    va_end (argptr);
    printf ("\n");
    
    exit (1);
}

void Sys_Quit (void)
{
    exit (0);
}

void	Sys_UnloadGame (void)
{
    if (gameHandle) {
        dlclose(gameHandle);
    }
    gameHandle = NULL;
}

void	*Sys_GetGameAPI (void *parms)
{
    char	name[MAX_OSPATH];
    char	*path;
    char	cwd[MAX_OSPATH];
    const char *gamename = "libgame.dylib";
    
    void* (*GetGameAPI)(void*);
    if (gameHandle) {
        Com_Error (ERR_FATAL, "Sys_GetGameAPI without Sys_UnloadingGame");
    }
    getcwd(cwd, sizeof(cwd));
    
    Com_sprintf (name, sizeof(name), "%s/%s", cwd, gamename);
    gameHandle = dlopen(name, RTLD_LAZY);
    if (gameHandle)
    {
        Com_DPrintf ("LoadLibrary (%s)\n", name);
    }
    else
    {
        NSLog (@"Sys_GetGameAPI failed (1) %s", dlerror());
        // now run through the search paths
        path = NULL;
        while (1)
        {
            path = FS_NextPath (path);
            if (!path) {
                return NULL;		// couldn't find one anywhere
            }
            Com_sprintf (name, sizeof(name), "%s/%s", path, gamename);
            gameHandle = dlopen(name, RTLD_LAZY);
            if (gameHandle)
            {
                Com_DPrintf ("LoadLibrary (%s)\n",name);
                break;
            }
        }
    }
    
    GetGameAPI = dlsym(gameHandle, "GetGameAPI");
    if (!GetGameAPI)
    {
        Sys_UnloadGame ();
        return NULL;
    }
    
    return GetGameAPI (parms);
}

char *Sys_ConsoleInput (void)
{
    return NULL;
}

void	Sys_ConsoleOutput (char *string)
{
}

void Sys_SendKeyEvents (void)
{
    sys_frame_time = Sys_Milliseconds();
}

void Sys_AppActivate (void)
{
}

void Sys_CopyProtect (void)
{
}

char *Sys_GetClipboardData( void )
{
    return NULL;
}

int		Sys_Milliseconds (void)
{
    static CFAbsoluteTime baseTime;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        baseTime = CFAbsoluteTimeGetCurrent();
    });
    curtime = (CFAbsoluteTimeGetCurrent() - baseTime) * 1000.0f;
    return curtime;
}

char	*Sys_FindFirst (char *path, unsigned musthave, unsigned canthave)
{
    return NULL;
}

char	*Sys_FindNext (unsigned musthave, unsigned canthave)
{
    return NULL;
}

void	Sys_FindClose (void)
{
}

void	Sys_Init (void)
{
}
