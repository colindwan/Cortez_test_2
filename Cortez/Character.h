//
//  Player.h
//  Cortez
//
//  Created by COLIN DWAN on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

// [TODO] - Build a set of NSArrays to store each walk cycle (forward, back, left, right) then index them with a dictionary

@interface Character : NSObject {
    CCSprite *mySprite;
    CCSpriteBatchNode *myBatchNode;
    
    // [TODO] - subclass CCSpriteFrameCache to handle these anims naturally
    NSMutableDictionary *anims;
}

// [TODO] - Load this from an xml file somehow
#define WALK_VEL        80  // = distance in px that our sprite can walk in one loop (.5 sec)
#define WALK_LOOP_TIME  0.5

@property (nonatomic, retain) CCSprite *mySprite;
@property (nonatomic, retain) CCSpriteBatchNode *myBatchNode;

- (CCAction *)animateToPoint:(CGPoint)p0 :(CGPoint)p1 :(bool)addTrailingWalk;
- (void)flipMe;
- (void)unFlipMe;
- (void)turnSprite;

@end
