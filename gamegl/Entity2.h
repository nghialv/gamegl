//
//  Entity2.h
//  gamegl
//
//  Created by iNghia on 5/8/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Sprite.h"

@interface Entity2 : Sprite

@property(nonatomic, assign) GLKVector2 vel;
@property(nonatomic, assign) GLKVector2 accel;
@property(nonatomic, assign) GLKVector2 scale;

- (id)initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (GLKMatrix4)calculateModelMatrix;
- (void)update:(float)dt;

// animation
- (void)moveLeft:(float)distance andDuration:(float)dt;
- (void)moveRight:(float)distance andDuration:(float)dt;
- (void)moveUp:(float)distance andDuration:(float)dt;
- (void)moveDown:(float)distance andDuration:(float)dt;

@end
