//
//  SpaceProcess.h
//  $Id: SpaceProcess.h,v 1.25 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Foundation/Foundation.h>
#include <Carbon/Carbon.h> 

#define initPSNwithInt(psn,int) \
    psn.highLongOfPSN = 0;      \
    psn.lowLongOfPSN  = int;
 
#define initPINFO(pinfo, pnamePSTR, pinfospecPTR)     \
    pinfo.processAppSpec    = pinfospecPTR;           \
    pinfo.processName       = pnamePSTR;              \
    pinfo.processInfoLength = sizeof(ProcessInfoRec);

// Undocumented API, use at your own risk!
EXTERN_API (OSErr) CPSPostHideReq     (ProcessSerialNumber *PSN); // from CoreGraphics 
EXTERN_API (OSErr) CPSPostShowReq     (ProcessSerialNumber *PSN); //  "     " 


@interface SpaceProcess : NSObject 
{
    NSString             *name;
    ProcessSerialNumber  *psn;
    BOOL                 sticky;
    BOOL                 BGOnly;
    BOOL                 front;
    int                  space;
}

+(SpaceProcess*) getNextProcess;
+(SpaceProcess*) processForPSN:(ProcessSerialNumber *)psn;
+(NSEnumerator*) processEnumerator;
+(void)          doGarbageCollection;
+(BOOL)          SpaceAppIsFront;

-(SpaceProcess*) initWithPSN:(ProcessSerialNumber*)psn;
-(void)          retire;

-(void)          show;
-(void)          focus;
-(void)          hide;

-(BOOL)          validate; // returns YES for valid; returns NO and retires non-valid
-(BOOL)          isForeground;

-(NSString*)     getName;
-(BOOL)          isBGOnly;
-(void)          setSticky:(BOOL)onOff;
-(BOOL)          isSticky;
-(void)          setFront:(BOOL)onOff;
-(BOOL)          isFront;
-(void)          setSpace:(int)newSpace;
-(int)           getSpace;

@end
