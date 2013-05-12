//
//  CGScene.h
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface CGScene : NSObject

@property(strong) GLKBaseEffect *effect;

- (id)initWithEffect:(GLKBaseEffect*)effect;
- (void)setBackgroundFile:(NSString*)fileName;

- (void)update:(float)dt;
- (void)render;

- (void)touchesBegan:(CGPoint)touchPoint;
- (void)touchesMoved:(CGPoint)touchPoint;
- (void)touchesEnded:(CGPoint)touchPoint;

@end
