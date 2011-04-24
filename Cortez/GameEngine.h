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
}

+(GameEngine *) sharedGameEngine;

@property (nonatomic, retain) CCSpriteFrameCache *animCache;
@property (nonatomic, retain) Character *player;

- (void)setupPlayer;

@end
