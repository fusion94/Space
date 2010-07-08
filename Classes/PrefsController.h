//
//  PrefsController.h
//  $Id: PrefsController.h,v 1.10 2002/06/04 06:56:31 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>

#define HORIZONTAL_SPACE_TAG 0
#define VERTICAL_SPACE_TAG   1

@class KeyGrabber, SpaceApplication;

@interface PrefsController : NSWindowController
{

    IBOutlet NSWindow   *prefsPanel;
    IBOutlet NSDrawer   *prefsDrawer;
    IBOutlet KeyGrabber *prefsKeyGrabber;

    IBOutlet NSButton *prefsBoxAlwaysPalette;
    IBOutlet NSButton *prefsBoxAOT;
    IBOutlet NSButton *prefsBoxShowPalette;
    IBOutlet NSButton *prefsBoxSticky;
    IBOutlet NSButton *prefsBoxYieldFocus;

    IBOutlet NSSlider *prefsSliderAlpha;
    IBOutlet NSSlider *prefsSliderColumn;
    IBOutlet NSSlider *prefsSliderRow;

    IBOutlet NSMatrix *specialKeyButtonMatrix;
    IBOutlet NSMatrix *specialKeyFieldMatrix;
}

- (void)     prefsSyncShowPalette;

- (IBAction) prefsPanelOpen:           (id)sender;
- (IBAction) prefsCountChange:         (id)sender;
- (IBAction) prefsAlphaChange:         (id)sender;
- (IBAction) prefsShowPaletteChange:   (id)sender;
- (IBAction) prefsAlwaysPaletteChange: (id)sender;
- (IBAction) prefsAOTChange:           (id)sender;
- (IBAction) prefsStickyChange:        (id)sender;
- (IBAction) prefsYieldFocusChange:    (id)sender;

- (IBAction) prefsDrawerToggle:        (id)sender;
- (IBAction) prefsHotKeySet:           (id)sender;


- (void) registerKey: (unsigned short)keyCode withMods: (unsigned int)modifier_flags;
- (void) abortKeyCapture;


@end
