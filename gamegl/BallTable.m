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
    Texture2 *m_background;
    NSTimer *m_pointCalculateTimer;
    BOOL m_checkingPoint;
    int m_checkingCount;
}

@property (nonatomic, strong) GLKBaseEffect *effect;
@property (nonatomic, strong) NSMutableArray *ballIndexArray;
@property (nonatomic, strong) NSMutableArray *ballArray;
@property (nonatomic, strong) Ball *movingBall;

- (int)checkPlusPoint;
- (void)addNewBall;

@end

// implementation
@implementation BallTable

@synthesize effect = m_effect;
@synthesize ballIndexArray = m_ballIndexArray;
@synthesize ballArray = m_ballArray;
@synthesize movingBall = m_movingBall;


- (id)initWithEffect:(GLKBaseEffect*)effect {
    if (self = [super init]) {
        m_effect = effect;
        m_ballmoving = NO;
        m_smovingBall = nil;
        m_dmovingBall = nil;
        m_pointCalculateTimer = nil;
        m_checkingPoint = NO;
        
        m_ballIndexArray = [NSMutableArray array];
        for (int i = 0; i < NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
            [m_ballIndexArray addObject:[NSNumber numberWithInt:-1]];
        }
    
        float ballDiameter = BALL_DIAMETER;
    
        // setbackground
        m_background = [[Texture2 alloc] initWithTexture:BALL_TABLE_BACKGROUND effect:m_effect];
        [m_background setPos:GLKVector2Make(ballDiameter*NUMBER_OF_BALL_IN_ROW/2, ballDiameter*NUMBER_OF_ROW/2)];
        [m_background setSize:CGSizeMake(ballDiameter*NUMBER_OF_BALL_IN_ROW, ballDiameter*NUMBER_OF_ROW)];
    
        m_ballArray = [NSMutableArray array];
        Ball *b;
        NSString *ballColor;
        int ballType;
    
        for (int i =0; i < NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
            switch ([self generateBallTypeAtCell:i]) {
                case RED_BALL:
                    ballColor = RED_BALL_FILE_NAME;
                    ballType = RED_BALL;
                    break;
                case GREEN_BALL:
                    ballColor = GREEN_BALL_FILE_NAME;
                    ballType = GREEN_BALL;
                    break;
                case BLUE_BALL:
                    ballColor = BLUE_BALL_FILE_NAME;
                    ballType = BLUE_BALL;
                    break;
                case ORANGE_BALL:
                default:
                    ballColor = ORANGE_BALL_FILE_NAME;
                    ballType = ORANGE_BALL;
                    break;
            }
            b = [[Ball alloc] initWithTexture:ballColor effect:m_effect];
            b.ballType = ballType;
            b.size = CGSizeMake(ballDiameter, ballDiameter);
            b.pos = [self getPosAtCell:i];
            
            [m_ballArray addObject:b];
            [self setBallAtCell:b atCell:i];
        }
    }
    return self;
}

- (void)update:(float)dt {
    for (Ball *e in m_ballArray) {
        [e update:dt];
    }
    if (m_movingBall)
        [m_movingBall update:dt];
}

- (void)render {
    // render background
    [m_background render];
    // render entities
    for (Ball *e in m_ballArray) {
        if (e != m_smovingBall && e != m_dmovingBall)
            [e render];
    }
    // render moving ball
    if(m_movingBall)
        [m_movingBall render];
    if(m_smovingBall)
        [m_smovingBall render];
    if(m_dmovingBall)
        [m_dmovingBall render];
}

#pragma mark - event
- (void)touchesBegan:(CGPoint)touchPoint {
    float ballDiameter = BALL_DIAMETER;
    int i = touchPoint.x/ballDiameter;
    int j = touchPoint.y/ballDiameter;
    
    if (j < NUMBER_OF_ROW && !m_checkingPoint) {
        m_ballmoving = YES;
        m_movingBall = [self getBallAtCell:(j*NUMBER_OF_BALL_IN_ROW + i)];
    }
}

- (void)touchesMoved:(CGPoint)touchPoint {
    if(m_ballmoving && !m_checkingPoint) {
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
    if (m_ballmoving && !m_checkingPoint) {
        //[self showTable];
        m_checkingPoint = YES;
        m_checkingCount = 0;
        [self checkPlusPoint];
    }
}

#pragma mark - point calculate
- (int)checkPlusPoint {
    [self showTable];
    
    [self stopAllBalls];
    
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
    
    m_checkingCount++;
    NSLog(@"Checking Count: %d", m_checkingPoint);
    
    // resort table
    if (sumPoint > 0) {
        [NSTimer scheduledTimerWithTimeInterval:0.5
                                         target:self
                                       selector:@selector(resortTable)
                                       userInfo:nil
                                        repeats:NO];
    }
    else if (m_checkingCount > 1) {
        m_checkingCount = 0;
        NSLog(@"Add new ball");
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                         target:self
                                       selector:@selector(addNewBall)
                                       userInfo:nil
                                        repeats:NO];
    }else
        m_checkingPoint = NO;
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
    [NSTimer scheduledTimerWithTimeInterval:BALL_DOWN_DURATION
                                     target:self
                                   selector:@selector(checkPlusPoint)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)addNewBall {
    //[self showTable];
    
    int curCell;
    for (int i=0; i<NUMBER_OF_ROW; i++) {
        for (int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            curCell = i*NUMBER_OF_BALL_IN_ROW+j;
            if ([[m_ballIndexArray objectAtIndex:curCell] intValue] == -1) {
                int ballType = [self generateBallTypeAtCell:curCell];
                int freeBallIndex = [self getFreeBallIndex];
                Ball *b;
                if (freeBallIndex!=-1)
                    b = [m_ballArray objectAtIndex:freeBallIndex];
                else {
                    b = [[Ball alloc] initWithTexture:GREEN_BALL_FILE_NAME effect:m_effect];
                    [m_ballArray addObject:b];
                }
                switch (ballType) {
                    case GREEN_BALL:
                        [b setTexture:GREEN_BALL_FILE_NAME];
                        break;
                    case RED_BALL:
                        [b setTexture:RED_BALL_FILE_NAME];
                        break;
                    case BLUE_BALL:
                        [b setTexture:BLUE_BALL_FILE_NAME];
                        break;
                    case ORANGE_BALL:
                    default:
                        [b setTexture:ORANGE_BALL_FILE_NAME];
                        break;
                }
                
                b.ballType = ballType;
                b.size = CGSizeMake(BALL_DIAMETER, BALL_DIAMETER);
                b.pos = [self getPosAtCell:curCell];
                [b setDisplay:YES];
                
                [self setBallAtCell:b atCell:curCell];
            }
        }
    }
    
    NSLog(@"Added new ball");
    m_ballmoving = NO;
    m_checkingPoint = NO;
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

- (void)setBallAtCell:(Ball*)ball atCell:(int)cellIndex {
    ball.currentCell = cellIndex;
    [m_ballIndexArray setObject:[NSNumber numberWithInt:[m_ballArray indexOfObject:ball]] atIndexedSubscript:cellIndex];
}

#pragma mark - gennerate ball for a cell
- (int)generateBallTypeAtCell:(int)cellId {
    int num= arc4random()%NUMBER_OF_BALL_TYPE;
    int l1=-1, l2=-1, d1=-1, d2=-1, r1 = -1, r2 = -1;
    
    if (cellId/NUMBER_OF_BALL_IN_ROW > 1) {
        d1 = [self getBallTypeAtCell:cellId-NUMBER_OF_BALL_IN_ROW];
        d2 = [self getBallTypeAtCell:cellId-2*NUMBER_OF_BALL_IN_ROW];
    }
    if (cellId%NUMBER_OF_BALL_IN_ROW > 1) {
        l1 = [self getBallTypeAtCell:cellId-1];
        l2 = [self getBallTypeAtCell:cellId-2];
    }
    if (cellId%NUMBER_OF_BALL_IN_ROW < (NUMBER_OF_BALL_IN_ROW-2)) {
        r1 = [self getBallTypeAtCell:cellId+1];
        r2 = [self getBallTypeAtCell:cellId+2];
    }
    
    NSMutableArray *except = [NSMutableArray array];
    if(l1 == l2 && l1 != -1)
        [except addObject:[NSNumber numberWithInt:l1]];
    if(d1 == d2 && d1 != -1)
        [except addObject:[NSNumber numberWithInt:d1]];
    if(r1 == r2 && r1 != -1)
        [except addObject:[NSNumber numberWithInt:r1]];
    if(l1 == r1 && l1 != -1)
        [except addObject:[NSNumber numberWithInt:l1]];
    
    while ([except containsObject:[NSNumber numberWithInt:num]]) {
        num = (num+1)%NUMBER_OF_BALL_TYPE;
    }
    
    return num;
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
    m_smovingBall = [self getBallAtCell:cellId];
    m_dmovingBall = [self getBallAtCell:desCellId];
    [self setBallAtCell:m_smovingBall atCell:desCellId];
    [self setBallAtCell:m_dmovingBall atCell:cellId];
    NSLog(@"move from [%d %d] --> [%d %d]",
          cellId/NUMBER_OF_BALL_IN_ROW,
          cellId%NUMBER_OF_BALL_IN_ROW,
          desCellId/NUMBER_OF_BALL_IN_ROW,
          desCellId%NUMBER_OF_BALL_IN_ROW);
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
        [m_ballIndexArray setObject:[NSNumber numberWithInt:-1]
                 atIndexedSubscript:ball.currentCell];
        [self setBallAtCell:ball atCell:desCell];
        [ball moveDownFromHere:[self getPosAtCell:desCell] andDuration:BALL_DOWN_DURATION];
    }
}

- (void)stopAllBalls {
    for (Ball *b in m_ballArray) {
        [b stopMoving];
    }
}

#pragma mark- debug
- (void)showTable{
    for(int i=NUMBER_OF_ROW-1; i>=0; i--) {
        for(int j=0; j<NUMBER_OF_BALL_IN_ROW; j++) {
            printf("%2d(%2d)    ", [self getBallTypeAtCell:i*NUMBER_OF_BALL_IN_ROW+j],
                   [[m_ballIndexArray objectAtIndex:i*NUMBER_OF_BALL_IN_ROW+j] intValue]);
        }
        NSLog(@"A");
    }
}

@end
