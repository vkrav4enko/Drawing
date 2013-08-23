//
//  ViewController.m
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "ViewController.h"
#import "Line.h"
#import "Angle.h"
#import "Curve.h"
#import "CIrcle.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableArray *angles;
@property (nonatomic, strong) NSMutableArray *circles;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *curves;
@property (nonatomic) BOOL isCircle;
@property (nonatomic) BOOL isLine;
@property (nonatomic) BOOL isAngle;
@property (nonatomic) BOOL isCurve;
@property (nonatomic) BOOL deleteMode;

- (IBAction)drawLine:(id)sender;
- (IBAction)drawAngle:(id)sender;
- (IBAction)drawCircle:(id)sender;
- (IBAction)drawCurve:(id)sender;
- (IBAction)deleteMode:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.lines = [NSMutableArray new];
    self.angles = [NSMutableArray new];
    self.circles = [NSMutableArray new];
    self.curves = [NSMutableArray new];
    self.points = [NSMutableArray new];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    for(UITouch *touch in touches)
    {
        // check if a starting/ending point is near the current touch
        CGPoint point = [touch locationInView:self.view];
        int i = 0;
        for (Line *line in _lines)
        {
            _isLine = [line checkPoint:point withinRadius:10];
            if (_isLine)
            {                
                
                currentIndex = i;
                _currentTouch = touch;
                break;
            }
            i++;
        }
        
        i = 0;
        for (Angle *angle in _angles)
        {
            _isAngle = [angle checkPoint:point withinRadius:10];
            if (_isAngle)
            {
                NSLog (@"Angle show points");
                currentIndex = i;
                _currentTouch = touch;
                break;
            }
            i++;
        }
        
        i = 0;
        for (Curve *curve in _curves)
        {
            _isCurve = [curve checkPoint:point withinRadius:10];
            if (_isCurve)
            {
                NSLog (@"Curve show points");
                currentIndex = i;
                _currentTouch = touch;
                break;
            }
            i++;
        }
        
        i = 0;
        for (CIrcle *circle in _circles)
        {
            _isCircle = [circle checkPoint:point withinRadius:20];
            if (_isCircle)
            {
                NSLog (@"Circle show points");
                currentIndex = i;
                _currentTouch = touch;
                break;
            }
            i++;
        }
        
    }
    [self showPoints];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        if(t != self.currentTouch) continue;        
        CGPoint p = [t locationInView:self.view];
        if (_isLine)
        {
            Line *line = [_lines objectAtIndex:currentIndex];
            
            if (line.pointToChange)
            {
                *line.pointToChange = p;
                [line setupLayer];
                break;
            }
            
        }
        
        if (_isAngle)
        {
            Angle *angle = [_angles objectAtIndex:currentIndex];
            
            if (angle.pointToChange)
            {
                *angle.pointToChange = p;
                [angle setupLayer];
                break;
            }
        }
        
        if (_isCurve)
        {
            Curve *curve = [_curves objectAtIndex:currentIndex];
            
            if (curve.pointToChange)
            {
                *curve.pointToChange = p;
                [curve setupLayer];
                break;
            }
        }
        
        if (_isCircle)
        {
            CIrcle *circle = [_circles objectAtIndex:currentIndex];
            if (circle.pointToChange)
            {
                *circle.pointToChange = p;
                [circle setupLayer];
                break;
            }
            else
            {
                float dx, dy;
                dx = p.x - circle.centerPoint.x;
                dy = p.y - circle.centerPoint.y;
                circle.radius = sqrtf(dx*dx + dy*dy);
                [circle setupLayer];
                break;
            }
        }
    }
    [self showPoints];
}

- (void) showPoints
{
    for (CAShapeLayer *layer in _points)
    {
        [layer removeFromSuperlayer];
    }
    [_points removeAllObjects];
    
    if (_isLine)
    {
        Line *line = [_lines objectAtIndex:currentIndex];
        [self showPoints:line.startPoint, line.endPoint, CGPointZero];
    }
    if (_isAngle)
    {
        Angle *angle = [_angles objectAtIndex:currentIndex];
        [self showPoints:angle.startPoint, angle.anglePoint, angle.endPoint, CGPointZero];
    }
    if (_isCurve)
    {
        Curve *curve = [_curves objectAtIndex:currentIndex];
        [self showPoints:curve.startPoint, curve.endPoint, curve.firstHelper, curve.secondHelper, CGPointZero];        
    }
    if (_isCircle)
    {
        CIrcle *circle = [_circles objectAtIndex:currentIndex];
        [self showPoints:circle.centerPoint, [_currentTouch locationInView:self.view], CGPointZero];
    }
        
}

- (void) showPoints: (CGPoint) point, ...
{
    va_list argumentList;
    va_start(argumentList, point);
    CGPoint argPoint = point;
    while (!CGPointEqualToPoint(argPoint, CGPointZero) ) {
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = [[UIColor blackColor] CGColor];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(argPoint.x - 3, argPoint.y - 3, 6, 6)
                                                        cornerRadius:3];
        layer.path = [path CGPath];
        [_points addObject:layer];
        [self.view.layer addSublayer:layer];
        argPoint = va_arg(argumentList, CGPoint);
    }    
    
    va_end(argumentList);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawLine:(id)sender {
    CGPoint startPoint = CGPointMake(600, 400);
    CGPoint endPoint = CGPointMake(50, 300);
    Line *line = [[Line alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [_lines addObject:line];
    [self.view addSubview:line];  
    
    //[self showAll];

}

- (IBAction)drawAngle:(id)sender {
    Angle *angle = [[Angle alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [_angles addObject:angle];
    [self.view addSubview:angle];
}

- (IBAction)drawCircle:(id)sender {
    CIrcle *circle = [[CIrcle alloc] initWithFrame:CGRectMake (0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [_circles addObject:circle];
    [self.view addSubview:circle];
}

- (IBAction)drawCurve:(id)sender {
    Curve *curve = [[Curve alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [_curves addObject:curve];
    [self.view addSubview:curve];
}

- (IBAction)deleteMode:(id)sender {
    _deleteMode = !_deleteMode;
    [_deleteButton setTitleColor: _deleteMode? [UIColor redColor] : [UIColor blueColor] forState:UIControlStateNormal ];
}
@end
