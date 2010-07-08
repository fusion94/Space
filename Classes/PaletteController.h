//
//  PaletteController.h
//  $Id: PaletteController.h,v 1.9 2002/06/04 16:06:57 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <AppKit/AppKit.h>

#define TITLE_BAR_SHIM    30

#define MIN_WIDTH_SPACE  40
#define MIN_HEIGHT_SPACE 20

#define MAX_WIDTH_SPACE  100
#define MAX_HEIGHT_SPACE 80

#define BB_STYLE_MASK (NSClosableWindowMask       | \
                       NSResizableWindowMask      | \
                       NSMiniaturizableWindowMask | \
                       NSTitledWindowMask)

@interface PaletteController : NSWindowController {
    // pseudo-outlets
    NSWindow*            spaceWindow;
    NSMatrix*            buttonSet; 
}

- (void)      showPalette;
- (void)      hidePalette;

- (void)      redraw;

- (void)      activateAtColumn: (int)spaceColumn andRow: (int)spaceRow;

- (IBAction)  spaceButtonClick:       (id) sender;
- (void)      spaceButtonDoubleClick: (id) sender;

- (void)      updateSpaceWindowAlpha;    
- (void)      updateSpaceWindowAOT;


@end
