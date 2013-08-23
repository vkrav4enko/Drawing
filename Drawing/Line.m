//
//  Line.m
//  Drawing
//
//  Created by Владимир on 22.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "Line.h"

@implementation Line

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _startPoint = CGPointMake(600, 400);
        _endPoint = CGPointMake(50, 300);
        [self setupLayer];
    }
    return self;
}

- (void)setupLayer
{
    CAShapeLayer *layer = (CAShapeLayer *)self.layer;
    layer.strokeColor = [[UIColor blackColor] CGColor];
    layer.fillColor = [[UIColor blackColor] CGColor];
    layer.lineWidth = 2;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_startPoint];
    [path addLineToPoint:_endPoint];
    layer.path = [path CGPath];    
}

- (BOOL) checkPoint: (CGPoint) point withinRadius:(float)r
{
    _pointToChange = nil;

    float dx, dy;
    dx = point.x - _startPoint.x;
    dy = point.y - _startPoint.y;
    if(sqrtf(dx*dx + dy*dy)<=r)
    {
        _pointToChange = &_startPoint;
        return YES;
    }
    
    dx = point.x - _endPoint.x;
    dy = point.y - _endPoint.y;
    if(sqrtf(dx*dx + dy*dy)<=r)
    {
        _pointToChange = &_endPoint;
        return YES;
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
    
    CGPathRef tapTargetPath = CGPathCreateCopyByStrokingPath(path.CGPath, NULL, fmaxf(20.0f, path.lineWidth), path.lineCapStyle, path.lineJoinStyle, path.miterLimit);
    if (tapTargetPath == NULL) {
        return nil;
    }
    
    UIBezierPath *tapTarget = [UIBezierPath bezierPathWithCGPath:tapTargetPath];
    CGPathRelease(tapTargetPath);
    return tapTarget;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
