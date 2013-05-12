//
//  SceneManager.h
//  gamegl
//
//  Created by iNghia on 5/12/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CGScene.h"

@interface SceneManager : NSObject

@property (nonatomic, retain) CGScene *currentScene;
@property (nonatomic, retain) NSMutableDictionary *gameSceneDict;

+ (SceneManager*) sharedInstance;
- (BOOL)changeToScene:(NSString *)sceneKey;
- (BOOL)addScene:(NSString *)key andScene:(CGScene *)newScene;

@end
