//
//  Texture2.h
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface Texture2 : NSObject

@property (nonatomic, assign) GLKVector2 pos;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) BOOL display;

- (id) initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect;
- (void)setTexture:(NSString*)fileName;
- (GLKMatrix4) calculateModelMatrix;
- (void) render;


@end
