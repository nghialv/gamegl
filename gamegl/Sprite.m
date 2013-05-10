//
//  Sprite.m
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "Sprite.h"

@interface Sprite()

@property (nonatomic, assign) GLKVector2 startPoint;
@property (nonatomic, assign) GLKVector2 endPoint;
@property (nonatomic, assign) GLKVector2 controlPoint;
@property (nonatomic, assign) float duration;
@property (nonatomic, assign) BOOL movingBezier;
@property (nonatomic, assign) float timer;

@end

@implementation Sprite

@synthesize vel = m_vel;
@synthesize accel = m_accel;
@synthesize scale = m_scale;

@synthesize startPoint = m_startPoint;
@synthesize endPoint = m_endPoint;
@synthesize controlPoint = m_controlPoint;
@synthesize duration = m_duration;
@synthesize movingBezier = m_movingBezier;
@synthesize timer = m_timer;

- (id)initWithTexture:(NSString *)fileName effect:(GLKBaseEffect *)effect {
    if(self = [super initWithTexture:fileName effect:effect]) {
        m_vel = GLKVector2Make(0.0, 0.0);
        m_accel = GLKVector2Make(0.0, 0.0);
        m_scale = GLKVector2Make(1.0, 1.0);
        
        m_movingBezier = NO;
        m_timer = 0.0;
    }
    return self;
}

- (GLKMatrix4)calculateModelMatrix {
    GLKMatrix4 modelMatrix = GLKMatrix4Identity;
    // translate
    modelMatrix = GLKMatrix4Translate(modelMatrix,
                                      super.pos.x - super.size.width/2.0,
                                      super.pos.y - super.size.height/2.0,
                                      0.0);
    // rotate
    // scale
    
    return modelMatrix;
}

- (void)update:(float)dt {
    if (!m_movingBezier) {
        m_vel = GLKVector2Add(m_vel, GLKVector2MultiplyScalar(m_accel, dt));
        super.pos = GLKVector2Add(super.pos, GLKVector2MultiplyScalar(m_vel, dt));
    }else {
        m_timer += dt;
        if (m_timer >= m_duration) {
            super.pos = m_endPoint;
            m_movingBezier = NO;
            m_timer = 0.0;
        }else {
            float t = m_timer/m_duration;
            super.pos = GLKVector2MultiplyScalar(m_startPoint, (1.0-t)*(1.0-t));
            super.pos = GLKVector2Add(super.pos, GLKVector2MultiplyScalar(m_controlPoint, 2*(1.0-t)*t));
            super.pos = GLKVector2Add(super.pos, GLKVector2MultiplyScalar(m_endPoint, t*t));
        }
    }
}

- (void)linearMove:(GLKVector2)endPoint andDuration:(float)dt {
    m_vel.x = (endPoint.x - super.pos.x)/dt;
    m_vel.y = (endPoint.y - super.pos.y)/dt;
    
    [NSTimer scheduledTimerWithTimeInterval:dt
                                     target:[NSBlockOperation blockOperationWithBlock:^{
        m_vel.x = 0.0;
        m_vel.y = 0.0;
    }]
                                   selector:@selector(main)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)quadraticBezierMove:(GLKVector2)endPos andControlPoint:(GLKVector2)control andDuration:(float)dt {
    if (m_movingBezier) {
        super.pos = m_endPoint;
    }
    
    m_startPoint = super.pos;
    m_endPoint = endPos;
    m_controlPoint = control;
    m_duration = dt;
    m_movingBezier = YES;
    m_timer = 0.0;
}

- (void)stopMoving {
    if (m_movingBezier) {
        super.pos = m_endPoint;
        m_movingBezier = NO;
        m_timer = 0.0;
    }
}

@end

