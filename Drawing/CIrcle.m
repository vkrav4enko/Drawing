//
//  CIrcle.m
//  Drawing
//
//  Created by Владимир on 23.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "CIrcle.h"

@implementation CIrcle

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _centerPoint = CGPointMake(200, 400);
        _radius = 50;
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
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(_centerPoint.x - _radius,
                                                                            _centerPoint.y - _radius,
                                                                            2.0*_radius, 2.0*_radius)
                                                    cornerRadius:_radius];
    layer.path = [path CGPath];
    
}

- (BOOL) checkPoint: (CGPoint) point withinRadius:(float)r
{
    _pointToChange = nil;
    float dx, dy;
    dx = point.x - _centerPoint.x;
    dy = point.y - _centerPoint.y;
    if(sqrtf(dx*dx + dy*dy)<=r)
    {
        _pointToChange = &_centerPoint;
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
