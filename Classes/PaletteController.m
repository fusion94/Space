//
//  PaletteController.m
//  $Id: PaletteController.m,v 1.19 2002/06/04 16:06:57 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>
#import "PaletteController.h"
//#import "SpaceController.h"
#import "SpaceApplication.h"
#import "PrefsController.h"
#import "Space.h"
#include "space-defines.h"

// From Frederic Stark's transparency example
extern int _NSSetWindowAlpha( int, float ); // is there a "legit" way to do this now?

@interface PaletteController (Private)
- (void) makeSpaceButtons;
- (void) resetSpaceWindowSize;           
@end

@implementation PaletteController (Private)

-(void) makeSpaceButtons 
{

    NSMatrix        *matrix;
    NSButtonCell    *button;

    int row, column;
    
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    int spaceRows    = [sharedApp getSpaceRows];
    int spaceColumns = [sharedApp getSpaceColumns];

    DEBUG_OUTF(@"Making %d buttons", (spaceRows * spaceColumns));
    
    button = [[NSButtonCell alloc] init];  // button prototype
    [button setButtonType: NSOnOffButton];
    [button setBezelStyle: NSRegularSquareBezelStyle];
    [button setBordered:   YES];
    [button setEnabled:    YES];

    matrix = [[NSMatrix alloc]
                  initWithFrame: [[spaceWindow contentView] frame]
                           mode: NSRadioModeMatrix
                      prototype: button
                   numberOfRows: spaceRows
                numberOfColumns: spaceColumns];
    [button release]; // done with prototype

    for (row = 0; row < spaceRows; row++) {
        for (column = 0; column < spaceColumns; column++) {
            int tag =  ((row * spaceColumns) + column + 1); // spaces start with 1
            Space *thisSpace = [Space getSpaceForIndex: tag];
            
            button = [matrix cellAtRow: row column: column];
            [button setTag: tag];            

            if ([sharedApp getCurrentSpaceIndex] == tag)
                [matrix setState: NSOnState atRow: row column: column];            

            if ([sharedApp getUseSticky] && (tag == (spaceRows * spaceColumns))) {
                [thisSpace setSticky: YES];
                [button setTitle: STICKY_TITLE];
            }
            else {
                [thisSpace setSticky: NO];
                [button setTitle: [thisSpace getName]];
            }            
        }
    }
    

    [matrix setAutosizesCells: YES];
    [matrix sizeToCells];
    [matrix setNeedsDisplay];
    [matrix autorelease];
    
    {
        NSMatrix *oldButtonSet = buttonSet;
        buttonSet = [matrix retain];
        [buttonSet setTarget: self];
        [buttonSet setAction: @selector(spaceButtonClick:)];
        [buttonSet setDoubleAction: @selector(spaceButtonDoubleClick:)];
        [oldButtonSet release];        
    }
    
    [self resetSpaceWindowSize];
    [spaceWindow setContentView: buttonSet];

}

- (void)resetSpaceWindowSize
{
    float minWidth, minHeight, maxWidth, maxHeight;

    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    
    int spaceRows    = [sharedApp getSpaceRows];
    int spaceColumns = [sharedApp getSpaceColumns];

    NSSize contentsize = [[spaceWindow contentView] bounds].size;
           
    minWidth =    (spaceColumns * MIN_WIDTH_SPACE);
    minHeight  = ((spaceRows    * MIN_HEIGHT_SPACE) + TITLE_BAR_SHIM);
    maxWidth   = (spaceColumns  * MAX_WIDTH_SPACE);
    maxHeight  = ((spaceRows    * MAX_HEIGHT_SPACE) + TITLE_BAR_SHIM);
    
    if (contentsize.width > maxWidth)
        contentsize.width = maxWidth;
    else if (contentsize.width < minWidth)
        contentsize.width = minWidth;
        
    if (contentsize.height > maxHeight)
        contentsize.height = maxHeight;
    else if (contentsize.height < minHeight)
        contentsize.height = minHeight;

    [spaceWindow setContentSize: contentsize];
    [spaceWindow setMinSize: NSMakeSize(minWidth, minHeight)];
    [spaceWindow setMaxSize: NSMakeSize(maxWidth, maxHeight)];
}

@end

@implementation PaletteController

// static global
static NSRect _DefaultSpaceWindowRect = {{100, 100}, {150, 150}};

- (PaletteController*) init
{
    if(![super init]) return nil;

    spaceWindow = [[NSWindow alloc]
                   initWithContentRect: _DefaultSpaceWindowRect
                             styleMask: BB_STYLE_MASK
                               backing: NSBackingStoreBuffered
                                 defer: YES];
    [spaceWindow setReleasedWhenClosed: NO];
    [spaceWindow setDelegate: self];
    [spaceWindow setTitle: BB_TITLE];
    
    [self redraw]; // initialize buttonSet

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(redraw)
        name: NOTE_SPACES_ALTERED object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(updateSelectedSpace:)
        name: NOTE_SPACE_SWITCH object:nil];

    return self;
}

- (void) updateSelectedSpace: (id) nothing
{

    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    if ([sharedApp getShowPalette]) {

        int spaceIndex   = [sharedApp getCurrentSpaceIndex];
        int spaceColumns = [sharedApp getSpaceColumns];
        int x = ((spaceIndex - 1) % spaceColumns);
        int y = ((spaceIndex - 1) / spaceColumns);
    
        [self activateAtColumn: x andRow: y];
    }
}

// reverse rows/columns for consistency
- (void) activateAtColumn: (int)spaceColumn andRow: (int)spaceRow
{
    [buttonSet setState: NSOnState 
                  atRow: spaceRow 
                 column: spaceColumn];
}

- (void) showPalette
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    DEBUG_OUT(@"Showing palette");
    [self updateSpaceWindowAOT]; // you can set the layer before window is visible...
    [spaceWindow setFrameAutosaveName: SPACE_WINDOW_SAVENAME]; 
    [spaceWindow makeKeyAndOrderFront:self]; // still needed ?
    [self updateSpaceWindowAlpha]; // ...but not the alpha
    [sharedApp setShowPalette: YES];
    [[sharedApp getPrefsController] prefsSyncShowPalette];
}

- (void) hidePalette
{
    DEBUG_OUT(@"Hiding palette");
    [spaceWindow performClose: self]; // windowWillClose handles prefs, prefssync
}

-(void) redraw
{
    [self makeSpaceButtons];
    [self updateSpaceWindowAlpha]; // what if not visible???
    [self updateSpaceWindowAOT];
}

-(void)updateSpaceWindowAlpha
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    float alpha = [sharedApp getAlpha];

    if ((alpha < 0) || (alpha > 1)) {
        [sharedApp setPaletteAlpha: ALPHA_DEFAULT];
        alpha = ALPHA_DEFAULT; //fix assign
    }
    
    _NSSetWindowAlpha([spaceWindow windowNumber], alpha);
}

-(void)updateSpaceWindowAOT
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    if ([sharedApp getAOT])
        [spaceWindow setLevel: NSFloatingWindowLevel];
    else
        [spaceWindow setLevel: NSNormalWindowLevel];
}



///////////////////////////////////////////////////////////////////////
// Actions ////////////////////////////////////////////////////////////

- (IBAction)spaceButtonClick:(id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];
    [sharedApp switchToSpace: [[sender selectedCell] tag]];
}

- (IBAction)spaceButtonDoubleClick:(id)sender
{
    NSButtonCell *cell = [sender selectedCell];
    if ([cell state] == NSOnState &&
        (! [[Space getSpaceForIndex: [cell tag]] isSticky])) {

        [sender setEnabled: NO];
        [cell setEnabled:   YES];
        [cell setEditable:  YES];
        [cell performClick: sender];
        [[sender currentEditor] setDelegate:self];
    }
}


///////////////////////////////////////////////////////////////////////
// Delegate methods -- not in header //////////////////////////////////

- (void)windowWillClose:(id)sender
{
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    if ([sharedApp getAlwaysPalette]) {
        [sharedApp terminate:self];
    }
    else {
        [sharedApp setShowPalette: NO];
        [[sharedApp getPrefsController] prefsSyncShowPalette];    
    }
} 

- (void)textDidEndEditing:(NSNotification *)aNotification
{  // this approach needed since loss of focus discards editor text in default handler
    
    NSButtonCell *cell    = [buttonSet selectedCell];
    NSString     *newName = [[aNotification object] string]; // NSText editor

    DEBUG_OUT(@"Editing ended");

    [cell setEditable: NO];
    [buttonSet setEnabled: YES];
    [cell setTitle: newName];
    [cell setState: NSOnState];

    [[Space getSpaceForIndex: [cell tag]] setName: newName];
    [spaceWindow endEditingFor: buttonSet];
} 

@end
