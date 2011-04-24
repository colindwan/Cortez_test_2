//
//  PathPoint.h
//  Sprite Test
//
//  Created by COLIN DWAN on 4/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface PathPoint : NSObject {
    int f, g, h;
    CGPoint pos;
    CGPoint parentPos;
}
@property (nonatomic) int f;
@property (nonatomic) int g;
@property (nonatomic) int h;
@property (nonatomic) CGPoint pos;
@property (nonatomic) CGPoint parentPos;

- (id)initWithPos:(CGPoint)newPos;

@end
