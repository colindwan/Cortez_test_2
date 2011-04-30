//
//  GameEngine.h
//  Cortez
//
//  Created by COLIN DWAN on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@class Character;

@interface GameEngine : NSObject {
    CCSpriteFrameCache *animCache;

    Character *player;

    bool bLock;
    CCNode *priorityNode;
}

+(GameEngine *) sharedGameEngine;

@property (nonatomic, retain) CCSpriteFrameCache *animCache;
@property (nonatomic, retain) Character *player;
@property (nonatomic, retain) CCNode *priorityNode;
@property (nonatomic, readonly) bool bLock;

- (void)setupPlayer;

- (bool)lockNode:(CCNode *)target;
- (void)unlockNode:(CCNode *)target;

@end
