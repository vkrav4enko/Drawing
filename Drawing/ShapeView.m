//
//  ShapeView.m
//  Drawing
//
//  Created by Владимир on 05.09.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "ShapeView.h"

@implementation ShapeView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _points = [NSMutableArray new];
        [self setupLayer];
    }
    return self;
}

- (void)setupLayer
{    
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;    
    layer.strokeColor = [[UIColor blackColor] CGColor];
    layer.fillColor = [[UIColor clearColor] CGColor];
    layer.lineWidth = 2;
    if (_eraserMode)
    {
        layer.strokeColor = [[UIColor whiteColor] CGColor];
        layer.lineWidth = 10;
    }
    UIBezierPath *path = [UIBezierPath bezierPath];
    for (int i = 0; i < _points.count; i++)
    {
        CGPoint point = [[_points objectAtIndex:i] CGPointValue];
        if (i == 0)
        {
            [path moveToPoint:point];
        }
        else
        {
            [path addLineToPoint:point];
        }
    }
    layer.path = [path CGPath];
}

- (BOOL) checkPoint: (CGPoint) point withinRadius:(float)r
{
    _pointToChange = CGPointZero;
    for (NSValue *value in _points)
    {
        CGPoint currentPoint = [value CGPointValue];
        float dx, dy;
        dx = point.x - currentPoint.x;
        dy = point.y - currentPoint.y;
        if(sqrtf(dx*dx + dy*dy)<=r)
        {
            _pointToChange = currentPoint;
            return YES;
        }
    }    
        
    UIBezierPath *path = [UIBezierPath bezierPathWithCGPath:[(CAShapeLayer *)self.layer path]];
    if([[self tapTargetForPath:path] containsPoint:point])
    {
        return YES;
    }
    
    return NO;
}

- (UIBezierPath *)tapTargetForPath:(UIBezierPath *)path
{
    if (path == nil) {
        return nil;
    }
    
    CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, fmaxf(40.0f, path.lineWidth), path.lineCapStyle, path.lineJoinStyle, path.miterLimit);
    if (tapTargetPath == NULL) {
        return nil;
    }
    
    UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
    CGPathRelease(tapTargetPath);
    return tapTarget;
}


@end
