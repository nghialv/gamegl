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

- (int)checkPlusPoint;
- (void)addNewBall;

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
    int index = [[m_ballIndexArray objectAtIndex:cellId] intValue];
    if (index == -1)
        return nil;
    return [m_ballArray objectAtIndex:index];
}

- (int)getBallTypeAtCell:(int)cellId {
    int index = [[m_ballIndexArray objectAtIndex:cellId] intValue];
    if (index == -1)
        return -1;
    return [[m_ballArray objectAtIndex:index] ballType];
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
- (int)checkPlusPoint {
    int sumPoint = 0, point, preType, curType, curCell;
    BOOL markBall[NUMBER_OF_ROW*NUMBER_OF_BALL_IN_ROW] = {NO};
    
    // hor
    for (int i=0; i<NUMBER_OF_ROW; i++) {
        point = 0;
        preType = -1;
        for (int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            curCell = i*NUMBER_OF_BALL_IN_ROW+j;
            curType = [self getBallTypeAtCell:curCell];
            if (curType == preType && curType != -1)
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
            if (curType == preType && curType != -1)
                point++;
            else {
                if (point > 1) {
                    NSLog(@"col: %d : point = %d", i, point+1);
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
        if (markBall[i]) {
            [[self getBallAtCell:i] setDisplay:NO];
            [m_ballIndexArray setObject:[NSNumber numberWithInt:-1] atIndexedSubscript:i];
        }
        // add effect
    }
    NSLog(@"After check");
    [self showTable];
    NSLog(@"After resort");
    
    // resort table
    if (sumPoint > 0)
        [self resortTable];
    return sumPoint;
}

- (void)resortTable {
    Ball *curBall = nil;
    for(int i = 0; i < NUMBER_OF_BALL_IN_ROW; i++) {
        for(int j=1; j < NUMBER_OF_ROW; j++) {
            curBall = [self getBallAtCell:j*NUMBER_OF_BALL_IN_ROW+i];
            if (curBall)
                [self moveBallDown:curBall];
        }
    }
    [self showTable];
}

- (void)showTable{
    for(int i=NUMBER_OF_ROW-1; i>=0; i--) {
        for(int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            printf("%2d(%2d)    ", [self getBallTypeAtCell:i*NUMBER_OF_BALL_IN_ROW+j],
                   [[m_ballIndexArray objectAtIndex:i*NUMBER_OF_BALL_IN_ROW+j] intValue]);
        }
        NSLog(@"A");
    }
}

- (void)addNewBall {
    [self showTable];
    int curCell;
    for (int i=0; i<NUMBER_OF_ROW; i++) {
        for (int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            curCell = i*NUMBER_OF_BALL_IN_ROW+j;
            if ([[m_ballIndexArray objectAtIndex:curCell] intValue] == -1) {
                int ballType = [self generateBallTypeAtCell:curCell];
                int freeBallIndex = [self getFreeBallIndex];
                if (freeBallIndex!=-1) {
                    Ball *b = [m_ballArray objectAtIndex:freeBallIndex];
                    [b setPos:[self getPosAtCell:curCell]];
                    [b setCurrentCell:curCell];
                    [b setBallType:ballType];
                    [b setDisplay:YES];
                    switch (ballType) {
                        case GREEN_BALL:
                            [b setTexture:@"green-ball.png"];
                            break;
                        case RED_BALL:
                            [b setTexture:@"red-ball.png"];
                            break;
                        case BLUE_BALL:
                            [b setTexture:@"blue-ball.png"];
                            break;
                        case ORANGE_BALL:
                            [b setTexture:@"orange-ball.png"];
                            break;
                        default:
                            break;
                    }
                    [m_ballIndexArray setObject:[NSNumber numberWithInt:freeBallIndex] atIndexedSubscript:curCell];
                }
            }
        }
    }
}

- (int)getFreeBallIndex {
    for (int i=0; i<[m_ballArray count]; i++) {
        Ball *b = [m_ballArray objectAtIndex:i];
        if(!b.display)
            return i;
    }
    return -1;
}

- (GLKVector2)getPosAtCell:(int)cellId {
    float ballDiameter = BALL_DIAMETER;
    return GLKVector2Make((cellId%NUMBER_OF_BALL_IN_ROW)*ballDiameter + ballDiameter/2, (cellId/NUMBER_OF_BALL_IN_ROW)*ballDiameter + ballDiameter/2);
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
        NSLog(@"Touch ended");
        [self showTable];
        int point;
        int sumPoint = 0;

        while ((point = [self checkPlusPoint]) > 0) {
            NSLog(@"CALCULATE POINT");
            sumPoint += point;
        }
        if (sumPoint > 0) {
            [NSTimer scheduledTimerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(addNewBall)
                                           userInfo:nil
                                            repeats:NO];
        }
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
    [self showTable];
    NSLog(@"Moving From: [%d, %d] To: [%d, %d]", cellId/NUMBER_OF_BALL_IN_ROW,
          cellId%NUMBER_OF_BALL_IN_ROW,
          desCellId/NUMBER_OF_BALL_IN_ROW,
          desCellId%NUMBER_OF_BALL_IN_ROW);
    
    int cIndex = [[m_ballIndexArray objectAtIndex:cellId] intValue];
    int dIndex = [[m_ballIndexArray objectAtIndex:desCellId] intValue];
    
    m_smovingBall = [m_ballArray objectAtIndex: cIndex];
    m_dmovingBall = [m_ballArray objectAtIndex: dIndex];
    
    m_smovingBall.currentCell = desCellId;
    [m_ballIndexArray setObject:[NSNumber numberWithInt:cIndex] atIndexedSubscript:m_smovingBall.currentCell];
    m_dmovingBall.currentCell = cellId;
    [m_ballIndexArray setObject:[NSNumber numberWithInt:dIndex] atIndexedSubscript:m_dmovingBall.currentCell];
    [self showTable];
}

- (void)moveBallDown:(Ball*)ball {
    int i = ball.currentCell%NUMBER_OF_BALL_IN_ROW;
    int j = ball.currentCell/NUMBER_OF_BALL_IN_ROW;
    int desCell = -1;
    for (int k=0; k<j; k++) {
        if ([[m_ballIndexArray objectAtIndex:k*NUMBER_OF_BALL_IN_ROW+i] intValue] == -1) {
            desCell = k*NUMBER_OF_BALL_IN_ROW+i;
            break;
        }
    }
    if (desCell != -1) {
        [ball moveDownFromHere:[self getPosAtCell:desCell] andDuration:0.2];
        [m_ballIndexArray setObject:[NSNumber numberWithInt:-1]
                 atIndexedSubscript:ball.currentCell];
        [ball setCurrentCell:desCell];
        [m_ballIndexArray setObject:[NSNumber numberWithInteger:[m_ballArray indexOfObject:ball]]
                 atIndexedSubscript:desCell];
    }
}

@end
