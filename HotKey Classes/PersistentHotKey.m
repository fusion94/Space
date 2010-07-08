//
//  PersistentHotKey.m
//  $Id: PersistentHotKey.m,v 1.7 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#include "space-defines.h";
#import "PersistentHotKey.h"
#import "HotKey.h"


@interface PersistentHotKey (Private)
+ (PersistentHotKey*) hotKeyForDict: (NSDictionary*) hotDict;
@end


@implementation PersistentHotKey (Private)
+ (PersistentHotKey*) hotKeyForDict: (NSDictionary*) hotDict
{
    PersistentHotKey *retval =
       [[PersistentHotKey alloc] 
            initWithUID:	[[hotDict objectForKey: HOTKEY_UID_PREFKEY] intValue]
            keycode:     	[[hotDict objectForKey: HOTKEY_KEYS_PREFKEY] intValue]
            flags:       	[[hotDict objectForKey: HOTKEY_FLAGS_PREFKEY] intValue]];
 
    if ([[hotDict objectForKey: HOTKEY_ACTIVE_PREFKEY] boolValue])
        [retval setActive: YES];
    else
        [retval setActive: NO];
              
    return [retval autorelease];
}
@end

@implementation PersistentHotKey

+ (void) registerDefaults
{
    NSDictionary *prefDict = 
        [[NSUserDefaults standardUserDefaults] dictionaryForKey: HOTKEY_DICT_PREFKEY];
    NSEnumerator *eachHotKeyDict = [prefDict objectEnumerator];    
    NSDictionary *thisHotKeyDict = nil;

    while ((thisHotKeyDict = [eachHotKeyDict nextObject]) != nil) {    
        PersistentHotKey *thisHotKey = [PersistentHotKey hotKeyForDict: thisHotKeyDict];
        if (thisHotKey && [thisHotKey isActive]) [thisHotKey registerWithCGS];
    }
}

+ (PersistentHotKey*) loadForUID: (int)loadUID
{
    PersistentHotKey *retval   = nil;
    NSDictionary     *hotDict  = nil;
    NSString         *dictKey  = [NSString stringWithFormat: HOTKEY_TEMPLATE_DICTKEY, loadUID];
    NSDictionary     *prefDict = 
        [[NSUserDefaults standardUserDefaults] dictionaryForKey: HOTKEY_DICT_PREFKEY];
    
    if (prefDict != nil)
        hotDict = [prefDict objectForKey: dictKey];

    if (hotDict  != nil)
        retval = [PersistentHotKey hotKeyForDict: hotDict];
    
    return retval;
}

- (void) saveToDefaults
{
    if (uid && key) {
    
        NSString       *dictKey  = [NSString stringWithFormat: HOTKEY_TEMPLATE_DICTKEY, uid];
    
        NSDictionary   *newDict  = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithInt: uid], HOTKEY_UID_PREFKEY,
                                        [NSNumber numberWithBool: active], HOTKEY_ACTIVE_PREFKEY,
                                        [NSNumber numberWithInt: key], HOTKEY_KEYS_PREFKEY,
                                        [NSNumber numberWithInt: flags], HOTKEY_FLAGS_PREFKEY,
                                    nil];
    
        NSDictionary *readDict = [[NSUserDefaults standardUserDefaults] 
                                    dictionaryForKey: HOTKEY_DICT_PREFKEY];
        
        NSMutableDictionary *writeDict = nil;
        
        if (readDict)
            writeDict = [NSMutableDictionary dictionaryWithDictionary: readDict];
        else
            writeDict = [[[NSMutableDictionary alloc] init] autorelease]; 
                                    
        [writeDict setObject: newDict forKey: dictKey];
        
        [[NSUserDefaults standardUserDefaults] setObject: writeDict forKey: HOTKEY_DICT_PREFKEY];
        
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (BOOL)              isActive
{    
    return active;
}

- (void)              setActive:(BOOL)onOff
{
    active = onOff;
}

@end
