//
//  dock-menu.h
//  $Id: dock-menu.h,v 1.11 2002/06/04 01:33:11 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#ifndef __DOCK_MENU__
#define __DOCK_MENU__

#include <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>

typedef NSMenu*     DockMenuRef;

DockMenuRef     newDockMenu();
void            addDockMenuItem (DockMenuRef menu, NSString *name, 
                                int tag, BOOL enableP, BOOL markP, SEL action, id target);
void            addDockMenuSeparator (DockMenuRef menu);

#endif