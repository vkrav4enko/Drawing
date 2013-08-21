//
//  ViewController.m
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableArray *angles;
@property (nonatomic, strong) NSMutableArray *circles;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic, strong) NSMutableArray *curves;
@property (nonatomic) BOOL isCircleCenter;
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

-(float)distanceOfPoint:(CGPoint)p toLineWith:(CGPoint)v0 and:(CGPoint)v1
{
    float vx = v0.x - p.x;
    float vy = v0.y - p.y;
    float ux = v1.x - v0.x;
    float uy = v1.y - v0.y;
    float length = ux * ux + uy * uy;
    float result;
    
    float det = (-vx * ux) + (-vy * uy);
    // if this is < 0 or > length then it's outside the line segment
    if(det < 0)
        result = (v0.x - p.x) * (v0.x - p.x) + (v0.y - p.y) * (v0.y - p.y);
    else if(det > length)
        result = (v1.x - p.x) * (v1.x - p.x) + (v1.y - p.y) * (v1.y - p.y);
    else
    {
        det = ux * vy - uy * vx;
        result = (det * det) / length;
    }
    
    return sqrtf(result);
}

-(int)getLineNearToPoint:(CGPoint)p withMaximumDistance:(float)d
{    
    CGPoint p1, p2, p3, p4;
    NSValue *v1, *v2, *v3, *v4;
    
    //Touch a line
    for(int i=0; i<self.lines.count/2; i++)
    {
        v1 = [self.lines objectAtIndex:i*2+0];
        v2 = [self.lines objectAtIndex:i*2+1];
        p1 = [v1 CGPointValue];
        p2 = [v2 CGPointValue];
        if([self distanceOfPoint:p toLineWith:p1 and:p2]<=d)
        {
            if (_deleteMode)
            {
                [self.lines removeObject:v1];
                [self.lines removeObject:v2];
                return -1;
            }
            [self.points addObject:v1];
            [self.points addObject:v2];
            return 1;
        }        
    }
    
    //Touch an angle
    for(int i=0; i<self.angles.count/3; i++)
    {
        v1 = [self.angles objectAtIndex:i*3+0];
        v2 = [self.angles objectAtIndex:i*3+1];
        v3 = [self.angles objectAtIndex:i*3+2];
        p1 = [v1 CGPointValue];
        p2 = [v2 CGPointValue];
        p3 = [v3 CGPointValue];
        if([self distanceOfPoint:p toLineWith:p1 and:p2]<=d || [self distanceOfPoint:p toLineWith:p2 and:p3]<=d)
        {
            if (_deleteMode)
            {
                [self.angles removeObject:v1];
                [self.angles removeObject:v2];
                [self.angles removeObject:v3];
                return -1;
            }
            [self.points addObject:v1];
            [self.points addObject:v2];
            [self.points addObject:v3];
            return 1;
        }        
    }
    
    //Touch a curve
    for (int i =0; i<self.curves.count/4; i++)
    {
        v1 = [self.curves objectAtIndex:i*4+0];
        v2 = [self.curves objectAtIndex:i*4+1];
        v3 = [self.curves objectAtIndex:i*4+2];
        v4 = [self.curves objectAtIndex:i*4+3];
        p1 = [v1 CGPointValue];
        p2 = [v2 CGPointValue];
        p3 = [v3 CGPointValue];
        p4 = [v4 CGPointValue];
        
        UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
        [bezierPath moveToPoint:p1];
        [bezierPath addCurveToPoint:p2 controlPoint1:p3 controlPoint2:p4];
        if([[self tapTargetForPath:bezierPath] containsPoint:p])
        {
            if (_deleteMode)
            {
                [self.curves removeObject:v1];
                [self.curves removeObject:v2];
                [self.curves removeObject:v3];
                [self.curves removeObject:v4];
                return -1;
            }
            [self.points removeAllObjects];
            [self.points addObject:v1];
            [self.points addObject:v2];
            [self.points addObject:v3];
            [self.points addObject:v4];
            return 1;
        }
    }
    
    
    return -1;
}

-(int)getPointNearToPoint:(CGPoint)p withinRadius:(float)r
{    
    [self.points removeAllObjects];
    float dx, dy;
    CGPoint p2;
    NSValue *v;
    
    //Touch near line points
    for(int i=0; i<self.lines.count; i++)
    {
        v = [self.lines objectAtIndex:i];
        p2 = [v CGPointValue];
        dx = p.x - p2.x;
        dy = p.y - p2.y;
        if(sqrtf(dx*dx + dy*dy)<=r)
        {
            _isLine = YES;
            _isAngle = NO;
            _isCircleCenter = NO;
            _isCurve = NO;
            return i;
        }
    }
    
    //Touch near angle points
    for(int i=0; i<self.angles.count; i++)
    {
        v = [self.angles objectAtIndex:i];
        p2 = [v CGPointValue];
        dx = p.x - p2.x;
        dy = p.y - p2.y;
        if(sqrtf(dx*dx + dy*dy)<=r)
        {
            _isAngle = YES;
            _isLine = NO;
            _isCircleCenter = NO;
            _isCurve = NO;
            return i;
        }
    }
    
    //Touch near curve points
    for(int i=0; i<self.curves.count; i++)
    {
        v = [self.curves objectAtIndex:i];
        p2 = [v CGPointValue];
        dx = p.x - p2.x;
        dy = p.y - p2.y;
        if(sqrtf(dx*dx + dy*dy)<=r)
        {
            _isAngle = NO;
            _isLine = NO;
            _isCircleCenter = NO;
            _isCurve = YES;
            
            [self.points addObjectsFromArray:@[_curves[i - i%4],_curves[i - i%4 +1],_curves[i - i%4+2],_curves[i - i%4+3]]];
            
            return i;
        }
    }

    //Touch near circle points
    for(int i=0; i<self.circles.count/2; i++)
    {
        CGPoint centre = [[self.circles objectAtIndex:i*2+0] CGPointValue];
        float radius = [[self.circles objectAtIndex:i*2+1] floatValue];
        dx = p.x - centre.x;
        dy = p.y - centre.y;
        if(sqrtf(dx*dx + dy*dy)<=r)
        {
            if (_deleteMode)
            {
                [self.circles removeObjectAtIndex:i*2];
                [self.circles removeObjectAtIndex:i*2];
                return -1;
            }
            _isLine = NO;
            _isAngle = NO;
            _isCircleCenter = YES;
            _isCurve = NO;
            currentCircleIndex = i;
            [self.points addObject:[NSValue valueWithCGPoint:centre]];
            return i;
        }
        else if (sqrtf(dx*dx + dy*dy) <= (radius + r/2) && sqrtf(dx*dx + dy*dy) >= (radius - r/2))
        {
            if (_deleteMode)
            {
                [self.circles removeObjectAtIndex:i*2];
                [self.circles removeObjectAtIndex:i*2];
                return -1;
            }
            _isLine = NO;
            _isAngle = NO;
            _isCircleCenter = NO;
            _isCurve = NO;
            currentCircleIndex = i;           
            [self.points addObject:[NSValue valueWithCGPoint:centre]];
            [self.points addObject:[NSValue valueWithCGPoint:p]];
            return i;
        }       
        
    }
    
    return -1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int iPoint;
    currentCircleIndex = -1;
    currentPointIndex = -1;
    
    for(UITouch *touch in touches)
    {
        // check if a starting/ending point is near the current touch
        CGPoint point = [touch locationInView:self.view];
        iPoint = [self getPointNearToPoint:point withinRadius:10];
        if(iPoint != -1)
        {
            currentPointIndex = iPoint;
            self.currentTouch = touch;            
        }        
        
        // check if current touch is near a line
        [self getLineNearToPoint:point withMaximumDistance:10];
        break;
    }
    
    [self showAll];    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for(UITouch *t in touches)
    {
        // only respond to touch move events of the touch previously assigned
        // to a point or line
        if(t != self.currentTouch) continue;
        
        CGPoint p = [t locationInView:self.view];
        
        // Are we moving an active point?
        if(currentPointIndex != -1)
        {
            NSValue *v = [NSValue valueWithCGPoint:p];
            if (_isLine)
            {
                [self.lines replaceObjectAtIndex:currentPointIndex withObject:v];
                [self.points replaceObjectAtIndex:currentPointIndex%2 withObject:v];
            }
            if (_isAngle)
            {
                [self.angles replaceObjectAtIndex:currentPointIndex withObject:v];
                [self.points replaceObjectAtIndex:currentPointIndex%3 withObject:v];
            }
            if (_isCurve)
            {
                [self.curves replaceObjectAtIndex:currentPointIndex withObject:v];
                [self.points replaceObjectAtIndex:currentPointIndex%4 withObject:v];
            }
            
        }
        
        // Are we moving a circle?
        if(currentCircleIndex != -1)
        {
            NSValue *v = [NSValue valueWithCGPoint:p];
            if (_isCircleCenter)
            {
                [self.circles replaceObjectAtIndex:currentCircleIndex*2 withObject:v];
                [self.points replaceObjectAtIndex:currentCircleIndex*2%2 withObject:v];
            }
            else
            {
                CGPoint centre = [[self.circles objectAtIndex:currentCircleIndex*2] CGPointValue];
                float radius = sqrtf(powf((p.x - centre.x), 2) + powf((p.y - centre.y), 2));
                [self.circles replaceObjectAtIndex:currentCircleIndex*2 + 1 withObject:@(radius)];
                [self.points replaceObjectAtIndex:currentCircleIndex*2%2 + 1 withObject:v];
            }
        }
        
        // only use first touch, discard the rest
        break;
    }
    [self showAll];
    
}

// this method will let you easily select a bezier path ( 15 px up and down of a path drawing)
- (UIBezierPath *)tapTargetForPath:(UIBezierPath *)path
{
    if (path == nil) {
        return nil;
    }
    
    CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, fmaxf(35.0f, path.lineWidth), path.lineCapStyle, path.lineJoinStyle, path.miterLimit);
    if (tapTargetPath == NULL) {
        return nil;
    }
    
    UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
    CGPathRelease(tapTargetPath);
    return tapTarget;
}

- (void) showAll
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
    
    // draw lines
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    for(int i=0; i<self.lines.count/2; i++)
    {
        CGPoint p1 = [[self.lines objectAtIndex:i*2+0] CGPointValue];
        CGPoint p2 = [[self.lines objectAtIndex:i*2+1] CGPointValue];        
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
    }
    
    // draw angle   
    for(int i=0; i<self.angles.count/3; i++)
    {
        CGPoint p1 = [[self.angles objectAtIndex:i*3+0] CGPointValue];
        CGPoint p2 = [[self.angles objectAtIndex:i*3+1] CGPointValue];
        CGPoint p3 = [[self.angles objectAtIndex:i*3+2] CGPointValue];        
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
        CGContextAddLineToPoint(context, p3.x, p3.y);
    }
    CGContextStrokePath(context);
    
    //draw curve
    for(int i=0; i<self.curves.count/4; i++)
    {
        CGPoint bezierStart = [[self.curves objectAtIndex:i*4+0] CGPointValue];
        CGPoint bezierEnd = [[self.curves objectAtIndex:i*4+1] CGPointValue];
        CGPoint bezierHelper1 = [[self.curves objectAtIndex:i*4+2] CGPointValue];
        CGPoint bezierHelper2 = [[self.curves objectAtIndex:i*4+3] CGPointValue];
        UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
        [bezierPath moveToPoint:bezierStart];
        [bezierPath addCurveToPoint:bezierEnd controlPoint1:bezierHelper1 controlPoint2:bezierHelper2];
        [bezierPath stroke];
        
    }
    
    // draw circle
    for(int i=0; i<self.circles.count/2; i++)
    {
        CGPoint centre = [[self.circles objectAtIndex:i*2+0] CGPointValue];
        float radius = [[self.circles objectAtIndex:i*2+1] floatValue];
        CGRect circleRect = CGRectMake(centre.x - radius, centre.y - radius, radius*2, radius*2);
        CGContextStrokeEllipseInRect(context, circleRect);
        
    }
    
    // draw points
    for(int i=0; i<self.points.count; i++)
    {
        CGPoint p = [[self.points objectAtIndex:i] CGPointValue];
        CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
        CGRect rectangle = CGRectMake(p.x - 5, p.y - 5, 10.0f, 10.0f);
        CGContextFillEllipseInRect(context, rectangle);        
    }
    
  

    
    
    _imageView.image = UIGraphicsGetImageFromCurrentImageContext();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)drawLine:(id)sender {
    [self.lines addObject:[NSValue valueWithCGPoint:CGPointMake(600, 400)]];
    [self.lines addObject:[NSValue valueWithCGPoint:CGPointMake( 50, 300)]];
    [self showAll];

}

- (IBAction)drawAngle:(id)sender {
    [self.angles addObject:[NSValue valueWithCGPoint:CGPointMake(600, 400)]];
    [self.angles addObject:[NSValue valueWithCGPoint:CGPointMake( 50, 300)]];
    [self.angles addObject:[NSValue valueWithCGPoint:CGPointMake( 500, 200)]];
    [self showAll];
}

- (IBAction)drawCircle:(id)sender {
    [self.circles addObject:[NSValue valueWithCGPoint:CGPointMake(400, 400)]];
    [self.circles addObject:@50];
    [self showAll];    
}

- (IBAction)drawCurve:(id)sender {
    CGPoint bezierStart = {200, 260};
    CGPoint bezierEnd = {400, 260};
    CGPoint bezierHelper1 = {300, 370};
    CGPoint bezierHelper2 = {240, 150};
    [self.curves addObject:[NSValue valueWithCGPoint: bezierStart]];
    [self.curves addObject:[NSValue valueWithCGPoint: bezierEnd]];
    [self.curves addObject:[NSValue valueWithCGPoint: bezierHelper1]];
    [self.curves addObject:[NSValue valueWithCGPoint: bezierHelper2]];
    [self showAll];   
}

- (IBAction)deleteMode:(id)sender {
    _deleteMode = !_deleteMode;
    [_deleteButton setTitleColor: _deleteMode? [UIColor redColor] : [UIColor blueColor] forState:UIControlStateNormal ];
}
@end
