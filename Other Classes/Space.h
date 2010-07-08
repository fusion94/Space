//
//  Space.h
//  $Id: Space.h,v 1.26 2002/06/04 01:33:10 riley Exp $
//
//  copyright Riley Lynch, June 2002
//  may be distributed under the terms of the Q Public License version 1.0
//  see LICENSE.txt for further details
//

#import <Foundation/Foundation.h>

@interface Space : NSObject 
{
    int               index;
    BOOL              sticky;
    NSString          *name; 
}

+ (void)letThereBeSpace;

+(Space*)          getSpaceForIndex: (int)newIndex;
+(NSMutableArray*) processIndexForMenu; // i.e. valid but not visible apps from last scan

-(Space*)          initWithIndex: (int)newIndex;

-(void)            switchTo;

-(void)            scan;
-(void)            hide;
-(void)            show: (BOOL)yieldP;

-(int)             getIndex;
-(void)            setSticky: (BOOL)onOff;
-(BOOL)            isSticky;

- (void)           setName: (NSString*)newName;
- (NSString*)      getName;

@end
