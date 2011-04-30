//
//  HelloWorldLayer.m
//  Empty Cocos Project
//
//  Created by COLIN DWAN on 4/18/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// Import the interfaces
#import "ConversationOverlay.h"
#import "GameEngine.h"
#import "MainStage.h"

// HelloWorldLayer implementation
@implementation ConversationOverlay

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	ConversationOverlay *layer = [ConversationOverlay node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		[self setupConvo];
    }
	return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	// in this particular example nothing needs to be released.
	// cocos2d will automatically release all the children (Label)
	
	// don't forget to call "super dealloc"
	[super dealloc];
}

#pragma mark - Drawing

void ccFillPoly( CGPoint *poli, int points, BOOL closePolygon )
{
    // Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
    // Needed states: GL_VERTEX_ARRAY,
    // Unneeded states: GL_TEXTURE_2D, GL_TEXTURE_COORD_ARRAY, GL_COLOR_ARRAY
    glDisable(GL_TEXTURE_2D);
    glDisableClientState(GL_TEXTURE_COORD_ARRAY);
    glDisableClientState(GL_COLOR_ARRAY);

    glVertexPointer(2, GL_FLOAT, 0, poli);
    if( closePolygon )
        glDrawArrays(GL_TRIANGLE_FAN, 0, points);
    else
        glDrawArrays(GL_LINE_STRIP, 0, points);

    // restore default state
    glEnableClientState(GL_COLOR_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    glEnable(GL_TEXTURE_2D);
}

-(void) draw
{
	CGSize s = [[CCDirector sharedDirector] winSize];
    
	// closed purble poly
	glColor4ub(0, 0, 0, 150);
	CGPoint vertices2[] = { ccp(s.width*0.15,0), ccp(s.width*0.15,s.height*0.25), ccp(s.width*0.85,s.height*0.25), ccp(s.width*0.85,0) };
        
    ccFillPoly( vertices2, 4, YES);
}

#pragma mark - Conversations

// [TODO] - subclass CCMenuItem to have more info than just an integer "tag"

- (void)setupConvo
{    
    [self lockConvo];
    NSString *path = [CCFileUtils fullPathFromRelativePath:@"conversation_test.plist"];
    NSDictionary *parentDict = [NSDictionary dictionaryWithContentsOfFile:path];
    convo = [parentDict objectForKey:@"first_convo"];
    [convo retain];
    [self showStep:@"0"];
}

- (void)lockConvo
{
    if (!([[GameEngine sharedGameEngine] lockNode:self])) {
        NSLog(@"We tried to lock the convo on top of another one!");
        abort();
    }
}

- (void)unlockConvo:(CCMenuItem *)menuItem
{
    [[GameEngine sharedGameEngine] unlockNode:self];
    [self removeAllChildrenWithCleanup:YES];
    
    // [CAD] - this works but is janky - I should be able to pass whoever called me a message that I'm done without caring what kind of class it was
    [(MainStage *)[self parent] cleanupConvo];
}

- (void)doSomething:(CCMenuItem *)menuItem
{
    [self showStep:[NSString stringWithFormat:@"%d",[menuItem tag]]];
}

- (void)showStep:(NSString *)stepLabel
{
    [self removeAllChildrenWithCleanup:YES];
    
    NSDictionary *stepDict = [convo objectForKey:stepLabel];
    CGSize s = [[CCDirector sharedDirector] winSize];
    
    NSString *greeting = [NSString stringWithString:[stepDict objectForKey:@"greeting"]];
    CCLabelTTF *greetingLabel = [CCLabelTTF labelWithString:greeting fontName:@"Times New Roman" fontSize:18];
    [greetingLabel setColor:ccc3(255, 50, 255)];
    greetingLabel.position = ccp(s.width*0.50, s.height*0.22);
    [self addChild:greetingLabel];
    
    NSString *immediateAction = [stepDict objectForKey:@"action"];
    if ([immediateAction length]) {
        if ([immediateAction isEqualToString:@"exit"]) {
            CCMenuItemFont *option = [CCMenuItemFont itemFromString:@"Goodbye" target:self selector:@selector(unlockConvo:)];
            menu = [CCMenu menuWithItems:option, nil];
            [menu setPosition:ccp(s.width*0.5, s.height*0.16)];
            [self addChild:menu];
            return;
        }
    }
    
    [CCMenuItemFont setFontName:@"Times New Roman"];
    [CCMenuItemFont setFontSize:18];
    menu = [CCMenu menuWithItems:nil];
    [menu setPosition:ccp(s.width*0.5, s.height*0.10)];
    [self addChild:menu];
    NSLog(@"Dissecting step: %@", stepDict);
    for (NSString *optionName in stepDict)
    {        
        if (!([optionName hasSuffix:@"response"])) {
            NSLog(@"Skipping %@", optionName);
            continue;
        }
        NSLog(@"Dissecting option %@", optionName);
        NSDictionary *optionDict = [stepDict objectForKey:optionName];
        NSString *optionText = [optionDict objectForKey:@"text"];
        CCMenuItemFont *option = [CCMenuItemFont itemFromString:optionText target:self selector:@selector(doSomething:)];
        [option setTag:[[optionDict objectForKey:@"leads_to"] intValue]];
        [menu addChild:option];
    }
    [menu alignItemsVerticallyWithPadding:0.0];
}

@end
