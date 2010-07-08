//
//  SpaceApplication.h
//  $Id: SpaceApplication.h,v 1.8 2002/06/01 10:16:06 riley Exp $
//
//  copyright Riley Lynch, May 20002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>
#import "HotKeyApplication.h"
#include "space-defines.h"

@class PaletteController, DockController, PrefsController;

@interface SpaceApplication : HotKeyApplication 
{

    // palette preferences
    BOOL                 alwaysPalette;
    BOOL                 showPalette;
    float                alpha;
    BOOL                 AOT;              // always on top
    BOOL                 yieldFocus;
    
    // cross-app preferences
    int                  spaceColumns;
    int                  spaceRows;
    BOOL                 useSticky;   

    // outlet
    IBOutlet PrefsController*     prefsController;
    IBOutlet DockController*      dockController;

    // pseudo-outlets filled in by init
    PaletteController*   paletteController;

    // state
    int                  currentSpaceIndex;
        
}

+(SpaceApplication*) sharedApplication;

- (void) handleHotKeyEvent: (NSEvent*)anEvent;
- (void) updateHotKeys;

- (int)       getCurrentSpaceIndex;
- (void)      switchToSpace:          (int)       tag;
- (void)      switchToSpaceForColumn:(int)column andRow:(int)row;

- (void)      switchToNextSpace;
- (void)      switchToPreviousSpace;
- (void)      switchToAboveSpace;
- (void)      switchToBelowSpace;

- (float)     getAlpha;
- (BOOL)      getAOT;
- (BOOL)      getYieldFocus;
- (BOOL)      getUseSticky;   
- (void)      setPaletteAlpha:(float) newAlpha;
- (void)      setAOT:         (BOOL)  newAOT;
- (void)      setYieldFocus:  (BOOL)  newYieldFocus;
- (void)      setUseSticky:   (BOOL)  newUseSticky;

- (int)       getSpaceColumns;
- (int)       getSpaceRows;
- (int)       getSpaceCount;
- (void)      setSpaceColumns: (int)newSpaceColumns andSpaceRows: (int)newSpaceRows;

- (BOOL)      getAlwaysPalette;
- (void)      setAlwaysPalette: (BOOL)onOff;
- (BOOL)      getShowPalette;
- (void)      setShowPalette: (BOOL)onOff;

- (PaletteController*)  getPaletteController;
- (DockController*)     getDockController;
- (PrefsController*)    getPrefsController;

@end
