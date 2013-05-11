//
//  BallTable.m
//  gamegl
//
//  Created by iNghia on 5/11/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "BallTable.h"
#import "Common.h"
#import "Ball.h"

@interface BallTable() {
    BOOL m_ballmoving;
    Ball* m_smovingBall;
    Ball* m_dmovingBall;
}

@property (nonatomic, strong) NSMutableArray *ballIndexArray;
@property (nonatomic, strong) NSMutableArray *ballArray;
@property (nonatomic, strong) Ball *movingBall;

@end

// implementation
@implementation BallTable

@synthesize ballIndexArray = m_ballIndexArray;
@synthesize ballArray = m_ballArray;
@synthesize movingBall = m_movingBall;

+ (BallTable*)sharedInstance {
    __strong static BallTable* sharedBallTable = nil;
    static dispatch_once_t onceQueue=0;
    
    dispatch_once(&onceQueue, ^{
        sharedBallTable = [[self alloc] init];
    });
    return sharedBallTable;
}

- (void)initilize:(GLKBaseEffect *)effect {
    m_ballmoving = NO;
    m_smovingBall = nil;
    m_dmovingBall = nil;
    
    m_ballIndexArray = [NSMutableArray array];
    for (int i = 0; i < NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
        [m_ballIndexArray addObject:[NSNumber numberWithInt:-1]];
    }
    
    m_ballArray = [NSMutableArray array];
    
    Ball *b;
    NSString *ballColor;
    int ballType;
    
    for (int i =0; i < NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
        switch ([self generateBallTypeAtCell:i]) {
            case RED_BALL:
                ballColor = @"red-ball.png";
                ballType = RED_BALL;
                break;
            case GREEN_BALL:
                ballColor = @"green-ball.png";
                ballType = GREEN_BALL;
                break;
            case BLUE_BALL:
                ballColor = @"blue-ball.png";
                ballType = BLUE_BALL;
                break;
            case ORANGE_BALL:
            default:
                ballColor = @"orange-ball.png";
                ballType = ORANGE_BALL;
                break;
        }
        b = [[Ball alloc] initWithTexture:ballColor effect:effect];
        b.currentCell = i;
        b.ballType = ballType;
        b.size = CGSizeMake(BALL_DIAMETER, BALL_DIAMETER);
        b.pos = GLKVector2Make((i%NUMBER_OF_BALL_IN_ROW)*BALL_DIAMETER + BALL_DIAMETER/2,
                               (i/NUMBER_OF_BALL_IN_ROW)*BALL_DIAMETER + BALL_DIAMETER/2);
        [m_ballArray addObject:b];
        [m_ballIndexArray setObject:[NSNumber numberWithInt:b.currentCell] atIndexedSubscript:i];
    }
}

- (void)update:(float)dt {
    for (Ball *e in m_ballArray) {
        [e update:dt];
    }
    if (m_movingBall)
        [m_movingBall update:dt];
}

- (void)render {
    // draw entities
    for (Ball *e in m_ballArray) {
        [e render];
    }
    
    // draw moving ball
    if(m_movingBall)
        [m_movingBall render];
    if(m_smovingBall)
        [m_smovingBall render];
    if(m_dmovingBall)
        [m_dmovingBall render];
}

#pragma mark - get ball
- (Ball*)getBallAtCell:(int)cellId {
    return [m_ballArray objectAtIndex:[[m_ballIndexArray objectAtIndex:cellId] intValue]];
}

- (int)getBallTypeAtCell:(int)cellId {
    return [[m_ballArray objectAtIndex:[[m_ballIndexArray objectAtIndex:cellId] intValue]] ballType];
}

#pragma mark - gennerate ball for a cell
- (int)generateBallTypeAtCell:(int)cellId {
    int num= arc4random()%4;
    int l1=-1, l2=-1, d1=-1, d2=-1, r1 = -1, r2 = -1;
    
    if (cellId/NUMBER_OF_BALL_IN_ROW > 1) {
        d1 = [self getBallTypeAtCell:cellId-NUMBER_OF_BALL_IN_ROW];
        d2 = [self getBallTypeAtCell:cellId-2*NUMBER_OF_BALL_IN_ROW];
    }
    if (cellId%NUMBER_OF_BALL_IN_ROW > 1) {
        l1 = [self getBallTypeAtCell:cellId-1];
        l2 = [self getBallTypeAtCell:cellId-2];
    }
    if (l1 == l2 && num == l1) {
        num = (num+1)%4;
        if (d1 == d2 && num == d1)
            num = (num+1)%4;
    }else if (d1 == d2 && num == d1) {
        num = (num+1)%4;
        if (l1 == l2 && num == l1)
            num = (num+1)%4;
    }
    if (cellId%NUMBER_OF_BALL_IN_ROW < (NUMBER_OF_BALL_IN_ROW-2)) {
        if ([[m_ballIndexArray objectAtIndex:cellId+1] intValue] != -1 &&
            [[m_ballIndexArray objectAtIndex:cellId+2] intValue] != -1) {
            r1 = [self getBallTypeAtCell:cellId+1];
            r2 = [self getBallTypeAtCell:cellId+2];
            if (r1 == r2 && num == r1)
                num = (num+1)%4;
        }
    }
    return num;
}

#pragma mark - point calculate
- (void)checkPlusPoint {
    int sumPoint = 0, point, preType, curType, curCell;
    BOOL markBall[NUMBER_OF_ROW*NUMBER_OF_BALL_IN_ROW] = {NO};
    
    // hor
    for (int i=0; i<NUMBER_OF_ROW; i++) {
        point = 0;
        preType = -1;
        for (int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            curCell = i*NUMBER_OF_BALL_IN_ROW+j;
            curType = [self getBallTypeAtCell:curCell];
            if (curType == preType)
                point++;
            else {
                if (point > 1) {
                    NSLog(@"row: %d : point = %d", i, point+1);
                    sumPoint += (point +1);
                    for (int k = curCell-1; k>= curCell-point-1; k--)
                        markBall[k] = YES;
                }
                point = 0;
            }
            preType = curType;
        }
        if (point > 1) {
            NSLog(@"row: %d : point = %d", i, point+1);
            sumPoint += (point +1);
            for (int k = curCell; k>= curCell-point; k--)
                markBall[k] = YES;
        }
    }
    //ver
    for (int i=0; i<NUMBER_OF_BALL_IN_ROW; i++) {
        point = 0;
        preType = -1;
        for (int j=0; j<NUMBER_OF_ROW; j++) {
            curCell = j*NUMBER_OF_BALL_IN_ROW+i;
            curType = [self getBallTypeAtCell:curCell];
            if (curType == preType)
                point++;
            else {
                if (point > 1) {
                    NSLog(@"row: %d : point = %d", i, point+1);
                    sumPoint += (point +1);
                    for (int k = curCell-NUMBER_OF_BALL_IN_ROW; k>= curCell-(point+1)*NUMBER_OF_BALL_IN_ROW; k-= NUMBER_OF_BALL_IN_ROW)
                        markBall[k] = YES;
                }
                point = 0;
            }
            preType = curType;
        }
        if (point > 1) {
            NSLog(@"row: %d : point = %d", i, point+1);
            sumPoint += (point +1);
            for (int k = curCell; k>=curCell-point*NUMBER_OF_BALL_IN_ROW; k-=NUMBER_OF_BALL_IN_ROW)
                markBall[k] = YES;
        }
    }
    
    NSLog(@"sumPoint : %d", sumPoint);
    
    // remove ball
    for (int i=0; i<NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
        if (markBall[i])
            [[self getBallAtCell:i] setDisplay:NO];
    }
}

#pragma mark - event

- (void)touchesBegan:(CGPoint)touchPoint {
    NSLog(@"TouchPoint: %f %f", touchPoint.x, touchPoint.y);
    float ballDiameter = BALL_DIAMETER;
    int i = touchPoint.x/ballDiameter;
    int j = touchPoint.y/ballDiameter;
    
    if (j < NUMBER_OF_ROW) {
        NSLog(@"moving ball: %d", j*NUMBER_OF_BALL_IN_ROW + i);
        m_ballmoving = YES;
        m_movingBall = [self getBallAtCell:(j*NUMBER_OF_BALL_IN_ROW + i)];
    }
}

- (void)touchesMoved:(CGPoint)touchPoint {
    if(m_ballmoving) {
        float ballDiameter = BALL_DIAMETER;
        float dx = touchPoint.x - (m_movingBall.currentCell%NUMBER_OF_BALL_IN_ROW)*ballDiameter - ballDiameter/2;
        float dy = touchPoint.y - (m_movingBall.currentCell/NUMBER_OF_BALL_IN_ROW)*ballDiameter - ballDiameter/2;
        if (dx >= ballDiameter/2) {
            [self moveBallToRight:m_movingBall.currentCell];
        }
        else if (dx <= -ballDiameter/2) {
            [self moveBallToLeft:m_movingBall.currentCell];
        }
        else if (dy >= ballDiameter/2) {
            [self moveBallToUp:m_movingBall.currentCell];
        }
        else if (dy <= -ballDiameter/2) {
            [self moveBallToDown:m_movingBall.currentCell];
        }
    }
}

- (void)touchesEnded:(CGPoint)touchPoint {
    if (m_ballmoving) {
        m_ballmoving = NO;
        [self checkPlusPoint];
    }
}

#pragma mark - Ball moving

- (void)moveBallToRight:(int)cellId{
    if ((cellId+1) % NUMBER_OF_BALL_IN_ROW == 0)
        return;
    [self moveBall:cellId andDesCellId:cellId+1];
    
    [m_smovingBall moveRight];
    [m_dmovingBall moveLeft];
}

- (void)moveBallToLeft:(int)cellId{
    if (cellId % NUMBER_OF_BALL_IN_ROW == 0)
        return;
    [self moveBall:cellId andDesCellId:cellId-1];
    [m_smovingBall moveLeft];
    [m_dmovingBall moveRight];
}

- (void)moveBallToUp:(int)cellId{
    if ((cellId/NUMBER_OF_BALL_IN_ROW) == NUMBER_OF_ROW -1)
        return;
    [self moveBall:cellId andDesCellId:cellId+NUMBER_OF_BALL_IN_ROW];
    
    [m_smovingBall moveUp];
    [m_dmovingBall moveDown];
}

- (void)moveBallToDown:(int)cellId{
    if ((cellId/NUMBER_OF_BALL_IN_ROW) == 0)
        return;
    [self moveBall:cellId andDesCellId:cellId-NUMBER_OF_BALL_IN_ROW];
    [m_smovingBall moveDown];
    [m_dmovingBall moveUp];
}

- (void)moveBall:(int)cellId andDesCellId:(int)desCellId {
    int cIndex = [[m_ballIndexArray objectAtIndex:cellId] intValue];
    int dIndex = [[m_ballIndexArray objectAtIndex:desCellId] intValue];
    
    m_smovingBall = [m_ballArray objectAtIndex: cIndex];
    m_dmovingBall = [m_ballArray objectAtIndex: dIndex];
    
    m_smovingBall.currentCell = desCellId;
    [m_ballIndexArray setObject:[NSNumber numberWithInt:cIndex] atIndexedSubscript:m_smovingBall.currentCell];
    m_dmovingBall.currentCell = cellId;
    [m_ballIndexArray setObject:[NSNumber numberWithInt:dIndex] atIndexedSubscript:m_dmovingBall.currentCell];
}

@end
