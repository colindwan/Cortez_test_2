//
//  Player.m
//  Cortez
//
//  Created by COLIN DWAN on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "GameEngine.h"
#import "Character.h"
#import "Math.h"
#import "cocos2d.h"

@implementation Character

@synthesize mySprite, myBatchNode;


- (id)init
{
    if (([super init])) {
        // [TODO] - load this info from an xml (or plist) file
        [[[GameEngine sharedGameEngine] animCache] addSpriteFramesWithFile:@"playerWalkCoordinates.plist" textureFile:@"playerWalkTexture.png"];
        
        anims = [[NSMutableDictionary alloc] init];
        
        // [TODO] - subclass cached anim loader to handle this heirarchy myself
        NSString *path = [CCFileUtils fullPathFromRelativePath:@"playerMasterAnims.plist"];
        NSDictionary *parentDict = [NSDictionary dictionaryWithContentsOfFile:path];
        NSDictionary *dict = [parentDict objectForKey:@"frames"];
        for(NSString *animGroupName in dict) {
            NSDictionary *animGroupDict = [dict objectForKey:animGroupName];
            NSMutableArray *animNames = [[NSMutableArray alloc] init];
            for (NSString *animName in animGroupDict) {
                if ([animName isEqualToString:@"num_frames"])
                    continue;
                [animNames addObject:animName];
            }
            NSArray *sortedArray = [animNames sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
            [anims setObject:sortedArray forKey:animGroupName];
            //[sortedArray release];
            [animNames release];
        }        
    }

    // setup the default anim frame
    mySprite = [CCSprite spriteWithSpriteFrameName:[[anims objectForKey:@"walk_toward"] objectAtIndex:0]];
    
    // set the sprite's anchor to be on the bottom, center of the sprite
    [mySprite setAnchorPoint:ccp(.5, 0)];
    
    myBatchNode = [CCSpriteBatchNode batchNodeWithFile:@"playerWalkTexture.png"];
    [myBatchNode addChild:mySprite];

    return self;
}

- (void)dealloc
{
    // Don't actually deallocate mySprite or myBatchNode - seems to be just a pointer to a spot in the animCache
    //[mySprite release];
    //[myBatchNode release];
    [anims release];
    [super dealloc];
}

- (void)turnSprite
{
    id anim = [CCAnimation animationWithFrames:[NSArray arrayWithObject:[[[GameEngine sharedGameEngine] animCache] spriteFrameByName:[[anims objectForKey:@"walk_toward"] objectAtIndex:0]]]];
    [mySprite runAction:[CCAnimate actionWithDuration:0.01 animation:anim restoreOriginalFrame:NO]];
}

#pragma mark - Animation

- (CCAction *)animateToPoint:(CGPoint)p0 :(CGPoint)p1 :(bool)addTrailingWalk
{    
    CGPoint vec = makeVector(p1, p0);
    float dist = distance(p1, p0);
    float time;
    time = dist/WALK_VEL;
    NSArray *animArray;
    
    CCAction *moveAction = [[CCAction alloc] init];
    moveAction = [CCMoveTo actionWithDuration:time position:p1];
    
    int iTemp = (int)(time*1000)%(int)(WALK_LOOP_TIME*1000);
    int iAdjust = round((iTemp/(1000/7)));
    
    NSMutableArray *animFrames = [NSMutableArray array];
    NSMutableArray *trailingFrames = [NSMutableArray array];
    
    // [TODO] - this is hacky - fix it
    id iFlip = [CCCallFunc actionWithTarget:self selector:@selector(unFlipMe)];
    
    // Are we walking more to the side or up and down?
    if (abs(vec.x) > abs(vec.y))
    {
        animArray = [[NSArray alloc] initWithArray:[anims objectForKey:@"walk_side"]];
        for (int i = 1; i < [animArray count]; i++)
        {

            CCSpriteFrame *frame = [[[GameEngine sharedGameEngine] animCache] spriteFrameByName:[animArray objectAtIndex:i]];
             [animFrames addObject:frame];
            if (i < [animArray count]-iAdjust)
                [trailingFrames addObject:frame];
             
        }
        if (p1.x < p0.x)
            iFlip = [CCCallFunc actionWithTarget:self selector:@selector(flipMe)];        
    }
    else    // we're walking more vertically than horizontally
    {
        // are we walking up (away)?
        if (vec.y > 0)
        {
            animArray = [anims objectForKey:@"walk_away"];
            for (int i = 1; i < [animArray count]; i++)
            {
                CCSpriteFrame *frame = [[[GameEngine sharedGameEngine] animCache] spriteFrameByName:[animArray objectAtIndex:i]];
                [animFrames addObject:frame];
                if (i < [animArray count]-iAdjust)
                    [trailingFrames addObject:frame];
            }
        }
        else
        {
            animArray = [anims objectForKey:@"walk_toward"];
            for (int i = 1; i < [animArray count]; i++)
            {
                CCSpriteFrame *frame = [[[GameEngine sharedGameEngine] animCache] spriteFrameByName:[animArray objectAtIndex:i]];
                [animFrames addObject:frame];
                if (i < [animArray count]-iAdjust)
                    [trailingFrames addObject:frame];
            }
        }
    }
    
    // setup and run our animation
    // Always force the default home frame in case we interrupted ourselves somewhere else
    CCAnimation *animation = [CCAnimation animationWithFrames:animFrames];
    CCAnimation *trailingAnimation = [CCAnimation animationWithFrames:trailingFrames];
    CCAnimation *homeAnim = [CCAnimation animationWithFrames:[NSArray arrayWithObject:[[[GameEngine sharedGameEngine] animCache] spriteFrameByName:[[anims objectForKey:@"walk_toward"] objectAtIndex:0]]]];
    id walk = [CCRepeat actionWithAction:[CCAnimate actionWithDuration:WALK_LOOP_TIME
                                                             animation:animation 
                                                  restoreOriginalFrame:YES] 
                                   times:MAX((time/WALK_LOOP_TIME),1)];
    id trailingWalk = [CCAnimate actionWithDuration:WALK_LOOP_TIME animation:trailingAnimation restoreOriginalFrame:NO];
    id homeStance = [CCRepeat actionWithAction:[CCAnimate actionWithDuration:0.01f animation:homeAnim restoreOriginalFrame:NO] times:0]; 
    
    CCAction *spriteAction = [[[CCAction alloc] init] autorelease];
    if (addTrailingWalk)
        spriteAction = [CCSequence actions:iFlip, walk, trailingWalk, homeStance, nil];
    else
        spriteAction = [CCSequence actions:iFlip, walk, homeStance, nil];
    
    
    return spriteAction;
}

- (void)flipMe
{
    [mySprite setFlipX:YES];
}

- (void)unFlipMe
{
    [mySprite setFlipX:NO];
}

@end
