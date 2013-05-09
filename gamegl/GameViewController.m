//
//  GameViewController.m
//  gamegl
//
//  Created by iNghia on 5/9/13.
//  Copyright (c) 2013 framgia. All rights reserved.
//

#import "GameViewController.h"
#import "Entity2.h"

@interface GameViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *effect;

@property (nonatomic, strong) NSMutableArray *ballArray;
@property (nonatomic, strong) Entity2 *movingBall;

@end

@implementation GameViewController

@synthesize context = m_context;
@synthesize effect = m_effect;

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
    
    int deviceWitdh = [UIScreen mainScreen].bounds.size.width;
    int deviceHeight = [UIScreen mainScreen].bounds.size.height;
    
    GLKMatrix4 projectionMatrix = GLKMatrix4MakeOrtho(0,
                                                      deviceWitdh,
                                                      0,
                                                      deviceHeight,
                                                      -1000.0,
                                                      1000.0);
    
    m_effect.transform.projectionMatrix = projectionMatrix;
    float ballDiameter = [UIScreen mainScreen].bounds.size.width/5;
    
    m_ballArray = [NSMutableArray array];
    
    m_movingBall = [[Entity2 alloc] initWithTexture:@"red-ball.png" effect:m_effect];
    m_movingBall.size = CGSizeMake(ballDiameter, ballDiameter);
    m_movingBall.pos = GLKVector2Make(ballDiameter/2, ballDiameter/2);
    
    Entity2 *b;
    NSString *ballColor;
    
    for (int i =1; i < 30; i++) {
        switch (rand()%4) {
            case 0:
                ballColor = @"green-ball.png";
                break;
            case 1:
                ballColor = @"red-ball.png";
                break;
            case 2:
                ballColor = @"orange-ball.png";
                break;
            case 3:
            default:
                ballColor = @"blue-ball.png";
                break;
        }
        b = [[Entity2 alloc] initWithTexture:ballColor effect:m_effect];
        b.size = CGSizeMake(ballDiameter, ballDiameter);
        b.pos = GLKVector2Make((i%5)*ballDiameter + ballDiameter/2, (i/5)*ballDiameter + ballDiameter/2);
        [m_ballArray addObject:b];
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
    for (Entity2 *e in m_ballArray) {
        [e update:1.0/60.0];
    }
    [m_movingBall update:1.0/60.0];
    
    // clear color
    glClearColor(0.0, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT|GL_DEPTH_BUFFER_BIT);
    // blend
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    
    
    // draw entities
    for (Entity2 *e in m_ballArray) {
        [e render];
    }
    
    // draw moving ball
    [m_movingBall render];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint endPoint = [touch locationInView:self.view];
    NSLog(@"endPoint x = %f, y = %f", endPoint.x, endPoint.y);
    //float x = endPoint.x;
    //float y = [UIScreen mainScreen].bounds.size.height - endPoint.y;
    //m_movingBall.pos = GLKVector2Make(x, y);
}

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //self.paused = !self.paused;
    UITouch *touch = [touches anyObject];
    CGPoint p = [touch locationInView:self.view];
    NSLog(@"touchesBegan: x = %f, y = %f", p.x, p.y);
    //float x = p.x;
    //float y = [UIScreen mainScreen].bounds.size.height - p.y;
    //m_movingBall.pos = GLKVector2Make(x, y);
    [m_movingBall moveUp:400 andDuration:0.5];
}

@end
