//
//  HotKey.m
//  $Id: HotKeyApplication.h,v 1.3 2002/06/04 01:33:09 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>

// subtype
extern const short NSHotKeyEventType; // 0x9;

@interface HotKeyApplication : NSApplication

- (void) sendEvent:         (NSEvent*)anEvent;
- (void) handleHotKeyEvent: (NSEvent*)anEvent; // subclass and customize handler

@end

