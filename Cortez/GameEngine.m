//
//  GameEngine.m
//  Cortez
//
//  Created by COLIN DWAN on 4/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameEngine.h"
#import "Character.h"

@implementation GameEngine

//@synthesize iBlah, player, playerAnimCache, spriteBatch, animCache;
@synthesize animCache, player;

static GameEngine* _sharedGameEngine=nil;

- (id)init
{
    if (([super init])) {
    }
    return self;
}

+(GameEngine *)sharedGameEngine
{
    if (!_sharedGameEngine) {
        _sharedGameEngine = [[self alloc] init];
    }
    return _sharedGameEngine;
}

- (void)dealloc
{
    [animCache release];
    [player release];
    [super dealloc];
}
 
- (void)setupPlayer
{
    animCache = [CCSpriteFrameCache sharedSpriteFrameCache];
    player = [[Character alloc] init];
}

@end
