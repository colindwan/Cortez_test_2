//
//  PathPoint.m
//  Sprite Test
//
//  Created by COLIN DWAN on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PathPoint.h"


@implementation PathPoint
@synthesize f, g, h, pos, parentPos;

- (id)initWithPos:(CGPoint)newPos
{
    [super init];
    pos = newPos;
    return self;
}

@end
