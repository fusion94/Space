//
//  DockController.h
//  $Id: DockController.h,v 1.5 2002/06/04 06:56:31 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Foundation/Foundation.h>

// menu codes
#define STICKY_SPACE_CODE 2003
#define SHOW_PALETTE_CODE 2004
#define HIDE_PALETTE_CODE 2005

@class NSApplication, NSMenu, NSMenuItem;

@interface DockController : NSObject {
    NSMenu*              menu;
}

- (NSMenu*)         applicationDockMenu:     (NSApplication *)  sender;

@end
