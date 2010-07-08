//
//  SpaceProcess.m
//  $Id: SpaceProcess.m,v 1.34 2002/06/04 01:33:11 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import "SpaceProcess.h"
#import "Space.h"
#include "space-defines.h"

@implementation SpaceProcess

// Class variables
static ProcessSerialNumber thisProcess;
static ProcessSerialNumber seekProcess;
static NSMutableDictionary *allProcesses;

+ (void)initialize
{
    allProcesses = [[NSMutableDictionary alloc] init];
    initPSNwithInt(seekProcess, 0);
    GetCurrentProcess(&thisProcess);
}

+ (SpaceProcess*) getNextProcess
{
    OSErr                error;
    SpaceProcess         *nextProcess = nil; // default for loop exit            

    while ((error = GetNextProcess(&seekProcess)) == 0) {
        NSString *procKey = [NSString stringWithFormat:@"%d-%d",
                                                       seekProcess.highLongOfPSN,
                                                       seekProcess.lowLongOfPSN];
        if ((nextProcess = [allProcesses objectForKey: procKey]) == nil) {
            nextProcess = [[[SpaceProcess alloc] initWithPSN: &seekProcess] autorelease];
            [allProcesses setObject: nextProcess forKey: procKey];
        }
        break; // nextProcess set -- exit loop
    }
    return nextProcess;
}

+ (SpaceProcess*) processForPSN:(ProcessSerialNumber *)Apsn
{
    SpaceProcess *process;
    NSString     *procKey = [NSString stringWithFormat:@"%d-%d",
                             Apsn->highLongOfPSN,
                             Apsn->lowLongOfPSN];                             
    if ((process = [allProcesses objectForKey: procKey]) == nil)
        process = [[SpaceProcess alloc] initWithPSN: Apsn];
    
    return process;
}

+ (NSEnumerator*) processEnumerator
{
     return [allProcesses objectEnumerator];
}

+ (void) doGarbageCollection
{
    SpaceProcess *process;
    NSEnumerator *eachProcess  = [allProcesses objectEnumerator];    
    while ((process = [eachProcess nextObject]) != nil) {
        [process validate];
    }    
}

+ (BOOL) SpaceAppIsFront
{
    BOOL                       isSpaceApp;
    static ProcessSerialNumber frontProcess;
    
    GetFrontProcess(&frontProcess);
    SameProcess(&frontProcess, &thisProcess, &isSpaceApp);

    return isSpaceApp;
}

- (SpaceProcess*) initWithPSN:(ProcessSerialNumber *)aPSN 
{
    OSErr                err;
    ProcessInfoRec       pinfo;
    FSSpec               pinfospec;
    Str255               pinfoname;
    Boolean              isThisProcess;

    initPINFO(pinfo, pinfoname, &pinfospec);
    if ((err = GetProcessInformation(aPSN, &pinfo))) {
        return nil;
    }
    else {
        char *cname   = (char *) malloc(sizeof(char[256]));
        if(![super init]) return nil;

        p2cstrcpy(cname,pinfo.processName); // any way to do pascal -> NSString ?
        DEBUG_OUTF(@"initializing process object for \"%s\"",cname);
        DEBUG_OUTF(@"process mode: %d", pinfo.processMode);
        name = [[NSString alloc] initWithCString: cname];

        psn = (ProcessSerialNumber *) malloc(sizeof(ProcessSerialNumber));
        memcpy(psn,aPSN,sizeof(ProcessSerialNumber));

        SameProcess(&seekProcess, &thisProcess, &isThisProcess);
        if ((pinfo.processMode & modeOnlyBackground) || isThisProcess)
            BGOnly = YES; // treating space like the dock, etc.
        else                                                    
            BGOnly = NO;     

        space  = SPACE_INDEX_NO_SPACE;
        sticky = NO;
    
        free(cname);
        return self;
    }
}

- (void)dealloc
{
    DEBUG_OUTF(@"deallocating process object for \"%@\"", name);
    [name release];    
    if (psn) free(psn);
    [super dealloc];
}


- (void)retire
{
    NSString     *procKey = [NSString stringWithFormat:@"%d-%d",
                             psn->highLongOfPSN,
                             psn->lowLongOfPSN];
    DEBUG_OUTF(@"retiring process object for \"%@\"", name);
    [allProcesses removeObjectForKey: procKey];
}

- (void)show
{
    OSErr  error;
    DEBUG_OUTF(@"showing \"%@\"", name);
    if (error = CPSPostShowReq(psn))
        DEBUG_OUTF(@"Error unhiding process \"%@\"", name);
}

- (void)focus
{
    OSErr  error;
    DEBUG_OUTF(@"focusing \"%@\"", name);
    if (error = SetFrontProcess(psn))
        DEBUG_OUTF(@"Error focusing process \"%@\"", name);
}

- (void)hide
{
    OSErr  error;
    DEBUG_OUTF(@"hiding \"%@\"", name);
    if (error = CPSPostHideReq(psn))
        DEBUG_OUTF(@"Error hiding process \"%@\"", name);
}

-(BOOL)validate
{ // GetProcessPID would be preferable, but it fails with classic apps
    OSStatus error;
    ProcessInfoRec       pinfo;
    FSSpec               pinfospec;
    Str255               pinfoname;
    initPINFO(pinfo, pinfoname, &pinfospec);
    if ((error = GetProcessInformation(psn, &pinfo))) {
        DEBUG_OUTF(@"\"%@\" is no longer valid", name);
        DEBUG_OUTF(@"Error was: %d", error);
        [self retire];
        return NO;
    }
    else {
        return YES;
    }
}

-(BOOL)isForeground
{ 
    if (!BGOnly && IsProcessVisible(psn)) {
        DEBUG_OUTF(@"\"%@\" is in the foreground", name);
        return YES;
    }
    else {
        DEBUG_OUTF(@"\"%@\" is in the background", name);
        return NO;
    }
}

- (NSString*)getName
{
    return [[name copy] autorelease];
}

-(BOOL)isBGOnly
{
    return BGOnly;
}

-(void)setSticky:(BOOL)onOff
{
    sticky = onOff;
}

-(BOOL)isSticky 
{
    return sticky;
}

-(void)setFront:(BOOL)onOff
{
    front = onOff;
}

-(BOOL)isFront
{
    return front;
}
-(void)setSpace:(int)newSpace
{
    space = newSpace;
}

-(int)getSpace
{
    return space;
}

@end
