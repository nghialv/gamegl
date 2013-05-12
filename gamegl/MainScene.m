//
//  MainScene.m
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "MainScene.h"
#import "BallTable.h"

@interface MainScene()

@property (nonatomic, strong) BallTable *ballTable;

@end

@implementation MainScene

@synthesize ballTable = m_ballTable;

- (id)initWithEffect:(GLKBaseEffect *)effect {
    if (self = [super initWithEffect:effect]) {
        m_ballTable = [[BallTable alloc] initWithEffect:effect];
    }
    return self;
}

- (void)update:(float)dt {
    [m_ballTable update:dt];
}

- (void)render {
    // draw balltable
    [m_ballTable render];
}

- (void)touchesBegan:(CGPoint)touchPoint {
    [m_ballTable touchesBegan:touchPoint];
}

- (void)touchesMoved:(CGPoint)touchPoint {
    [m_ballTable touchesMoved:touchPoint];
}

- (void)touchesEnded:(CGPoint)touchPoint {
    [m_ballTable touchesEnded:touchPoint];
}

@end
