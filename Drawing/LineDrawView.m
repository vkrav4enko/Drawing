//
//  lineDrawView.m
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import "LineDrawView.h"

@implementation LineDrawView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{       
    [self drawLine];
}

- (void) drawLine
{    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // fill background
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillRect(context, self.frame);
    
    // draw lines
    CGContextSetStrokeColorWithColor(context, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(context, 2.0);
    for(int i=0; i<self.lines.count/2; i++)
    {
        CGPoint p1 = [[self.lines objectAtIndex:i*2+0] CGPointValue];
        CGPoint p2 = [[self.lines objectAtIndex:i*2+1] CGPointValue];
        if (_showAnchorPoints)
        {
            CGContextSetFillColorWithColor(context, [UIColor blackColor].CGColor);
            CGRect rectangle = CGRectMake(p1.x - 5, p1.y - 5, 10.0f, 10.0f);
            CGContextFillEllipseInRect(context, rectangle);
            rectangle = CGRectMake(p2.x - 5, p2.y - 5, 10.0f, 10.0f);
            CGContextFillEllipseInRect(context, rectangle);
        }
        CGContextMoveToPoint(context, p1.x, p1.y);
        CGContextAddLineToPoint(context, p2.x, p2.y);
    }
    CGContextStrokePath(context);
}


@end
