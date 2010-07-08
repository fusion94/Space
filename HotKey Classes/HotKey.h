//
//  HotKey.h
//  $Id: HotKey.h,v 1.5 2002/06/04 01:33:09 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Foundation/Foundation.h>

// warning: some (lower?) uids seem to be reserved and are
// not passed to your application unless it is in front
// these include the ids around 100 (decimal)
// these seem to be assigned to control-fkeys by default
// removing these hot keys does not help.

@interface HotKey : NSObject {
    int            uid;
    unsigned short options;
    unsigned short key;
    unsigned int   flags;
    int            exclusion; // not sure what this is
                              // 0x0 replicates CGSSetHotKey
}

+ (HotKey*) HotKeyForUID: (int)uid;

- (HotKey*) initWithUID:(int)uid options:(unsigned short)options
                                 keycode:(unsigned short)key 
                                 flags:(unsigned int)modifier_flags
                                exclusion:(int)exclusion;
                                
- (HotKey*) initWithUID:(int)uid options:(unsigned short)options
                                 keycode:(unsigned short)key 
                                 flags:(unsigned int)modifier_flags; 
                                 
- (HotKey*) initWithUID:(int)uid keycode:(unsigned short)key 
                                 flags:(unsigned int)modifier_flags; 

-(int)            getUID;
-(unsigned short) getOptions;
-(unsigned short) getKey;
-(unsigned int)   getFlags;
-(int)            getExclusion;

- (void) registerWithCGS;
- (void) setEnabled:(BOOL)onOff;
- (BOOL) isEnabled;
- (void) removeFromCGS;



@end

