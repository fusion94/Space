//
//  KeyGrabber.h
//  $Id: KeyGrabber.h,v 1.3 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Cocoa/Cocoa.h>

@interface KeyGrabber : NSButton
{
    IBOutlet id controller;
    BOOL        isListening;
}

- (void) listen:(BOOL)onOff;

@end
