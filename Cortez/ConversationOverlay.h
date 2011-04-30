//
//  HelloWorldLayer.h
//  Empty Cocos Project
//
//  Created by COLIN DWAN on 4/18/11.
//  Copyright __MyCompanyName__ 2011. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

// HelloWorldLayer
@interface ConversationOverlay : CCLayer
{
    NSDictionary *convo;
    CCMenu *menu;
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (void)setupConvo;
- (void)lockConvo;
- (void)doSomething:(CCMenuItem *)menuItem;
- (void)unlockConvo:(CCMenuItem *)menuItem;

- (void)showStep:(NSString *)stepLabel;
@end
