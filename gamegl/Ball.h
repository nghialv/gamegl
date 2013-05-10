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

- (void)moveDown:(GLKVector2) startPoint andEndPoint:(GLKVector2)endPoint andDuration:(float)dt;
- (void)moveRight;


@end
