//
//  Ball.m
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "Ball.h"

@implementation Ball

- (void)moveDown:(GLKVector2)startPoint andEndPoint:(GLKVector2)endPoint andDuration:(float)dt {
    super.pos = startPoint;
    [self linearMove:endPoint andDuration:dt];
}

- (void)moveRight {
    [self quadraticBezierMove:GLKVector2Add(super.pos, GLKVector2Make(super.size.width, 0.0)) andControlPoint:GLKVector2Add(super.pos, GLKVector2Make(super.size.width/2, -super.size.height)) andDuration:0.5];
}

@end
