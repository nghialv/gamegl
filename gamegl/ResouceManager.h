//
//  ResouceManager.h
//  gamegl
//
//  Created by iNghia on 5/10/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface ResouceManager : NSObject

+ (ResouceManager*) sharedInstance;
- (GLKTextureInfo *)getTextureInfo:(NSString*)filePath;

@end
