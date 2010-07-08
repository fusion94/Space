//
//  dock-menu.m
//  $Id: dock-menu.m,v 1.6 2002/06/04 01:33:11 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#include <Cocoa/Cocoa.h>
#include "dock-menu.h"
#include "space-defines.h"

DockMenuRef newDockMenu() { 
    NSMenu* newMenu = [[NSMenu alloc] init];
    [newMenu setAutoenablesItems: NO];
    return newMenu;
}

void addDockMenuItem  (DockMenuRef menu, NSString *name, int tag, 
                       BOOL enableP, BOOL markP, SEL action, id target) {

    NSMenuItem *menuItem = 
        [[NSMenuItem alloc] initWithTitle: name action: action
                            keyEquivalent:@""];

    [menuItem setTag: tag];
    [menuItem setEnabled: enableP];
    [menuItem setState:  (markP ? NSOnState : NSOffState)];
    [menuItem setTarget: target];    

    [menu addItem: menuItem];
}

void addDockMenuSeparator (DockMenuRef menu) {
    [menu addItem: [NSMenuItem separatorItem]];
}
