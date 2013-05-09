//
//  Entity2.m
//  gamegl
//
//  Created by iNghia on 5/8/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "Entity2.h"

@implementation Entity2

@synthesize vel = m_vel;
@synthesize accel = m_accel;
@synthesize scale = m_scale;

- (id)initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if(self = [super initWithTexture:fileName effect:effect]) {
        m_vel = GLKVector2Make(0.0, 0.0);
        m_accel = GLKVector2Make(0.0, 0.0);
        m_scale = GLKVector2Make(1.0, 1.0);
    }
    return self;
}

- (GLKMatrix4)calculateModelMatrix {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    // translate
    // NSLog(@"size: %f %f", m_size.width/2.0, m_size.height/2.0);
    
    modelMatrix = GLKMatrix4Translate(modelMatrix,
                                      super.pos.x - super.size.width/2.0,
                                      super.pos.y - super.size.height/2.0,
                                      0.0);
    // rotate
    // scale
    
    return modelMatrix;
}

- (void)update:(float)dt {
    m_vel = GLKVector2Add(m_vel, GLKVector2MultiplyScalar(m_accel, dt));
    super.pos = GLKVector2Add(super.pos, GLKVector2MultiplyScalar(m_vel, dt));
}


@end
