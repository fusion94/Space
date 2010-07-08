//
//  SpaceApplication.m
//  $Id: SpaceApplication.m,v 1.15 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>
#include <Carbon/Carbon.h>

#include "space-defines.h"
#import "SpaceApplication.h"
#import "HotKeyApplication.h"
#import "PersistentHotKey.h"
#import "Space.h"
#import  "PaletteController.h"
#import  "DockController.h"
#import  "PrefsController.h"

@implementation SpaceApplication

+(SpaceApplication*) sharedApplication
{
    return (SpaceApplication*) [super sharedApplication]; // Is this evil?
}

+ (void)initialize { 
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];    

    NSDictionary *appDefaults = 
        [NSDictionary dictionaryWithObjectsAndKeys:

            [NSNumber numberWithBool:  ALWAYS_DEFAULT  ], ALWAYS_PREFKEY,
            [NSNumber numberWithBool:  PALETTE_DEFAULT ], PALETTE_PREFKEY,
            [NSNumber numberWithFloat: ALPHA_DEFAULT   ], ALPHA_PREFKEY, 
            [NSNumber numberWithBool:  AOT_DEFAULT     ], AOT_PREFKEY,
            [NSNumber numberWithBool:  STICKY_DEFAULT  ], STICKY_PREFKEY,
            [NSNumber numberWithInt:   COLUMNS_DEFAULT ], COLUMNS_PREFKEY,
            [NSNumber numberWithInt:   ROWS_DEFAULT    ], ROWS_PREFKEY,
            [NSNumber numberWithInt:   COUNT_DEFAULT   ], COUNT_PREFKEY,     

            [NSArray arrayWithObjects: 
              @"0",
              @"1",  @"2",       
              @"3",  @"4",      
              @"5",  @"6",       
              @"7",  @"8",     
              @"9", @"10",       
             @"11", @"12",    
             @"13", @"14",  
             @"15", @"16",
             nil],                                       NAMES_PREFKEY,            

            [NSDictionary dictionaryWithObjectsAndKeys:
            
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: HOTKEY_NEXT_CODE],     HOTKEY_UID_PREFKEY,
                    [NSNumber numberWithBool: YES],                 HOTKEY_ACTIVE_PREFKEY,
                    [NSNumber numberWithInt:  HOTKEY_NEXT_DEFAULT], HOTKEY_KEYS_PREFKEY,
                    [NSNumber numberWithInt:  HOTKEY_NEXT_FLAGS],   HOTKEY_FLAGS_PREFKEY,
                    nil], HOTKEY_NEXT_PREFKEY,
                
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: HOTKEY_PREV_CODE],    HOTKEY_UID_PREFKEY,
                    [NSNumber numberWithBool: YES],                HOTKEY_ACTIVE_PREFKEY,
                    [NSNumber numberWithInt: HOTKEY_PREV_DEFAULT], HOTKEY_KEYS_PREFKEY,
                    [NSNumber numberWithInt: HOTKEY_PREV_FLAGS],   HOTKEY_FLAGS_PREFKEY,
                    nil], HOTKEY_PREV_PREFKEY,

                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: HOTKEY_UP_CODE],      HOTKEY_UID_PREFKEY,
                    [NSNumber numberWithBool: YES],                HOTKEY_ACTIVE_PREFKEY,
                    [NSNumber numberWithInt:  HOTKEY_UP_DEFAULT],  HOTKEY_KEYS_PREFKEY,
                    [NSNumber numberWithInt:  HOTKEY_UP_FLAGS],    HOTKEY_FLAGS_PREFKEY,
                    nil], HOTKEY_UP_PREFKEY,
                
                [NSDictionary dictionaryWithObjectsAndKeys:
                    [NSNumber numberWithInt: HOTKEY_DOWN_CODE],    HOTKEY_UID_PREFKEY,
                    [NSNumber numberWithBool: YES],                HOTKEY_ACTIVE_PREFKEY,
                    [NSNumber numberWithInt: HOTKEY_DOWN_DEFAULT], HOTKEY_KEYS_PREFKEY,
                    [NSNumber numberWithInt: HOTKEY_DOWN_FLAGS],   HOTKEY_FLAGS_PREFKEY,
                    nil], HOTKEY_DOWN_PREFKEY,

                nil], HOTKEY_DICT_PREFKEY,
            
            nil]; 
            
    [defaults registerDefaults:appDefaults];

    // Legacy prefs may still be good for something.
    CFPreferencesAddSuitePreferencesToApp(kCFPreferencesCurrentApplication, LEGACY_BUNDLE);
}

- init
{
    if(![super init]) return nil;

    alwaysPalette = [[NSUserDefaults standardUserDefaults]    boolForKey: ALWAYS_PREFKEY  ];
    showPalette   = [[NSUserDefaults standardUserDefaults]    boolForKey: PALETTE_PREFKEY ];
        
    spaceColumns  = [[NSUserDefaults standardUserDefaults] integerForKey: COLUMNS_PREFKEY ];
    spaceRows     = [[NSUserDefaults standardUserDefaults] integerForKey: ROWS_PREFKEY    ];
    
    alpha         = [[NSUserDefaults standardUserDefaults]   floatForKey: ALPHA_PREFKEY   ];
    AOT           = [[NSUserDefaults standardUserDefaults]    boolForKey: AOT_PREFKEY     ];
    yieldFocus    = [[NSUserDefaults standardUserDefaults]    boolForKey: YIELD_PREFKEY   ];

    useSticky     = [[NSUserDefaults standardUserDefaults]    boolForKey: STICKY_PREFKEY  ];

    paletteController = nil; // dependent on this object being fully init'd

    currentSpaceIndex = SPACE_INDEX_FIRST_SPACE;

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(updateHotKeys)
        name: NOTE_SPACE_KEY_CHANGE object:nil];

    return self;
}

- (void)awakeFromNib
{
    Space* firstSpace = nil; 

    [Space letThereBeSpace];
    firstSpace = [Space getSpaceForIndex: currentSpaceIndex];
    [firstSpace scan];

    paletteController = [[PaletteController alloc] init];
    if (showPalette) [paletteController showPalette];

    [self updateHotKeys];
}

- (void) updateHotKeys
{
    PersistentHotKey *prefsHotKey   = [PersistentHotKey loadForUID: HOTKEY_PREV_CODE]; 
    HotKey *cgsHotKey = [HotKey HotKeyForUID: HOTKEY_PREV_CODE];
    if (cgsHotKey != nil) [cgsHotKey removeFromCGS];
    if (prefsHotKey != nil) { if ([prefsHotKey isActive]) [prefsHotKey registerWithCGS]; }

    prefsHotKey   = [PersistentHotKey loadForUID: HOTKEY_NEXT_CODE]; 
    cgsHotKey = [HotKey HotKeyForUID: HOTKEY_NEXT_CODE];
    if (cgsHotKey != nil) [cgsHotKey removeFromCGS];
    if (prefsHotKey != nil) { if ([prefsHotKey isActive]) [prefsHotKey registerWithCGS]; }

    prefsHotKey   = [PersistentHotKey loadForUID: HOTKEY_UP_CODE]; 
    cgsHotKey = [HotKey HotKeyForUID: HOTKEY_UP_CODE];
    if (cgsHotKey != nil) [cgsHotKey removeFromCGS];
    if (prefsHotKey != nil) { if ([prefsHotKey isActive]) [prefsHotKey registerWithCGS]; }

    prefsHotKey   = [PersistentHotKey loadForUID: HOTKEY_DOWN_CODE]; 
    cgsHotKey = [HotKey HotKeyForUID: HOTKEY_DOWN_CODE];
    if (cgsHotKey != nil) [cgsHotKey removeFromCGS];
    if (prefsHotKey != nil) { if ([prefsHotKey isActive]) [prefsHotKey registerWithCGS]; }
}

- (void) handleHotKeyEvent: (NSEvent*)anEvent {

   unsigned short keycode = [anEvent data1];
    if (keycode == HOTKEY_PREV_CODE) {
        [self switchToPreviousSpace];    
    }
    else if (keycode == HOTKEY_NEXT_CODE) {
        [self switchToNextSpace];        
    }
    else if (keycode == HOTKEY_UP_CODE) {
        [self switchToAboveSpace];        
    }
    else if (keycode == HOTKEY_DOWN_CODE) {
        [self switchToBelowSpace];        
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super applicationWillTerminate: aNotification];
}

-(void)switchToSpaceForColumn:(int)column andRow:(int)row
{
    int newIndex = ((row * spaceColumns) + column + 1);
    [self switchToSpace: newIndex];    
}

-(void)switchToNextSpace
{
    if (currentSpaceIndex < (spaceColumns * spaceRows)) {
        [self switchToSpace: (currentSpaceIndex + 1)]; 
    }
    else [self switchToSpace: 1];
}

-(void)switchToPreviousSpace
{
    if (currentSpaceIndex > 1) {
        [self switchToSpace: (currentSpaceIndex - 1)]; 
    }
    else [self switchToSpace: (spaceColumns * spaceRows)];
}

-(void)switchToAboveSpace
{
    int newIndex;
    if ((currentSpaceIndex - spaceColumns) >=  1) {
        newIndex = (currentSpaceIndex - spaceColumns); 
    }
    else newIndex = (currentSpaceIndex - spaceColumns) + (spaceColumns * spaceRows);        
    [self switchToSpace: newIndex];    
}

-(void)switchToBelowSpace
{   
    int newIndex;
    if ((currentSpaceIndex + spaceColumns) <=  (spaceColumns * spaceRows)) {
        newIndex = (currentSpaceIndex + spaceColumns); 
    }
    else newIndex = (currentSpaceIndex + spaceColumns) - (spaceColumns * spaceRows);        
    [self switchToSpace: newIndex];    
}

-(void)switchToSpace:(int)index
{
    if (index != currentSpaceIndex) {
        Space *newSpace = nil;
        if ((newSpace = [Space getSpaceForIndex: index]) != nil) {
            Space *thisSpace;
            DEBUG_OUTF(@"Switching to space %d",index);

            thisSpace = [Space getSpaceForIndex: currentSpaceIndex];
            [thisSpace hide];
            
            currentSpaceIndex = index;  
            [newSpace show: (yieldFocus ? YES: NO)];                    
        }

        [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACE_SWITCH object:nil];    
    }
}

// Accessors

- (void) setPaletteAlpha: (float)newAlpha
{
    alpha = newAlpha;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithFloat: alpha]
        forKey:    ALPHA_PREFKEY];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACES_ALTERED object:nil];
}

- (void) setAOT: (BOOL)newAOT
{
    AOT = newAOT;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithBool: AOT]
        forKey:    AOT_PREFKEY];
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACES_ALTERED object:nil];
}

- (void) setYieldFocus: (BOOL)newYieldFocus
{
    yieldFocus = newYieldFocus;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithBool: yieldFocus]
        forKey:    YIELD_PREFKEY];
}

- (void) setSpaceColumns: (int)newSpaceColumns andSpaceRows: (int)newSpaceRows
{

    BOOL aspectChanged = NO;

    aspectChanged |= (spaceColumns != newSpaceColumns);
    aspectChanged |= (spaceRows    != newSpaceRows);
        
    spaceColumns = newSpaceColumns;
    spaceRows    = newSpaceRows;

    if (showPalette && aspectChanged) [paletteController redraw]; // todo: or let notification do this?

    if (currentSpaceIndex > (spaceColumns * spaceRows)) 
        [self switchToSpace: (spaceColumns * spaceRows)];

    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithInt: spaceColumns]
        forKey:    COLUMNS_PREFKEY];
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithInt: spaceRows]
        forKey:    ROWS_PREFKEY];    

}

- (void) setUseSticky: (BOOL)newUseSticky
{
    useSticky = newUseSticky;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithBool: useSticky]
        forKey:    STICKY_PREFKEY];    
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACES_ALTERED object:nil];
}

- (void) setAlwaysPalette: (BOOL)onOff
{
    alwaysPalette = onOff;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithBool: alwaysPalette]
        forKey:    ALWAYS_PREFKEY];
}

- (void) setShowPalette: (BOOL)onOff
{
    showPalette = onOff;
    [[NSUserDefaults standardUserDefaults] 
        setObject: [NSNumber numberWithBool: showPalette]
        forKey:    PALETTE_PREFKEY];
}

- (int)                getSpaceCount        { return spaceColumns * spaceRows; }

- (float)              getAlpha             { return alpha;                    }
- (BOOL)               getAOT               { return AOT;                      }
- (BOOL)               getYieldFocus        { return yieldFocus;               }
- (int)                getSpaceColumns      { return spaceColumns;             }
- (int)                getSpaceRows         { return spaceRows;                }
- (BOOL)               getUseSticky         { return useSticky;                }
- (BOOL)               getAlwaysPalette     { return alwaysPalette;            }
- (int)                getCurrentSpaceIndex { return currentSpaceIndex;        }
- (BOOL)               getShowPalette       { return showPalette;              }
- (PaletteController*) getPaletteController { return paletteController;        }
- (DockController*)    getDockController    { return dockController;           }
- (PrefsController*)   getPrefsController   { return prefsController;          }

@end



