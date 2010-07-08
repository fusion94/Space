//
//  PrefsController.m
//  $Id: PrefsController.m,v 1.15 2002/06/04 16:06:57 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#include <Cocoa/Cocoa.h>

#import "PaletteController.h"
#import "PrefsController.h"
#import "SpaceApplication.h"
#include "space-defines.h"
#import "KeyGrabber.h"
#import "Space.h"
#import "keycode.h"
#import "PersistentHotKey.h"

// Fixme: L13N
#define SET_MSG @"Set"
#define UNSET_MSG @"Clear"
#define DISABLED_MSG @"(disabled)"
#define SETTING_MSG @"(setting)"

@interface PrefsController(private)
-(void)regulateSlidersForColumns: (int)columns andRows:(int) rows;
@end

@implementation PrefsController(private)
-(void)regulateSlidersForColumns: (int)columns andRows:(int) rows
{
    int maxColumns = MAX(MAX_SPACES/rows,MIN_SPACE_OPTIONS);
    int maxRows    = MAX(MAX_SPACES/columns,MIN_SPACE_OPTIONS);

    [prefsSliderColumn setMaxValue: maxColumns];
    [prefsSliderColumn setNumberOfTickMarks: maxColumns];
    [prefsSliderColumn setIntValue: columns];    

    [prefsSliderRow    setMaxValue: maxRows];    
    [prefsSliderRow    setNumberOfTickMarks: maxRows];
    [prefsSliderRow    setIntValue: rows];    

}
@end

@implementation PrefsController

static int keyGrabbingUID = 0;

- (void) awakeFromNib {

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(updateDrawerforKeys)
        name: NOTE_SPACE_KEY_CHANGE object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(updateDrawerforKeys)
        name: NOTE_SPACE_COUNT_CHANGE object:nil];

}

- (void) updateDrawerforKeys
{
    int i;
    HotKey *key;
    int thisCode;

    for (i=0; i<4; i++) {
        switch (i) {
            case 0:
                thisCode = HOTKEY_PREV_CODE;
                break;
            case 1:
                thisCode = HOTKEY_NEXT_CODE;    
                break;
            case 2:
                thisCode = HOTKEY_UP_CODE;    
                break;
            case 3:
                thisCode = HOTKEY_DOWN_CODE;    
                break;
        }
        
        key = [HotKey HotKeyForUID: thisCode];    
        
        if (key) {         
            NSMutableString *string = glyphsForModifierFlags([key getFlags]);
            [string appendString: 
                [NSString stringWithCString: charactersForKeyCode([key getKey])]];
            [[specialKeyFieldMatrix cellAtRow: i column: 0] setStringValue: string];
            [[specialKeyButtonMatrix cellAtRow: i column: 0] setTitle: UNSET_MSG];
        }
        else {
            [[specialKeyButtonMatrix cellAtRow: i column: 0] setTitle: SET_MSG];
            [[specialKeyFieldMatrix cellAtRow: i column: 0] setStringValue: DISABLED_MSG];
        }

        if (keyGrabbingUID) {
            if (thisCode == keyGrabbingUID)
                [[specialKeyButtonMatrix cellAtRow: i column: 0] setEnabled: YES];
            else
                [[specialKeyButtonMatrix cellAtRow: i column: 0] setEnabled: NO];
        }
        else [[specialKeyButtonMatrix cellAtRow: i column: 0] setEnabled: YES];

    }
}


- (void)prefsSyncShowPalette;
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    if ([sharedApp getAlwaysPalette]) {
        [prefsBoxAlwaysPalette setState: NSOnState]; 
        [prefsBoxShowPalette setEnabled: NO];     
    }
    else {
        [prefsBoxAlwaysPalette setState: NSOffState]; 
        [prefsBoxShowPalette setEnabled: YES];
    }

    if ([sharedApp getShowPalette]) {
        [prefsBoxShowPalette setState: NSOnState]; 

        [prefsBoxAlwaysPalette setEnabled: YES];
        [prefsBoxYieldFocus    setEnabled: YES];
        [prefsSliderColumn     setEnabled: YES];
        [prefsSliderRow        setEnabled: YES];     
        [prefsSliderAlpha      setEnabled: YES];
        [prefsBoxAOT           setEnabled: YES];
        [prefsBoxYieldFocus    setEnabled: YES];
    }
    else {
        [prefsBoxShowPalette setState: NSOffState]; 

        [prefsBoxAlwaysPalette setEnabled: NO];
        [prefsSliderColumn     setEnabled: NO];
        [prefsSliderRow        setEnabled: NO];     
        [prefsSliderAlpha      setEnabled: NO];
        [prefsBoxAOT           setEnabled: NO];
        [prefsBoxYieldFocus    setEnabled: NO];    
    }

}

-(IBAction)prefsPanelOpen:(id)sender 
{ 

    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    int columns = [sharedApp getSpaceColumns];
    int rows    = [sharedApp getSpaceRows   ];

    [prefsSliderColumn setIntValue: columns];        
    [prefsSliderRow    setIntValue: rows   ];
    [self regulateSlidersForColumns: columns andRows: rows];

    [prefsSliderAlpha setFloatValue: [sharedApp getAlpha]];

    [prefsBoxAOT setState:        ([sharedApp getAOT]        ? NSOnState : NSOffState)];    
    [prefsBoxSticky setState:     ([sharedApp getUseSticky]  ? NSOnState : NSOffState)];
    [prefsBoxYieldFocus setState: ([sharedApp getYieldFocus] ? NSOnState : NSOffState)];

    [self prefsSyncShowPalette];
    
    [prefsPanel setFrameAutosaveName: PREFS_WINDOW_SAVENAME]; 
    [prefsPanel makeKeyAndOrderFront:sender];
}

- (IBAction)prefsCountChange:(id)slider 
{
    int *changeAxis, *referenceAxis;
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    int spaceColumns = [sharedApp getSpaceColumns];
    int spaceRows    = [sharedApp getSpaceRows];

    switch ([slider tag]) {
        case HORIZONTAL_SPACE_TAG:
            changeAxis    = &spaceColumns;
            referenceAxis = &spaceRows;
            break;
        case VERTICAL_SPACE_TAG:
            changeAxis    = &spaceRows;
            referenceAxis = &spaceColumns;
            break;
    }    
    *changeAxis = [slider intValue];

    if ((spaceRows * spaceColumns) > MAX_SPACES) {
        *referenceAxis = (MAX_SPACES / *changeAxis);
    }
    else if ((spaceRows * spaceColumns) < MIN_SPACES) {
        *referenceAxis = (MIN_SPACES / *changeAxis);
    }

    [sharedApp setSpaceColumns: spaceColumns andSpaceRows: spaceRows];
    [self regulateSlidersForColumns: spaceColumns andRows: spaceRows];

    [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACE_COUNT_CHANGE object:nil];
} 

- (IBAction) prefsAlphaChange: (id)sender {
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    [sharedApp setPaletteAlpha: [sender floatValue]];
}

- (IBAction) prefsAlwaysPaletteChange: (id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    if ([sender state] == NSOnState) {
        [sharedApp setAlwaysPalette: YES]; // sync will take care of disabling
        [prefsBoxShowPalette setEnabled: NO];     
    }
    else {
        [sharedApp setAlwaysPalette: NO];
        [prefsBoxShowPalette setEnabled: YES];     
    }    
}

- (IBAction) prefsShowPaletteChange: (id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    PaletteController *pcontrol = [sharedApp getPaletteController];
    if ([sender state] == NSOnState) [pcontrol showPalette]; else [pcontrol hidePalette];
}

- (IBAction) prefsAOTChange: (id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    [sharedApp setAOT: (([sender state] == NSOnState) ? YES : NO)];
}

- (IBAction)prefsStickyChange:(id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    [sharedApp setUseSticky: (([sender state] == NSOnState) ? YES : NO)];
}

- (IBAction)prefsYieldFocusChange:(id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    [sharedApp setYieldFocus: (([sender state] == NSOnState) ? YES : NO)];
}

- (IBAction) prefsDrawerToggle: (id)sender
{
    if ([prefsDrawer state] == NSDrawerOpenState) {
        [prefsDrawer close];
    }
    else {
        [self updateDrawerforKeys];
        [prefsDrawer open];
    }
}

- (IBAction) prefsHotKeySet: (id)sender
{
    int buttonIndex      = [[sender selectedCell] tag];
    BOOL deactivate = NO;
    int newKeyGrabIndex = 0;

    switch (buttonIndex) {
        case 0:
            newKeyGrabIndex = HOTKEY_PREV_CODE;
            break;
        case 1:
            newKeyGrabIndex = HOTKEY_NEXT_CODE;
            break;                
        case 2:
            newKeyGrabIndex = HOTKEY_UP_CODE;
            break;
        case 3:
            newKeyGrabIndex = HOTKEY_DOWN_CODE;
            break;                
    }
    
    if (keyGrabbingUID == newKeyGrabIndex) { 
        deactivate = YES; 
    }
    else {
        HotKey *key = [HotKey HotKeyForUID: newKeyGrabIndex];
        if (key) {
            deactivate = YES;
        }       
    }
    
    if (keyGrabbingUID) [self abortKeyCapture];    
    keyGrabbingUID = newKeyGrabIndex;
      
    if (deactivate) {
    
        PersistentHotKey *key = [PersistentHotKey loadForUID: keyGrabbingUID];
        if (key) {
            [key setActive: NO];
            [key removeFromCGS];
            [key saveToDefaults];
        }
    
        [self abortKeyCapture];
        [[sender cellAtRow: buttonIndex column: 0] setTitle: SET_MSG];
        keyGrabbingUID = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACE_KEY_CHANGE object:nil];    
        [self updateDrawerforKeys];
    }
    else {
        [prefsKeyGrabber listen: YES];
        [[specialKeyFieldMatrix cellAtRow: buttonIndex column: 0] setStringValue: SETTING_MSG];
        [[sender selectedCell] setTitle: UNSET_MSG];
        [prefsPanel makeFirstResponder: prefsKeyGrabber];
    }
}

- (void) registerKey: (unsigned short)keyCode withMods: (unsigned int)modifier_flags;
{

    if (modifier_flags & NSFunctionKeyMask) { // strip mask for hotkey
        modifier_flags &= ~NSFunctionKeyMask;
    }

    {
        PersistentHotKey *key = 
            [[PersistentHotKey alloc] initWithUID: keyGrabbingUID
                            keycode: keyCode 
                            flags: modifier_flags];
        [key setActive: YES];
        [key saveToDefaults];
    }
    
    keyGrabbingUID = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName: NOTE_SPACE_KEY_CHANGE object:nil];    
    
    [self updateDrawerforKeys];

}

- (void) abortKeyCapture
{
    [prefsKeyGrabber listen: NO];
    keyGrabbingUID = 0;
    [self updateDrawerforKeys];
}

- (void)windowWillClose: (NSNotification*)aNotification
{
    [self abortKeyCapture];
    [prefsDrawer close];
}

- (void)drawerWillClose:(NSNotification *)notification
{
   [self abortKeyCapture];
}
@end
