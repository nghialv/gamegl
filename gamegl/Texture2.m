//
//  Texture2.m
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "Texture2.h"

#import "ResouceManager.h"

typedef struct {
    CGPoint point;
    CGPoint texture;
} TVertex;

typedef struct {
    TVertex bl;
    TVertex br;
    TVertex tl;
    TVertex tr;
} TQuad;

@interface Texture2()

@property (nonatomic, retain) GLKBaseEffect *effect;
@property (nonatomic, retain) GLKTextureInfo *textureInfo;
@property (nonatomic, assign) TQuad quad;

@end

// Implementation
@implementation Texture2

@synthesize effect = m_effect;
@synthesize textureInfo = m_textureInfo;
@synthesize quad = m_quad;
@synthesize pos = m_pos;
@synthesize size = m_size;

- (id)initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if (self = [super init]) {
        m_effect = effect;
        m_textureInfo = [[ResouceManager sharedInstance] getTextureInfo:fileName];
    }
    // default pos and size
    m_pos = GLKVector2Make(0.0, 0.0);
    m_size = CGSizeMake(m_textureInfo.width, m_textureInfo.height);
    // set point
    m_quad.bl.point = CGPointMake(0.0, 0.0);
    m_quad.br.point = CGPointMake(m_size.width, 0.0);
    m_quad.tl.point = CGPointMake(0.0, m_size.height);
    m_quad.tr.point = CGPointMake(m_size.width, m_size.height);
    // set texture vertex
    m_quad.bl.texture = CGPointMake(0.0, 0.0);
    m_quad.br.texture = CGPointMake(1.0, 0.0);
    m_quad.tl.texture = CGPointMake(0.0, 1.0);
    m_quad.tr.texture = CGPointMake(1.0, 1.0);
    
    return self;
}

- (GLKMatrix4)calculateModelMatrix {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    modelMatrix = GLKMatrix4Translate(modelMatrix,
                                      m_pos.x - m_size.width/2.0,
                                      m_pos.y - m_size.height/2.0,
                                      0.0);
    return modelMatrix;
}

- (void)render{
    // set texture
    m_effect.texture2d0.name = m_textureInfo.name;
    m_effect.texture2d0.enabled = YES;
    // calculate model matrix
    m_effect.transform.modelviewMatrix = [self calculateModelMatrix];
    // prepare to draw texture
    [m_effect prepareToDraw];
    // enable
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    
    m_quad.bl.point = CGPointMake(0.0, 0.0);
    m_quad.br.point = CGPointMake(m_size.width, 0.0);
    m_quad.tl.point = CGPointMake(0.0, m_size.height);
    m_quad.tr.point = CGPointMake(m_size.width, m_size.height);
    
    long offset = (long)&m_quad;
    glVertexAttribPointer(GLKVertexAttribPosition,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(TVertex),
                          (void*)(offset + offsetof(TVertex, point)));
    glVertexAttribPointer(GLKVertexAttribTexCoord0,
                          2,
                          GL_FLOAT,
                          GL_FALSE,
                          sizeof(TVertex),
                          (void*)(offset + offsetof(TVertex, texture)));
    
    // draw
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

@end