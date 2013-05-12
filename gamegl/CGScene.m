//
//  CGScene.m
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "CGScene.h"
#import "Texture2.h"

@interface CGScene()
@property(nonatomic, retain) Texture2 *background;
@end

@implementation CGScene

@synthesize effect = m_effect;
@synthesize background = m_background;

- (id)initWithEffect:(GLKBaseEffect *)effect {
    if (self = [super init]) {
        m_effect = effect;
        m_background = nil;
    }
    return self;
}

- (void)setBackgroundFile:(NSString*)fileName {
    m_background = [[Texture2 alloc] initWithTexture:fileName effect:m_effect];
    [m_background setPos:GLKVector2Make([UIScreen mainScreen].bounds.size.width/2.0, [UIScreen mainScreen].bounds.size.width/2.0)];
    [m_background setSize:CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)];
}

- (void)update:(float)dt{}

- (void)render{
    if (m_background)
        [m_background render];
}

- (void)touchesBegan:(CGPoint)touchPoint{}
- (void)touchesMoved:(CGPoint)touchPoint{}
- (void)touchesEnded:(CGPoint)touchPoint{}

@end
