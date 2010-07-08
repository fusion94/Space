//
//  PersistentHotKey.h
//  $Id: PersistentHotKey.h,v 1.5 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Foundation/Foundation.h>
#import "HotKey.h"

#define HOTKEY_DICT_PREFKEY       @"HotKeys"
#define HOTKEY_TEMPLATE_DICTKEY   @"HotKey_0x%x"

#define HOTKEY_UID_PREFKEY        @"HotKeyUID"
#define HOTKEY_KEYS_PREFKEY       @"HotKeyKeys"
#define HOTKEY_FLAGS_PREFKEY      @"HotKeyFlags"
#define HOTKEY_ACTIVE_PREFKEY     @"HotKeyActive"

@interface PersistentHotKey : HotKey
{
    BOOL active;
}

+ (void)              registerDefaults; // i.e. register with CGS
+ (PersistentHotKey*) loadForUID: (int)UID;

- (void)              saveToDefaults;

- (BOOL)              isActive;
- (void)              setActive:(BOOL)onOFF;

@end
