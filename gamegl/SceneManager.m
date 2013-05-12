//
//  SceneManager.m
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "SceneManager.h"

@implementation SceneManager

@synthesize currentScene = m_currentScene;
@synthesize gameSceneDict = m_gameSceneDict;

+ (SceneManager*)sharedInstance {
    __strong static SceneManager* sharedSceneManager = nil;
    static dispatch_once_t onceQueue=0;
    
    dispatch_once(&onceQueue, ^{
        sharedSceneManager = [[self alloc] init];
        [sharedSceneManager setCurrentScene:nil];
        sharedSceneManager.gameSceneDict = [NSMutableDictionary dictionary];
        
    });
    return sharedSceneManager;
}

- (BOOL)changeToScene:(NSString *)sceneKey {
    CGScene *s = [m_gameSceneDict objectForKey:sceneKey];
    if (s) {
        m_currentScene = s;
        return YES;
    }
    return NO;
}

- (BOOL)addScene:(NSString *)key andScene:(CGScene *)newScene {
    if (![m_gameSceneDict objectForKey:key]) {
        [m_gameSceneDict setObject:newScene forKey:key];
        return YES;
    }
    return NO;
}

@end
