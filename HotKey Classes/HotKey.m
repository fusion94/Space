//
//  HotKey.m
//  $Id: HotKey.m,v 1.9 2002/06/04 01:33:09 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>
#import "HotKey.h"

// Undocumented API: proceed with caution /////////////////x/////////////

extern mach_port_t _CGSDefaultConnection(void);

extern void CGSSetHotKeyWithExclusion(mach_port_t connection, 
                                      int uid, unsigned short options,
                                      unsigned short key, 
                                      unsigned int modifier_flags, 
                                      int exclusion);

extern void CGSSetHotKey (mach_port_t connection, int uid, int options,
                          unsigned short key, unsigned int modifier_flags);

extern BOOL CGSGetHotKey (mach_port_t connection, int uid, int *options,
                          unsigned short *key, unsigned int *modifier_flags);

extern void CGSRemoveHotKey(mach_port_t connection, int uid);

extern void CGSSetHotKeyEnabled(mach_port_t connection, int uid, BOOL onOff);        extern BOOL CGSIsHotKeyEnabled (mach_port_t connection, int uid);

////////////////////////////////////////////////////////////////

@implementation HotKey

+ (HotKey*) HotKeyForUID: (int) searchUID
{

    int            newOptions;
    unsigned short keycode; 
    unsigned int   modifier_flags;

    mach_port_t CGSConnection = _CGSDefaultConnection();
    if (!CGSConnection) return nil;
     
    // is it a boolean, or something bigger?
    if (!CGSGetHotKey (CGSConnection, searchUID, 
                       &newOptions, &keycode, &modifier_flags)) {

        HotKey *newHotKey = [[HotKey alloc] 
                          initWithUID: searchUID options: newOptions 
                          keycode: keycode flags: modifier_flags];

        return [newHotKey autorelease];
    }
    else
        return nil;
    
}



- (HotKey*) initWithUID: (int)newUid options:(unsigned short)newOptions keycode:(unsigned short)newKey flags:(unsigned int)modifier_flags exclusion:(int)newExclusion
{

    uid        = newUid;
    options    = newOptions;
    key        = newKey;
    flags      = modifier_flags;
    exclusion  = newExclusion;

    return self;
}

- (HotKey*) initWithUID: (int)newuid options:(unsigned short)newoptions keycode:(unsigned short)newkey flags:(unsigned int)modifier_flags
{
    return [self initWithUID: newuid options: newoptions keycode:newkey flags: modifier_flags 
                 exclusion: 0x0];
}

- (HotKey*) initWithUID: (int)newuid keycode:(unsigned short)newkey flags:(unsigned int)modifier_flags
{
    return [self initWithUID: newuid options: 0x0 keycode: newkey 
                 flags: modifier_flags exclusion: 0x0];
}

-(int)            getUID       { return uid;       }
-(unsigned short) getOptions   { return options;   }
-(unsigned short) getKey       { return key;       }
-(unsigned int)   getFlags     { return flags;     }
-(int)            getExclusion { return exclusion; }

- (void) registerWithCGS
{   // check if enabled first?
    mach_port_t CGSConnection = _CGSDefaultConnection();

    if (CGSConnection)
        CGSSetHotKeyWithExclusion (CGSConnection, uid, 0x0, 
                                   key, flags, exclusion);
    else
        NSLog(@"Could not get port to register hotkey");

}

- (void) setEnabled:(BOOL)onOff
{
    mach_port_t CGSConnection = _CGSDefaultConnection();
    
    if (CGSConnection)
        CGSSetHotKeyEnabled(CGSConnection, uid, onOff);
    else
        NSLog(@"Could not get port to configure hotkey");
}

- (BOOL) isEnabled
{
    mach_port_t CGSConnection = _CGSDefaultConnection();
    if (CGSConnection)
        return CGSIsHotKeyEnabled(CGSConnection, uid);
    else {
        NSLog(@"Could not get port to query hotkey");
        return NO;
    }	
}

- (void) removeFromCGS
{
    mach_port_t CGSConnection = _CGSDefaultConnection();

    if (CGSConnection)
        CGSRemoveHotKey(CGSConnection, uid);
    else
        NSLog(@"Could not get port to remove hotkey");
}

@end
