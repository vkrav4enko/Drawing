//
//  Curve.m
//  Drawing
//
//  Created by Владимир on 23.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "Curve.h"

@implementation Curve

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _startPoint = CGPointMake(200, 260);
        _endPoint = CGPointMake(400, 260);
        _firstHelper = CGPointMake(300, 370);
        _secondHelper = CGPointMake(240, 200);
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
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:_startPoint];
    [path addCurveToPoint:_endPoint controlPoint1:_firstHelper controlPoint2:_secondHelper];
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
    
    dx = point.x - _firstHelper.x;
    dy = point.y - _firstHelper.y;
    if(sqrtf(dx*dx + dy*dy)<=r)
    {
        _pointToChange = &_firstHelper;
        return YES;
    }
    
    dx = point.x - _secondHelper.x;
    dy = point.y - _secondHelper.y;
    if(sqrtf(dx*dx + dy*dy)<=r)
    {
        _pointToChange = &_secondHelper;
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
@end
