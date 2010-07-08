//
//  keycode.m
//  $Id: keycode.m,v 1.7 2002/06/04 01:33:11 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import "keycode.h"
#import <Cocoa/Cocoa.h>

const int keyTableCount = 90;

// Documentation says keycodes are hardware independent, 
// but I couldn't figure out how to do a runtime lookup.
// For want of a better idea, I hope my iBook's keyboard codes
// will work elsewhere!

const keyDecoder keyTable[] =
{
    {0x0,		"a",		"A"	},
    {0x1,		"s",		"S"	},
    {0x2,		"d",		"D"	},
    {0x3,		"f",		"F"	},
    {0x4,		"h",		"H"	},
    {0x5,		"g",		"G"	},
    {0x6,		"z",		"Z"	},
    {0x7,		"x",		"X"	},
    {0x8,		"c",		"C"	},
    {0x9,		"v",		"V"	},
    {0xb,		"b",		"B"	},
    {0xc,		"q",		"Q"	},
    {0xd,		"w",		"W"	},
    {0xe,		"e",		"E"	},
    {0xf,		"r",		"R"	},
    {0x10,		"y",		"Y"	},
    {0x11,		"t",		"T"	},
    {0x12,		"1",		"!"	},
    {0x13,		"2",		"@"	},
    {0x14,		"3",		"#"	},
    {0x15,		"4",		"$"	},
    {0x16,		"6",		"^"	},
    {0x17,		"5",		"%"	},
    {0x18,		"=",		"+"	},
    {0x19,		"9",		"("	},
    {0x1a,		"7",		"&"	},
    {0x1b,		"-",		"_"	},
    {0x1c,		"8",		"*"	},
    {0x1d,		"0",		")"	},
    {0x1e,		"]",		"}"	},
    {0x1f,		"o",		"O"	},
    {0x20,		"u",		"U"	},
    {0x21,		"[",		"{"	},
    {0x22,		"i",		"I"	},
    {0x23,		"p",		"P"	},
    {0x24,		"return",	""	},
    {0x25,		"l",		"L"	},
    {0x26,		"j",		"J"	},
    {0x27,		"'",		"\""	},
    {0x28,		"k",		"K"	},
    {0x29,		";",		":"	},
    {0x2a,		"\\",		"|"	},
    {0x2b,		",",		"<"	},
    {0x2c,		"/",		"?"	},
    {0x2d,		"n",		"N"	},
    {0x2e,		"m",		"M"	},
    {0x2f,		".",		">"	},
    {0x30,		"tab",		""	},
    {0x31,		"space",	""	},
    {0x32,		"`",		"~"	},
    {0x33,		"delete",	""	},
    {0x34,		"enter",	""	},
    {0x35,		"esc",		""	},
    {0x41,		"KPD .",	""	},
    {0x43,		"KPD *",	""	},
    {0x45,		"KPD +",	""	},
    {0x47,		"clear",	""	},
    {0x4b,		"KPD /",	""	},
    {0x4e,		"KPD -",	""	},
    {0x51,		"KPD =",	""	},
    {0x52,		"KPD 0",	""	},
    {0x53,		"KPD 1",	""	},
    {0x54,		"KPD 2",	""	},
    {0x55,		"KPD 3",	""	},
    {0x56,		"KPD 4",	""	},
    {0x57,		"KPD 5",	""	},
    {0x58,		"KPD 6",	""	},
    {0x59,		"KPD 7",	""	},
    {0x5b,		"KPD 8",	""	},
    {0x5c,		"KPD 9",	""	},
    {0x60,		"f5",		""	},
    {0x61,		"f6",		""	},
    {0x62,		"f7",		""	},
    {0x63,		"f3",		""	},
    {0x64,		"f8",		""	},
    {0x65,		"f9",		""	},
    {0x67,		"f11",		""	},
    {0x6d,		"f10",		""	},
    {0x6f,		"f12",		""	},
    {0x73,		"home",		""	},
    {0x74,		"pgup",		""	},
    {0x76,		"f4",		""	},
    {0x77,		"end",		""	},
    {0x78,		"f2",		""	},
    {0x79,		"pgdn",		""	},
    {0x7a,		"f1",		""	},
    {0x7b,		"left",		""	},
    {0x7c,		"right",	""	},
    {0x7d,		"down",		""	},
    {0x7e,		"up",		""	}
};

const char *charactersForKeyCode (unsigned short keycode) {
    int   i;
    const char *retval = "";

    for (i=0; i<keyTableCount; i++) {
        if (keyTable[i].keycode == keycode) {
            retval = keyTable[i].name;
            break;
        }        
    }
    return retval;
}

const char *charactersForShiftedKeyCode (unsigned short keycode) {
    int   i;
    const char *retval = "";
    for (i=0; i<keyTableCount; i++) {
        if (keyTable[i].keycode == keycode) {
            retval = keyTable[i].shiftName;
            break;
        }        
    }
    return retval;
}

NSMutableString *glyphsForModifierFlags (unsigned int flags) {

    unichar buf[2] = {0,0};
    NSMutableString *muteString = [[NSMutableString alloc] init];

    if (flags & NSShiftKeyMask) {
        buf[0] = ShiftKeyGlyph;
        [muteString appendString: [NSString stringWithCharacters: buf length: 1]];
    }
    if (flags & NSControlKeyMask) {
        [muteString appendString: @"^"]; // is there an "official" char for this?
    }
    if (flags & NSAlternateKeyMask) {
        buf[0] = OptionKeyGlyph;
        [muteString appendString: [NSString stringWithCharacters: buf length: 1]];
    }
    if (flags & NSCommandKeyMask) {
        buf[0] = CommandKeyGlyph;
        [muteString appendString: [NSString stringWithCharacters: buf length: 1]];    
    }

    return muteString;
}


BOOL isFunctionKey (unsigned short keycode) {
    switch (keycode) {
        case 0x60:
        case 0x61:
        case 0x62:
        case 0x63:
        case 0x64:
        case 0x65:
        case 0x67:
        case 0x6d:
        case 0x6f:
        case 0x76:
        case 0x78:
        case 0x7a:
            return YES;
            break;
    }
       
    return NO;
}


// filter out these?
//        NSAlphaShiftKeyMask
//        NSNumericPadKeyMask =           1 << 21,
//        NSHelpKeyMask =                 1 << 22,
//        NSFunctionKeyMask =             1 << 23

