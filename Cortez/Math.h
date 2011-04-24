//
//  Math.h
//  Cortez
//
//  Created by COLIN DWAN on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

#define    DEGREES_TO_RADIANS( d )            ((d) * 0.0174532925199432958)
#define RADIANS_TO_DEGREES( r )            ((r) * 57.29577951308232)

static inline void blah(int a)
{
    NSLog(@"ARGH");
}

static inline float distance(CGPoint p1, CGPoint p2)
{
    float dx = p1.x - p2.x;
    float dy = p1.y - p2.y;
    return sqrtf(dx*dx + dy*dy);
}

static inline int manhattanDist(CGPoint p0, CGPoint p1)
{
    return abs(p0.x-p1.x)*10 + abs(p0.y-p1.y)*10;
}

static inline CGPoint makeVector(CGPoint p1, CGPoint p2)
{
    return CGPointMake((p1.x - p2.x), (p1.y - p2.y));
}

static inline int plotY(int x, int dx, int dy, CGPoint origin)
{
    // round up so we can account for the uneven steps
    int iStep = round(((float)dy/dx)*(x-(int)origin.x));
    return iStep + (int)origin.y;
}

// [TODO] - is this more pathfinding than math?
static inline NSArray* stepLine(CGPoint p0, CGPoint p1)
{
    bool bSteep = abs(p1.y-p0.y) > abs(p1.x-p0.x);
    NSMutableArray *set = [[NSMutableArray alloc] init];
    [set addObject:[NSValue valueWithCGPoint:p0]];
    [set addObject:[NSValue valueWithCGPoint:p1]];
    // if the line is steep, just swap the x and y to make it a low slope
    if (bSteep)
    {
        p0 = ccp(p0.y, p0.x);
        p1 = ccp(p1.y, p1.x);
    }
    if (p0.x > p1.x)
    {
        CGPoint temp = p0;
        p0 = p1;
        p1 = temp;
    }
    int dx = p1.x - p0.x;
    int dy = p1.y - p0.y;
    int ystep;
    int y = p0.y;
    if (p0.y < p1.y) {
        ystep = 1;
    }
    else { 
        ystep = -1;
    }
    for (int x = p0.x; x < p1.x; x++)
    {
        y = plotY(x, dx, dy, p0);
        if (bSteep) {
            [set addObject:[NSValue valueWithCGPoint:CGPointMake(y, x)]];
        }
        else {
            [set addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
        }
    }
    return [NSArray arrayWithArray:set];
}



