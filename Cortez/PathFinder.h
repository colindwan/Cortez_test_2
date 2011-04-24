//
//  PathFinder.h
//  Cortez
//
//  Created by COLIN DWAN on 4/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "cocos2d.h"

@class PathPoint;

@interface PathFinder : NSObject {
    CCTMXTiledMap *map;

    NSMutableArray *openList;
    NSMutableArray *closedList;
    NSMutableArray *path;
}

#define WALK_VEL        80  // = distance in px that our sprite can walk in one loop (.5 sec)
#define WALK_LOOP_TIME  0.5

- (id)initWithMap:(CCTMXTiledMap *)theMap;
- (NSMutableArray *)findPath:(CGPoint)p0 :(CGPoint)p1;
- (BOOL)findNeighbors:(CGPoint)aPoint :(CGPoint)endPoint;
- (bool)isOnClosedList:(int)iPos;
- (PathPoint *)getClosedNodeByParent:(CGPoint)parent;

@end
