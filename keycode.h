//
//  keycode.h
//  $Id: keycode.h,v 1.5 2002/06/04 01:33:11 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>

#define CommandKeyGlyph 0x2318
#define ShiftKeyGlyph   0x21e7
#define OptionKeyGlyph  0x2325

typedef struct {
    unsigned short  keycode;
    const char     *name;
    const char     *shiftName;
} keyDecoder;

extern const int        keyTableCount;
extern const keyDecoder keyTable[];

BOOL isFunctionKey (unsigned short keycode);

const char *charactersForKeyCode (unsigned short keycode);
const char *charactersForShiftedKeyCode (unsigned short keycode);

NSMutableString *glyphsForModifierFlags (unsigned int flags);