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
#import "Circle.h"
#import "ShapeView.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableArray *angles;
@property (nonatomic, strong) NSMutableArray *circles;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *curves;
@property (nonatomic, strong) ShapeView *shape;
@property (nonatomic, strong) Circle *circle;
@property (nonatomic) BOOL isCircle;
@property (nonatomic) BOOL isLine;
@property (nonatomic) BOOL isAngle;
@property (nonatomic) BOOL isCurve;
@property (nonatomic) BOOL deleteMode;
@property (nonatomic) BOOL drawCurveMode;

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
    _isCurve = NO;
    _isLine = NO;
    _isCircle = NO;
    _isAngle = NO;
    
    for(UITouch *touch in touches)
    {
        // check if a starting/ending point is near the current touch
        CGPoint point = [touch locationInView:self.view];
        _isLine = [_shape checkPoint:point withinRadius:20];
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
    if (_drawCurveMode)
    {
        UITouch *touch = [touches anyObject];
        CGPoint currentPoint = [touch locationInView:self.view];
        [_shape.points addObject:[NSValue valueWithCGPoint:currentPoint]];
        [_shape setupLayer];
    }
    else
    {
        for(UITouch *t in touches)
        {
            if(t != self.currentTouch) continue;        
            CGPoint p = [t locationInView:self.view];
            if (_isLine)
            {              
                
                if (!CGPointEqualToPoint(_shape.pointToChange, CGPointZero))
                {
                    if (_shape.points.count > 4)
                    {
                        if (CGPointEqualToPoint(_shape.pointToChange, [[_shape.points objectAtIndex:0] CGPointValue]))
                        {
                            float dx, dy;
                            dx = p.x - _shape.pointToChange.x;
                            dy = p.y - _shape.pointToChange.y;
                            for (int i = 0; i < _shape.points.count; i++)
                            {
                                CGPoint oldPoint = [[_shape.points objectAtIndex:i] CGPointValue];
                                CGPoint newPoint = CGPointMake(oldPoint.x + dx, oldPoint.y +dy);
                                [_shape.points replaceObjectAtIndex:i withObject: [NSValue valueWithCGPoint:newPoint]];
                            }
                            _shape.pointToChange = [[_shape.points objectAtIndex:0] CGPointValue];
                            [_shape setupLayer];
                        }                            
                    }
                    else
                    {
                        int i = 0;
                        for (NSValue *value in _shape.points)
                        {
                            CGPoint point = [value CGPointValue];
                            if (CGPointEqualToPoint(point, _shape.pointToChange))
                            {
                                break;
                            }
                            i++;
                        }
                        _shape.pointToChange = p;
                        [_shape.points replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint: _shape.pointToChange]];
                        [_shape setupLayer];
                        break;
                    }         
                    
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
        if (_shape.points.count < 4)
            [self showPoints:_shape.points];
        else
            [self showPoints:@[[_shape.points objectAtIndex:0]]];
    }
    if (_isCircle)
    {        
        [self showPoints:@[[NSValue valueWithCGPoint:_circle.centerPoint], [NSValue valueWithCGPoint:_circle.pointToChange? CGPointZero : [_currentTouch locationInView:self.view]]]];
    }        
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
    CGPathRef path = _shape?  [(CAShapeLayer *)_shape.layer path] : [(CAShapeLayer *) _circle.layer path];
    CGContextAddPath(context, path);
    CGContextStrokePath(context);    
    [_shape removeFromSuperview];
    _shape = nil;
    _circle = nil;
    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawLine:(id)sender {
    [self drawInMainContext];
    ShapeView *line = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [line.points addObject:[NSValue valueWithCGPoint:CGPointMake(100, 200)]];
    [line.points addObject:[NSValue valueWithCGPoint:CGPointMake(300, 400)]];
    _shape = line;
    [_shape setupLayer];
    [self.view addSubview:line];  
}

- (IBAction)drawAngle:(id)sender {
    [self drawInMainContext];
    ShapeView *angle = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(50, 200)]];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(250, 400)]];
    [angle.points addObject:[NSValue valueWithCGPoint:CGPointMake(100, 600)]];
    _shape = angle;
    [_shape setupLayer];
    [self.view addSubview:angle];
}

- (IBAction)drawCircle:(id)sender {
    [self drawInMainContext];
    Circle *circle = [[Circle alloc] initWithFrame:CGRectMake (0, 0, self.view.frame.size.width, self.view.frame.size.height/2)];
    _circle = circle;
    [self.view addSubview:circle];
}

- (IBAction)drawCurve:(id)sender {
    _drawCurveMode = !_drawCurveMode;
    if (_drawCurveMode)
    {
        [self drawInMainContext];
        ShapeView *curve = [[ShapeView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width,
                                                               self.view.frame.size.height/2)];
        _shape = curve;
        [self.view addSubview:curve];
    }
}

- (IBAction)deleteMode:(id)sender {
    _deleteMode = !_deleteMode;
    [_deleteButton setTitleColor: _deleteMode? [UIColor redColor] : [UIColor blueColor] forState:UIControlStateNormal ];
}
@end
