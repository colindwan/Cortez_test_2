//
//  HelloWorldLayer.h
//  Cortez
//
//  Created by COLIN DWAN on 4/12/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@class PathFinder;
@class Character;

// Main Stage
@interface MainStage : CCLayer
{
    CCTMXTiledMap *map;
    
    PathFinder *pathFinder;
    
    NSMutableArray *triggers;
    
    NSString *myFileName;
    
    NSMutableArray *characters;
    
    Character *mainChar;
}

#define MAP_TAG     1

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;
+(CCScene *) sceneWithMap:(NSString *)mapName :(NSString *)fromMap;

// Initialization
- (id)initWithMapName:(NSString *)mapName :(NSString *)fromMap;
- (void)setupMap:(NSString *)mapName;
- (void)setupTriggers:(NSString *)fromMap;
- (void)setupGenerators;

- (void)setupSprite;

// Screen moving
- (void)didPointOffScreen:(CGPoint)tap;
- (void)repositionPlayerZ:(ccTime)dt;

// Triggers
- (bool)pointInTrigger;
@end
