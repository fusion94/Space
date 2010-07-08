//
//  SpaceAppDelegate.h
//  Space
//
//  Created by Tony Guntharp on 5/13/10.
//  Copyright 2010 damagestudios.net. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface SpaceAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
