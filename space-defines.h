//
//  space-defines.h
//  $Id: space-defines.h,v 1.32 2002/06/04 06:56:31 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#ifndef __SPACE_DEFINES__
#define __SPACE_DEFINES__

//#define DEBUG

#ifdef DEBUG
// Anybody know how to define vararg macros with this compiler? This isn't working...
// #define DEBUG_OUT(format,args...) NSLog(format, ## args)
#define DEBUG_OUT(x) NSLog(x)
#define DEBUG_OUTF(f,x) NSLog(f,x)
#else
#define DEBUG_OUT(x)
#define DEBUG_OUTF(f,x)
#endif

#define MIN_SPACE_OPTIONS   4
#define MIN_SPACES          2
#define MAX_SPACES         16
#define MAX_MENU_PROCESSES  3

// Garbage collection constants
#define GC_COUNT_THRESHOLD 12

// Space index constants
#define SPACE_INDEX_NO_SPACE    -1
#define SPACE_INDEX_STICKY       0
#define SPACE_INDEX_FIRST_SPACE  1

#define LEGACY_BUNDLE CFSTR("Space")
#define SPACE_BUNDLE  @"com.codeclever.Space"

#define COUNT_PREFKEY  @"WorkspaceCount"
#define kCOUNT_PREFKEY CFSTR("WorkspaceCount")
#define COUNT_DEFAULT  4

// Localizable strings
#define STRING_TABLE        @"Localizable"
#define ADD_SPACE_LABEL     @"Add Space"
#define REM_SPACE_LABEL     @"Remove Space"
#define LABEL_CURRENT_SPACE @"(Current Space)"
#define LABEL_EMPTY_SPACE   @"(Empty Space)"
#define LABEL_STICKY_SPACE  @"(Sticky Space)"

// FIXME: L13N
#define BB_TITLE                  @"Space" 
#define STICKY_TITLE              @"sticky"
#define SHOW_PALETTE_LABEL        @"Show palette"
#define HIDE_PALETTE_LABEL        @"Hide palette"

// Preference keys and defaults
#define SPACE_WINDOW_SAVENAME     @"ButtonBoxFrame"
#define PREFS_WINDOW_SAVENAME     @"PrefsFrame"
#define ALWAYS_PREFKEY            @"DisableDockmode"
#define ALWAYS_DEFAULT            NO
#define PALETTE_PREFKEY           @"ShowPalette"
#define PALETTE_DEFAULT           YES
#define ALPHA_PREFKEY             @"TransparencyLevel"
#define ALPHA_DEFAULT             0.80
#define AOT_PREFKEY               @"AlwaysOnTop"
#define AOT_DEFAULT               YES
#define STICKY_PREFKEY            @"StickySpace"
#define STICKY_DEFAULT            NO
#define YIELD_PREFKEY             @"YieldFocus"
#define YIELD_DEFAULT             NO
#define COLUMNS_PREFKEY           @"WorkspaceColumns"
#define COLUMNS_DEFAULT           2
#define ROWS_PREFKEY              @"WorkspaceRows"
#define ROWS_DEFAULT              2
#define NAMES_PREFKEY             @"WorkspaceNames"

#define HOTKEY_PREFKEY            @"HotKeys"

#define HOTKEY_PREV_CODE          0x101
#define HOTKEY_PREV_PREFKEY       @"HotKey_0x101"
#define HOTKEY_PREV_FLAGS         (NSCommandKeyMask|NSControlKeyMask)
#define HOTKEY_PREV_DEFAULT       0x7b

#define HOTKEY_NEXT_CODE          0x102
#define HOTKEY_NEXT_PREFKEY       @"HotKey_0x102"
#define HOTKEY_NEXT_FLAGS         (NSCommandKeyMask|NSControlKeyMask)
#define HOTKEY_NEXT_DEFAULT       0x7c

#define HOTKEY_UP_CODE            0x103
#define HOTKEY_UP_PREFKEY         @"HotKey_0x103"
#define HOTKEY_UP_FLAGS           (NSCommandKeyMask|NSControlKeyMask)
#define HOTKEY_UP_DEFAULT         0x7e

#define HOTKEY_DOWN_CODE          0x104
#define HOTKEY_DOWN_PREFKEY       @"HotKey_0x104"
#define HOTKEY_DOWN_FLAGS         (NSCommandKeyMask|NSControlKeyMask)
#define HOTKEY_DOWN_DEFAULT       0x7d

#define NOTE_SPACES_ALTERED       @"Changed space characteristics"
#define NOTE_SPACE_NAME_CHANGE    @"Changed space names"
#define NOTE_SPACE_COUNT_CHANGE   @"Changed space count"
#define NOTE_SPACE_SWITCH         @"Changed space"
#define NOTE_SPACE_KEY_CHANGE     @"Changed hot key"

#endif