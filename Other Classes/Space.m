//
//  Space.m
//  $Id: Space.m,v 1.50 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

//#import  "SpaceController.h"
#import "SpaceApplication.h"
#import  "Space.h"
#import  "SpaceProcess.h"
#include "space-defines.h"

@implementation Space

static NSMutableArray* allSpaces;
static int             GCCount = 0;

+ (void)initialize {
    allSpaces = [[NSMutableArray alloc] initWithCapacity: (MAX_SPACES + 1)];
}

+ (void)letThereBeSpace
{ // can't happen in initialize since prefs(names) are needed
    int i;
    for (i=0; i<=MAX_SPACES; i++) {
        Space *thisSpace = [[Space alloc] initWithIndex: i];

        if (i == SPACE_INDEX_STICKY)
            [thisSpace setSticky: YES];

        [allSpaces addObject: [thisSpace autorelease]];
    }
}

+ (Space*)getSpaceForIndex:(int)fetchIndex
{
    return [allSpaces objectAtIndex: fetchIndex];
}

+(NSMutableArray*) processIndexForMenu
{
    int i;
    SpaceProcess   *process;
    NSEnumerator   *enumerator = [SpaceProcess processEnumerator];    
    NSMutableArray *space2procs = [[NSMutableArray alloc] initWithCapacity: (MAX_SPACES + 1)];

    for (i = 0; i<=MAX_SPACES; i++) {
        [space2procs addObject: [[NSMutableArray new] autorelease]];
    }

    DEBUG_OUT(@"Refreshing process dictionary for menu");
    while ((process = [enumerator nextObject]) != nil) {
        int procIndex = [process getSpace];
        if ((procIndex == SPACE_INDEX_NO_SPACE)||(![process validate])||[process isForeground]) {
            continue; // process will not be displayed in menu
        }
        else {
            NSMutableArray *procList = [space2procs objectAtIndex: procIndex];
            int procCount = [procList count];
            if (procCount < MAX_MENU_PROCESSES) {
                DEBUG_OUTF(@"Adding \"%@\" to the menu", [process getName]);
                [procList addObject: [process getName]];            
            }
            else if (procCount < (MAX_MENU_PROCESSES + 1)) {
                [procList addObject: @"..."];
            }
        }
    }
    return [space2procs autorelease];
}

- (Space*)initWithIndex:(int)newIndex
{
    if (![super init]) return nil;
    if (newIndex < SPACE_INDEX_STICKY) return nil;
    else {
        DEBUG_OUTF(@"initializing workspace %d", newIndex);
        index      = newIndex;
        sticky     = NO;
        name       = [[[[NSUserDefaults standardUserDefaults]
                    arrayForKey: NAMES_PREFKEY] objectAtIndex: index] retain];
    }
    return self;
}

- (void)scan
{
    SpaceProcess *process;
    ProcessSerialNumber  frontPSN;

    DEBUG_OUTF(@"Scanning space %d", index);
    while ((process = [SpaceProcess getNextProcess]) != nil) {
        if ([process isBGOnly])
            continue;
        if ([process isForeground]) {
            if (sticky) {
                DEBUG_OUTF(@"sticking \"%@\"", [process getName]);
                [process setSticky: YES];
                [process setSpace: SPACE_INDEX_NO_SPACE];
            }
            else if (![process isSticky]) {
                DEBUG_OUTF(@"adding \"%@\" to this space", [process getName]);
                [process setSpace: index];
            }
            
            [process setFront: NO]; // we will set one process front at end
        }
        else if (sticky && [process isSticky]) { // consider making it easier to unstick
            DEBUG_OUTF(@"unsticking \"%@\"", [process getName]);
            [process setSticky: NO];
        }
        else if ([process getSpace] == index) {
            DEBUG_OUTF(@"removing \"%@\" from this space", [process getName]);
            [process setSpace: SPACE_INDEX_NO_SPACE];
        }
    }
    
    GetFrontProcess(&frontPSN); // it would be nice if we could just test a given proc!
    if ((process = [SpaceProcess processForPSN: &frontPSN]) != nil)
        [process setFront: YES];    
}

-(void)switchTo
{ // this function is called by dock menu
    
    SpaceApplication *sharedApp = [SpaceApplication sharedApplication];

    // determine which row/space is being switched to
    int spaceColumns = [sharedApp getSpaceColumns];
    int x = ((index - 1) % spaceColumns);
    int y = ((index - 1) / spaceColumns);
    
    [sharedApp switchToSpaceForColumn: x andRow: y];

}

-(void)hide
{ 
    DEBUG_OUTF(@"=== Scanning workspace %d before departure===", index);
    [self scan];
    if (!sticky) { // sticky spaces have nothing to hide
        SpaceProcess         *process;
        NSEnumerator         *processEnumerator = [SpaceProcess processEnumerator];
        DEBUG_OUTF(@"=== Hiding workspace %d ===", index);
        while ((process = [processEnumerator nextObject]) != nil) {
            if (([process getSpace] == index)) {
                if ([process validate] && (![process isSticky])) {
                    [process hide];
                } // else not valid or already hidden(?) 
            } // else not pertinent to this space
        }
    }
}

- (void)show:(BOOL)yieldP;
{
    SpaceProcess *process;
    SpaceProcess *frontProcess = nil;
    SpaceProcess *lastProcess  = nil;

    NSEnumerator *processEnumerator = [SpaceProcess processEnumerator];
    DEBUG_OUTF(@"=== Showing workspace %d ===", index);
    while ((process = [processEnumerator nextObject]) != nil) {
        if (([process getSpace] == index) || [process isSticky]) {
            if ([process validate] && (![process isForeground])) {            
                [process show];
                if (yieldP && [process isFront]) frontProcess = process;
                else lastProcess = process;
            } // else it's invalid or already visible
        } // else it's not something we want to show
    }
    
    // if we can't use the last process that was in front in a space
    // just yield to the last process (enumerator wise) in the space
    if (yieldP && frontProcess) [frontProcess focus];
    else if (yieldP && [SpaceProcess SpaceAppIsFront] && lastProcess) {
        [lastProcess focus];
    }
    
    // Doing GC here won't disrupt user experience
    if (++GCCount > GC_COUNT_THRESHOLD) {
        DEBUG_OUT(@"=== Doing SpaceProcess GC ===");
        [SpaceProcess doGarbageCollection];
        GCCount = 0;
    }
}

- (void) setSticky: (BOOL)onOff
{
    BOOL wasSticky = sticky;
    sticky = onOff;
    
    if (wasSticky && (!sticky)) {
        SpaceProcess *process;
        while ((process = [SpaceProcess getNextProcess]) != nil) {
            if ([process getSpace] == index) {
                [process setSticky: NO];
            }
        }
    }
}

- (BOOL) isSticky
{
    return sticky;
}

- (int)getIndex
{
    return index;
}

- (void)setName:(NSString*)newName
{
    if (name != newName) {
        NSArray *oldNames        = [[NSUserDefaults standardUserDefaults] 
                                    arrayForKey: NAMES_PREFKEY];
        NSMutableArray *newNames = [NSMutableArray arrayWithArray: oldNames];
        
        NSString *oldName = name;
        name = [newName copy];
        [newNames replaceObjectAtIndex:index withObject: name];
        
        [[NSUserDefaults standardUserDefaults] setObject: newNames 
                                                  forKey: NAMES_PREFKEY];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        [oldName release];
    }
}

- (NSString*)getName
{
    return [[name copy] autorelease];
}

@end
