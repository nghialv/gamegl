//
//  Common.h
//  gamegl
//
//  Created by iNghia on 5/9/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#ifndef gamegl_Common_h
#define gamegl_Common_h

#define NUMBER_OF_BALL_IN_ROW 6
#define NUMBER_OF_ROW 5

#define TRANSLATE_DURATION 0.2

#define DEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define DEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define BALL_DIAMETER DEVICE_WIDTH/NUMBER_OF_BALL_IN_ROW

#define RED_BALL_FILE_NAME @"red-ball.png"
#define BLUE_BALL_FILE_NAME @"blue-ball.png"
#define GREEN_BALL_FILE_NAME @"green-ball.png"
#define ORANGE_BALL_FILE_NAME @"orange-ball.png"

enum BALL_TYPE{
    RED_BALL=0,
    GREEN_BALL,
    BLUE_BALL,
    ORANGE_BALL,
    NUMBER_OF_BALL_TYPE,
};

#endif
