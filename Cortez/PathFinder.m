//
//  PathFinder.m
//  Cortez
//
//  Created by COLIN DWAN on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PathFinder.h"
#import "PathPoint.h"
#import "Math.h"

@implementation PathFinder

- (id)initWithMap:(CCTMXTiledMap *)theMap
{
    [super init];
    map = theMap;
    return self;
}

- (NSMutableArray *)findPath:(CGPoint)p0 :(CGPoint)p1
{
    if (openList){
        [openList release];
    }
    if (closedList){
        [closedList release];
    }
    openList = [[NSMutableArray alloc] init];
    closedList = [[NSMutableArray alloc] init];
    
    // Add the first point onto the list
    PathPoint *start = [[PathPoint alloc] initWithPos:p0];
    start.g = 0;
    start.h = manhattanDist(p0, p1);
    start.parentPos = p0;
    [closedList addObject:start];
    [start release];
    
    PathPoint *temp;
    [self findNeighbors:p0 :p1];
    temp = [closedList objectAtIndex:[closedList count]-1];
    while (!CGPointEqualToPoint(temp.pos, p1)) {
        if (!([self findNeighbors:temp.pos :p1])) {
            return nil;
        }
        temp = [closedList objectAtIndex:[closedList count]-1];
    }
    PathPoint *end = [[PathPoint alloc] initWithPos:p1];
    end.parentPos = temp.pos;
    [closedList addObject:end];
    [end release];
        
    if (!path)
        path = [[NSMutableArray alloc] init];
    temp = [closedList objectAtIndex:[closedList count]-1];
    [path addObject:temp];
    //NSLog(@"Walking from (%d, %d) => (%d, %d)", (int)p0.x, (int)p0.y, (int)p1.x, (int)p1.y);
    while (!CGPointEqualToPoint(p0, temp.pos)){
        temp = [self getClosedNodeByParent:temp.parentPos];
        if (CGPointEqualToPoint(temp.pos, temp.parentPos) && !CGPointEqualToPoint(p0, temp.pos)) {
            NSLog(@"Infinite Loop!");
        }
        //NSLog(@"Added a point: (%d, %d)", (int)temp.pos.x, (int)temp.pos.y);
        [path addObject:temp];
    }
    //NSLog(@" ");
    return path;
}

- (BOOL)findNeighbors:(CGPoint)aPoint :(CGPoint)endPoint
{
    CCTMXLayer *layer = [map layerNamed:@"obstacles"];
    unsigned int guid;
    NSDictionary *props;
    int iWalkable = 0;
    CGSize mapSize = [map contentSize];
    CGSize tileSize = [map tileSize];
    CGSize mapTiles = CGSizeMake((int)mapSize.width/tileSize.width, (int)mapSize.height/tileSize.height);
    
    // [CAD] - HACK
    int iParentG = 0;
    int iPreG = 0;
    PathPoint *parent = nil;
    if ([closedList count])
    {
        parent = [closedList objectAtIndex:[closedList count]-1];
        iParentG = parent.g;
    }
    
    for (int x = MAX(aPoint.x-1,0); x < MIN(aPoint.x+2,mapTiles.width); x++)
    {
        int dx = x - aPoint.x;
        for (int y = MAX(aPoint.y-1,0); y < MIN(aPoint.y+2,mapTiles.height); y++)
        {
            int dy = y - aPoint.y;
            
            // Is this tile walkable?
            guid = [layer tileGIDAt:ccp(x, (int)mapTiles.height-y-1)];
            props = [map propertiesForGID:guid];
            iWalkable = 0;
            iWalkable = [[props objectForKey:@"walkable"] intValue];
            //NSLog(@"Walkable? %d @(%d, %d)", iWalkable, x, (int)mapTiles.height-y-1);
            if (iWalkable < 0)
                continue;
            
            // [HACK] - precalc the g, don't bother with building a real PathPoint and all the memory management
            iPreG = iParentG;
            if (dx ^ dy)
                iPreG += 10;
            else
                iPreG += 14;
            
            
            // [CAD] - This is dumb - do another version where I store a duplicate list in a dictionary so I can do quick lookups
            bool bFound = NO;
            // Is this tile already in our open list?
            for (int i = 0; i < [openList count]; i++)
            {
                PathPoint *temp = [openList objectAtIndex:i];
                if (CGPointEqualToPoint(temp.pos, CGPointMake(x, y)) && [closedList count] > 2 && !CGPointEqualToPoint(temp.pos, aPoint))
                {
                    // [CAD] - another hack here to make sure we don't go to the parent of my parent (for quick right angle turns)
                    if (temp.g < iPreG && !CGPointEqualToPoint(parent.pos, temp.pos) && !CGPointEqualToPoint(parent.pos, temp.parentPos) && !CGPointEqualToPoint(temp.pos, CGPointMake(x, y)))
                    {
                        // [CAD] - I don't really understand this...
                        //NSLog(@"Found a better sibling than myself");
                        temp.parentPos = ccp(x,y);
                        if (CGPointEqualToPoint(temp.pos, temp.parentPos))
                            NSLog(@"Setting up infinite loop!");
                        temp.g -= iParentG;
                        temp.g += iPreG;
                        temp.f = temp.g + temp.h;
                    }
                    bFound = YES;
                    break;
                }
            }
            if (bFound)
            {
                //NSLog(@"Found in open list! %d, %d", x, y);
                continue;
            }
            bFound = NO;
            // Is this tile already in our closed list?
            for (int i = 0; i < [closedList count]; i++)
            {
                PathPoint *temp = [closedList objectAtIndex:i];
                if (CGPointEqualToPoint(temp.pos, CGPointMake(x, y)))
                {
                    bFound = YES;
                    break;
                }
            }
            if (bFound)
            {
                //NSLog(@"Found in closed list! %d, %d", x, y);
                continue;
            }
            
            
            PathPoint *temp = [[PathPoint alloc] initWithPos:CGPointMake(x, y)];
            // [CAD] - BROKEN!
            temp.g = iParentG;
            if (dx ^ dy)
            {
                temp.g += 10;
            }
            else
                temp.g += 14;
            temp.h = manhattanDist(temp.pos, endPoint);
            temp.f = temp.g + temp.h;
            temp.parentPos = aPoint;
            [openList addObject:temp];
            [temp release];
        }
    }
        
    int iLowPos=0;
    int iLowF=-1;
    for (int i = 0; i < [openList count]; i++)
    {
        PathPoint *temp = [openList objectAtIndex:i];
        // [CAD] - more hacks just to get through tonight
        if (![closedList count] > 1)
            if (CGPointEqualToPoint(parent.pos, temp.pos) || CGPointEqualToPoint(parent.pos, temp.parentPos))
                continue;
        if (iLowF == -1)
        {
            if ([self isOnClosedList:i])
            {
                //NSLog(@"BLAH");
                continue;
            }
            iLowF = temp.f;
            iLowPos = i;
        }
        else if (temp.f < iLowF)
        {
            if ([self isOnClosedList:i])
            {
                //NSLog(@"BLAH");
                continue;
            }
            iLowF = temp.f;
            iLowPos = i;
        }
    }
    if ([openList count] == 0) {
        return false;
    }
    PathPoint *temp = [openList objectAtIndex:iLowPos];
    [closedList addObject:temp];
    [openList removeObject:temp];
    return true;
}

- (bool)isOnClosedList:(int)iPos
{
    PathPoint *temp = [openList objectAtIndex:iPos];
    PathPoint *closedTemp;
    for (int i = 0; i < [closedList count]; i++)
    {
        closedTemp = [closedList objectAtIndex:i];
        if (CGPointEqualToPoint(temp.pos, closedTemp.pos))
            return YES;
    }
    return NO;
}

- (PathPoint *)getClosedNodeByParent:(CGPoint)parent
{
    PathPoint *temp;
    for (int i = 0; i < [closedList count]; i++)
    {
        temp = [closedList objectAtIndex:i];
        if (CGPointEqualToPoint(parent, temp.pos))
            return temp;
    }
    return Nil;
}

@end
