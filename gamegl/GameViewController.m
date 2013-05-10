//
//  GameViewController.m
//  gamegl
//
//  Created by iNghia on 5/9/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "GameViewController.h"
#import "Common.h"
#import "Ball.h"

@interface GameViewController () {
    BOOL m_ballmoving;
    Ball* m_smovingBall;
    Ball* m_dmovingBall;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic, strong) NSMutableArray *ballIndexArray;
@property (nonatomic, strong) NSMutableArray *ballArray;
@property (nonatomic, strong) Ball *movingBall;

@end

@implementation GameViewController

@synthesize context = m_context;
@synthesize effect = m_effect;

@synthesize ballIndexArray = m_ballIndexArray;
@synthesize ballArray = m_ballArray;
@synthesize movingBall = m_movingBall;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    m_context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!m_context)
        NSLog(@"Failed to create OpenGLES2 context");
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    self.preferredFramesPerSecond  = 60;
    [EAGLContext setCurrentContext:m_context];
    
    m_effect = [[GLKBaseEffect alloc] init];
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0,
                                                      DEVICE_WIDTH,
                                                      0,
                                                      DEVICE_HEIGHT,
                                                      -1000.0,
                                                      1000.0);
    
    m_effect.transform.projectionMatrix = projectionMatrix;
    float ballDiameter = DEVICE_WIDTH/NUMBER_OF_BALL_IN_ROW;
    
    m_ballmoving = NO;
    m_smovingBall = nil;
    m_dmovingBall = nil;
    
    m_ballIndexArray = [NSMutableArray array];
    m_ballArray = [NSMutableArray array];
       
    Ball *b;
    NSString *ballColor;
    int ballType;
    
    for (int i =0; i < NUMBER_OF_BALL_IN_ROW*NUMBER_OF_ROW; i++) {
        switch (rand()%4) {
            case 0:
                ballColor = @"green-ball.png";
                ballType = GREEN_BALL;
                break;
            case 1:
                ballColor = @"red-ball.png";
                ballType = RED_BALL;
                break;
            case 2:
                ballColor = @"orange-ball.png";
                ballType = ORANGE_BALL;
                break;
            case 3:
            default:
                ballColor = @"blue-ball.png";
                ballType = BLUE_BALL;
                break;
        }
        b = [[Ball alloc] initWithTexture:ballColor effect:m_effect];
        b.currentCell = i;
        b.ballType = ballType;
        b.size = CGSizeMake(ballDiameter, ballDiameter);
        b.pos = GLKVector2Make((i%NUMBER_OF_BALL_IN_ROW)*ballDiameter + ballDiameter/2, (i/NUMBER_OF_BALL_IN_ROW)*ballDiameter + ballDiameter/2);
        [m_ballArray addObject:b];
        [m_ballIndexArray addObject: [NSNumber numberWithInt:b.currentCell]];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - GLKViewDelegate
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    
    // update
    for (Ball *e in m_ballArray) {
        [e update:self.timeSinceLastDraw];
    }
    [m_movingBall update:self.timeSinceLastDraw];
    //NSLog(@"Elapse time: %f", self.timeSinceLastDraw);
    
    // clear color
    glClearColor(0.0, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    // blend
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
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

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (m_ballmoving) {
        m_ballmoving = NO;
        [self checkPlusPoint];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch locationInView:self.view];
    
    if(m_ballmoving) {
        float x = endPoint.x;
        float y = DEVICE_HEIGHT - endPoint.y;
        //m_movingBall.pos = GLKVector2Make(x, y);
        float ballDiameter = DEVICE_WIDTH/NUMBER_OF_BALL_IN_ROW;
        float dx = x - (m_movingBall.currentCell%NUMBER_OF_BALL_IN_ROW)*ballDiameter - ballDiameter/2;
        float dy = y - (m_movingBall.currentCell/NUMBER_OF_BALL_IN_ROW)*ballDiameter - ballDiameter/2;
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

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.paused = !self.paused;
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self.view];
    NSLog(@"touchesBegan: x = %f, y = %f", p.x, p.y);
    
    float ballDiameter = DEVICE_WIDTH/NUMBER_OF_BALL_IN_ROW;
    int i = p.x/ballDiameter;
    int j = (DEVICE_HEIGHT-p.y)/ballDiameter;

    if (j < NUMBER_OF_ROW) {
        m_ballmoving = YES;
        m_movingBall = [self getBallAtCell:(j*NUMBER_OF_BALL_IN_ROW + i)];
    }
}

- (Ball*)getBallAtCell:(int)cellId {
    return [m_ballArray objectAtIndex:[[m_ballIndexArray objectAtIndex:cellId] intValue]];
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

#pragma mark - point checking
- (void)checkPlusPoint {
    
}

@end
