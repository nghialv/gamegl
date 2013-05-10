//
//  Sprite.h
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Texture2.h"

@interface Sprite : Texture2

@property(nonatomic, assign) GLKVector2 vel;
@property(nonatomic, assign) GLKVector2 accel;
@property(nonatomic, assign) GLKVector2 scale;

- (id)initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (GLKMatrix4)calculateModelMatrix;
- (void)update:(float)dt;

// animation
- (void)linearMove:(GLKVector2)endPoint andDuration:(float)dt;
- (void)quadraticBezierMove:(GLKVector2)endPos andControlPoint:(GLKVector2)control andDuration:(float)dt;

@end
