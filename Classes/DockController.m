//
//  DockController.m
//  $Id: DockController.m,v 1.8 2002/06/04 01:33:09 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//
#import "DockController.h"
#import <Cocoa/Cocoa.h>

#include "space-defines.h"
#import "dock-menu.h"
#import "Space.h"
#import "SpaceApplication.h"

@implementation DockController

- (DockController*) init
{
    if(![super init]) return nil;

    menu            = nil; // consider constructing here?

    return self;
}
                               
- (NSMenu*) applicationDockMenu: (NSApplication*)sender
{
    int i;
    NSString   *label; 

    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    int spaceCount = [sharedApp getSpaceCount];
    int currentSpaceIndex = [sharedApp getCurrentSpaceIndex];

    NSMutableArray *space2procs = [Space processIndexForMenu];

    DEBUG_OUTF(@"Building menu for current space %d",
               currentSpaceIndex);

    if (menu) { [menu release]; }
    menu = newDockMenu(); 
    
    DEBUG_OUT(@"Composing menu");
    for (i = 1; i<=spaceCount; i++) {
        DEBUG_OUTF(@"Adding item for space %d", i);
        if (i == currentSpaceIndex) {
            label = [[NSBundle bundleWithIdentifier: SPACE_BUNDLE] 
                      localizedStringForKey:LABEL_CURRENT_SPACE 
                      value:LABEL_CURRENT_SPACE table:STRING_TABLE];

            DEBUG_OUTF(@"Current label: %@", label);
            
            addDockMenuItem (menu, label, i, 
                             NO, YES, 
                             @selector(switchTo), 
                             [Space getSpaceForIndex: i]);
        }
        else {
            NSMutableArray *proclist = [space2procs objectAtIndex: i];
            if ([proclist count] == 0) {
                label = [[NSBundle bundleWithIdentifier: SPACE_BUNDLE]
                          localizedStringForKey:LABEL_EMPTY_SPACE 
                          value:LABEL_EMPTY_SPACE table:STRING_TABLE];
            }
            else {
                label = [proclist componentsJoinedByString: @", "];
            }

            addDockMenuItem (menu, label, i,
                             YES, NO,
                             @selector(switchTo), 
                             [Space getSpaceForIndex: i]);
        }
    }

    DEBUG_OUT(@"Adding control items");    

    if (![sharedApp getAlwaysPalette]) {
        addDockMenuSeparator(menu);

        if ([sharedApp getShowPalette])
            addDockMenuItem (menu, HIDE_PALETTE_LABEL, HIDE_PALETTE_CODE, 
                         YES, NO,
                         @selector(hidePalette), 
                         [sharedApp getPaletteController]);
        else
            addDockMenuItem (menu, SHOW_PALETTE_LABEL, SHOW_PALETTE_CODE, 
                         YES, NO,
                         @selector(showPalette), 
                         [sharedApp getPaletteController]);
    }
    
    DEBUG_OUT(@"Menu complete");    
    return menu;
}

@end

