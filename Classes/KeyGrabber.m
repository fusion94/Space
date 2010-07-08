//
//  KeyGrabber.m
//  $Id: KeyGrabber.m,v 1.4 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import "KeyGrabber.h"
#import "PrefsController.h"

@implementation KeyGrabber

- (void) listen:(BOOL)onOff;
{
    isListening = onOff;
}

- (void)keyDown: (NSEvent*)anEvent
{
    if (isListening) {

        [controller registerKey: [anEvent keyCode] withMods: [anEvent modifierFlags]];
        isListening = NO;
    }

}

- (BOOL)performKeyEquivalent: (NSEvent*)anEvent
{
    if (isListening) {
        [controller registerKey: [anEvent keyCode] withMods: [anEvent modifierFlags]];
        isListening = NO;
        return YES;
    }
    else return NO;
}

- (BOOL) becomeFirstResponder
{
    return isListening; 
}


- (BOOL) resignFirstResponder
{
    isListening = NO;
    [controller abortKeyCapture];
    return YES;
}


@end
