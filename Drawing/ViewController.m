//
//  ViewController.m
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "ViewController.h"
#import "Circle.h"
#import "ShapeView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) NSMutableArray *points;

@property (nonatomic, strong) ShapeView *line;
@property (nonatomic, strong) Circle *circle;
@property (nonatomic) BOOL isCircle;
@property (nonatomic) BOOL isLine;
@property (nonatomic) BOOL drawCurveMode;
@property (nonatomic) BOOL eraserMode;
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
    self.points = [NSMutableArray new];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isLine = NO;
    _isCircle = NO;    
    for(UITouch *touch in touches)
    {
        // check if a starting/ending point is near the current touch
        CGPoint point = [touch locationInView:self.view];
        _isLine = [_line checkPoint:point withinRadius:20];
        if (_isLine)
        {
            _currentTouch = touch;
            break;
        }
        
        _isCircle = [_circle checkPoint:point withinRadius:20];
        if (_isCircle)
        {
            _currentTouch = touch;
            break;
        }
      
    }    
    [self showPoints];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_drawCurveMode || _eraserMode)
    {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        [_line.points addObject:[NSValue valueWithCGPoint:currentPoint]];
        [_line setupLayer];
    }
    else
    {
        for(UITouch *t in touches)
        {
            if(t != self.currentTouch) continue;        
            CGPoint p = [t locationInView:self.view];
            if (_isLine)
            {
                if (!CGPointEqualToPoint(_line.pointToChange, CGPointZero))
                {
                    [_line movePoint:p];                    
                }                
            }       
            if (_isCircle)
            {
                if (_circle.pointToChange)
                {
                    *_circle.pointToChange = p;
                    [_circle setupLayer];
                    break;
                }
                else
                {
                    float dx, dy;
                    dx = p.x - _circle.centerPoint.x;
                    dy = p.y - _circle.centerPoint.y;
                    _circle.radius = sqrtf(dx*dx + dy*dy);
                    [_circle setupLayer];
                    break;
                }
            }
        }
    }
   [self showPoints];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    _drawCurveMode = NO;
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
        if (_line.points.count < 4)
            [self showPoints:_line.points];
        else
        {
            if (_eraserMode == NO)
                [self showPoints:@[[_line.points objectAtIndex:0]]];
        }
    }
    if (_isCircle)
    {        
        [self showPoints:@[[NSValue valueWithCGPoint:_circle.centerPoint], [NSValue valueWithCGPoint:_circle.pointToChange? CGPointZero : [self findPointOnCircumferenceByTouchPoint: [_currentTouch locationInView:_imageView]]]]];
    }        
}

- (CGPoint) findPointOnCircumferenceByTouchPoint: (CGPoint) point
{
    CGPoint currentPoint;
    float minDistance = 20;
    for (float angle = 0; angle < 360; angle ++)
    {
        float dx, dy;
        float x = _circle.radius * cosf(angle * 3.14 / 180) + _circle.centerPoint.x;
        float y = _circle.radius * sinf(angle * 3.14 / 180) + _circle.centerPoint.y;
        dx = point.x - x;
        dy = point.y - y;
        float distanceToPoint = sqrtf(dx*dx + dy*dy);
        if (distanceToPoint < minDistance)
        {
            minDistance = distanceToPoint;
            currentPoint = CGPointMake(x, y);
        }
    }    
    return currentPoint;
}

- (void) showPoints: (NSArray *) points
{
    for (NSValue *value in points)
    {
        CGPoint argPoint = [value CGPointValue];
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        layer.fillColor = [[UIColor blackColor] CGColor];
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: CGRectMake(argPoint.x - 3, argPoint.y - 3, 6, 6)
                                                        cornerRadius:3];
        layer.path = [path CGPath];
        [_points addObject:layer];
        [self.view.layer addSublayer:layer];        
    }    
}

- (void) drawInMainContext
{    
    UIGraphicsBeginImageContext(self.imageView.frame.size);
    CGRect drawRect = CGRectMake(0.0f, 0.0f,
                                 self.imageView.frame.size.width,
                                 self.imageView.frame.size.height);
    [_imageView.image drawInRect:drawRect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    // fill background
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, _imageView.frame);
    [_imageView.image drawInRect:drawRect];    
    //draw shape
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    if (_line.eraserMode)
    {
        CGContextSetStrokeColorWithColor(context, [UIColor whiteColor].CGColor);
        CGContextSetLineWidth(context, 50.0);
    }
    CGPathRef path = _line?  [(CAShapeLayer *)_line.layer path] : [(CAShapeLayer *) _circle.layer path];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);    
    [_line removeFromSuperview];
    [_circle removeFromSuperview];
    for (CAShapeLayer *layer in _points)
    {
        [layer removeFromSuperlayer];
    }
    [_points removeAllObjects];
    _line = nil;
    _circle = nil;
    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    _eraserMode = NO;
    [_deleteButton setTitleColor: [UIColor blueColor] forState:UIControlStateNormal ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawLine:(id)sender
{
    [self drawInMainContext];    
    ShapeView *line = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [line.points addObject:[NSValue valueWithCGPoint:CGPointMake(100, 200)]];
    [line.points addObject:[NSValue valueWithCGPoint:CGPointMake(300, 400)]];
    _line = line;
    [_line setupLayer];
    [_imageView addSubview:line];  
}

- (IBAction)drawAngle:(id)sender
{
    [self drawInMainContext];
    ShapeView *angle = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(50, 200)]];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(250, 400)]];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(100, 600)]];
    _line = angle;
    [_line setupLayer];
    [_imageView addSubview:angle];
}

- (IBAction)drawCircle:(id)sender
{
    [self drawInMainContext];
    Circle *circle = [[Circle alloc] initWithFrame:CGRectMake (0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    _circle = circle;
    [_imageView addSubview:circle];
}

- (IBAction)drawCurve:(id)sender
{
    [self drawInMainContext];
    _drawCurveMode = YES;
    ShapeView *curve = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                           self.view.frame.size.height/2)];
    _line = curve;
    [_imageView addSubview:curve];
   
}

- (IBAction)deleteMode:(id)sender
{
    [self drawInMainContext];
    _eraserMode = YES;
            
    ShapeView *curve = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                                   self.view.frame.size.height/2)];
    _line = curve;
    [_imageView addSubview:curve];    
    _line.eraserMode = _eraserMode;
    [_deleteButton setTitleColor: [UIColor redColor] forState:UIControlStateNormal ];
}

@end
