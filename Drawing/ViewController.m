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
@property (nonatomic) BOOL deleteMode;
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic, strong) NSMutableArray *angles;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic) BOOL showAnchorPoints;
@property (nonatomic) BOOL isLine;
@property (nonatomic) BOOL isAngle;

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
    self.points = [NSMutableArray new];
    
    
//    self.lineDrawView = [[LineDrawView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height / 2)];
//    [self.view addSubview:self.lineDrawView];
//    self.lineDrawView.lines = [[NSMutableArray alloc] init];    
//    [self.lineDrawView.lines addObject:[NSValue valueWithCGPoint:CGPointMake(600, 400)]];
//    [self.lineDrawView.lines addObject:[NSValue valueWithCGPoint:CGPointMake( 50, 300)]];
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
    [self.points removeAllObjects];
    CGPoint p1, p2, p3;
    NSValue *v1, *v2, *v3;
    
    for(int i=0; i<self.lines.count/2; i++)
    {
        v1 = [self.lines objectAtIndex:i*2+0];
        v2 = [self.lines objectAtIndex:i*2+1];
        p1 = [v1 CGPointValue];
        p2 = [v2 CGPointValue];
        if([self distanceOfPoint:p toLineWith:p1 and:p2]<=d)
        {
            [self.points addObject:v1];
            [self.points addObject:v2];
            return 1;
        }        
    }
    
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
            [self.points addObject:v1];
            [self.points addObject:v2];
            [self.points addObject:v3];
            return 1;
        }        
    }
    
    return -1;
}

-(int)getPointNearToPoint:(CGPoint)p withinRadius:(float)r
{
    float dx, dy;
    CGPoint p2;
    NSValue *v;
    
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
            return i;
        }
    }
    
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
            return i;
        }
    }
    
    return -1;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    int iPoint;
    currentLineIndex = -1;
    currentPointIndex = -1;
    
    for(UITouch *t in touches)
    {
        // check if a starting/ending point is near the current touch
        CGPoint p = [t locationInView:self.view];
        iPoint = [self getPointNearToPoint:p withinRadius:10];
        if(iPoint != -1)
        {
            currentPointIndex = iPoint;
            self.currentTouch = t;            
        }        
        
        // check if current touch is near a line
        [self getLineNearToPoint:p withMaximumDistance:10];
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
        
        // Are we moving a starting/ending point?
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
            
        }
        
//        // Are we moving a line?
//        if(currentLineIndex != -1)
//        {
//            // calculate drag distance
//            float dx = p.x - dragStartingPoint.x;
//            float dy = p.y - dragStartingPoint.y;
//            
//            // calculate new starting/ending points
//            CGPoint p1 = CGPointMake(lineOriginStart.x+dx, lineOriginStart.y+dy);
//            CGPoint p2 = CGPointMake(lineOriginEnd.x+dx, lineOriginEnd.y+dy);
//            NSValue *v1 = [NSValue valueWithCGPoint:p1];
//            NSValue *v2 = [NSValue valueWithCGPoint:p2];
//            
//            // replace old values
//            [self.lines replaceObjectAtIndex:currentLineIndex*2+0 withObject:v1];
//            [self.lines replaceObjectAtIndex:currentLineIndex*2+1 withObject:v2];
//        }
        
        // only use first touch, discard the rest
        break;
    }
    [self showAll];
    
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
}

- (IBAction)drawCurve:(id)sender {
}

- (IBAction)deleteMode:(id)sender {
    _deleteMode = !_deleteMode;
    [_deleteButton setTitleColor: _deleteMode? [UIColor redColor] : [UIColor blueColor] forState:UIControlStateNormal ];
}
@end
