//
//  Sprite.h
//  gamegl
//
//  Created by iNghia on 5/8/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Sprite : NSObject

@property (nonatomic, assign) GLKVector2 pos;
@property (nonatomic, assign) CGSize size;

- (id) initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (GLKMatrix4) calculateModelMatrix;
- (void) render;

@end
