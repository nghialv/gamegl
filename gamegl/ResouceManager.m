//
//  ResouceManager.m
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "ResouceManager.h"

@interface ResouceManager()

@property (nonatomic, retain) NSMutableDictionary *textureList;
@property (nonatomic, retain) NSMutableDictionary *soundList;

@end

@implementation ResouceManager

@synthesize textureList = m_textureList;
@synthesize soundList = m_soundList;

+ (ResouceManager*)sharedInstance {
    __strong static ResouceManager* sharedResoureManager = nil;
    static dispatch_once_t onceQueue=0;
    
    dispatch_once(&onceQueue, ^{
        sharedResoureManager = [[self alloc] init];
        sharedResoureManager.textureList = [NSMutableDictionary dictionary];
        sharedResoureManager.soundList = [NSMutableDictionary dictionary];
    });
    return sharedResoureManager;
}

- (GLKTextureInfo *)getTextureInfo:(NSString *)filePath {
    if (![m_textureList objectForKey:filePath]) {
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES],
                                 GLKTextureLoaderOriginBottomLeft,
                                 nil];
        NSString *path = [[NSBundle mainBundle] pathForResource:filePath ofType:nil];
        GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithContentsOfFile:path options:options error:nil];
        NSLog(@"Load texture: %@", filePath);
        if (!textureInfo) {
            NSLog(@"Error loading file¥n");
            return nil;
        }
        [m_textureList setObject:textureInfo forKey:filePath];
    }
    return [m_textureList objectForKey:filePath];
}

@end
