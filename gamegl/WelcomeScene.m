//
//  WelcomeScene.m
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "WelcomeScene.h"
#import "MainScene.h"
#import "SceneManager.h"

@implementation WelcomeScene

- (void)update:(float)dt {
    
}

- (void)render {
    
}

- (void)touchesBegan:(CGPoint)touchPoint {
    NSLog(@"Go to main scene");
    [[SceneManager sharedInstance] addScene:@"mainscene" andScene:[[MainScene alloc] initWithEffect:[super effect]]];
    [[SceneManager sharedInstance] changeToScene:@"mainscene"];
}

@end
