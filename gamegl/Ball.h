//
//  Ball.h
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface Ball : Sprite

@property (nonatomic, assign) int currentCell;

- (void)moveDown:(GLKVector2) startPoint andEndPoint:(GLKVector2)endPoint andDuration:(float)dt;
- (void)moveRight;
- (void)moveLeft;
- (void)moveUp;
- (void)moveDown;

@end
