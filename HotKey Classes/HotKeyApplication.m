//
//  HotKeyApplication.m
//  $Id: HotKeyApplication.m,v 1.6 2002/06/04 01:33:09 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>
#import "HotKeyApplication.h"

// undocumented API
const short NSHotKeyEventType = 0x9; 

@implementation HotKeyApplication

- (void)sendEvent: (NSEvent*)anEvent
{
    
    if ([anEvent type] == NSSystemDefined) {
        if ([anEvent subtype] == NSHotKeyEventType) {            
            [self handleHotKeyEvent: anEvent];
        }
    }
    [super sendEvent: anEvent];
}

- (void) handleHotKeyEvent: (NSEvent*)anEvent
{
// write for subclass
}

@end
