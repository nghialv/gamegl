//
//  Ball.m
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "Ball.h"
#import "Common.h"

@implementation Ball

@synthesize currentCell = m_currentCell;
@synthesize ballType = m_ballType;

- (void)moveDown:(GLKVector2)startPoint andEndPoint:(GLKVector2)endPoint andDuration:(float)dt {
    super.pos = startPoint;
    [self linearMove:endPoint andDuration:dt];
}

- (void)moveRight {
    [self stopMoving];
    [self quadraticBezierMove:GLKVector2Add(super.pos, GLKVector2Make(super.size.width, 0.0)) andControlPoint:GLKVector2Add(super.pos, GLKVector2Make(super.size.width/2, -super.size.height)) andDuration:TRANSLATE_DURATION];
}

- (void)moveLeft {
    [self stopMoving];
    [self quadraticBezierMove:GLKVector2Add(super.pos, GLKVector2Make(-super.size.width, 0.0)) andControlPoint:GLKVector2Add(super.pos, GLKVector2Make(-super.size.width/2, super.size.height)) andDuration:TRANSLATE_DURATION];
}

- (void)moveUp {
    [self stopMoving];
    [self quadraticBezierMove:GLKVector2Add(super.pos, GLKVector2Make(0.0, super.size.height)) andControlPoint:GLKVector2Add(super.pos, GLKVector2Make(super.size.width, super.size.height/2)) andDuration:TRANSLATE_DURATION];
}

- (void)moveDown {
    [self stopMoving];
    [self quadraticBezierMove:GLKVector2Add(super.pos, GLKVector2Make(0.0, -super.size.height)) andControlPoint:GLKVector2Add(super.pos, GLKVector2Make(-super.size.width, -super.size.height/2)) andDuration:TRANSLATE_DURATION];
}

@end
