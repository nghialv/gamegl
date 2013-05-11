//
//  BallTable.h
//  gamegl
//
//  Created by iNghia on 5/11/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface BallTable : NSObject

+ (BallTable*) sharedInstance;

- (void)initilize:(GLKBaseEffect*)effect;
- (void)update:(float)dt;
- (void)render;

- (void)touchesBegan:(CGPoint)touchPoint;
- (void)touchesMoved:(CGPoint)touchPoint;
- (void)touchesEnded:(CGPoint)touchPoint;

@end
