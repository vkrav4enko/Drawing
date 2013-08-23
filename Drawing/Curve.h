//
//  Curve.h
//  Drawing
//
//  Created by Владимир on 23.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Curve : UIView
@property (nonatomic) CGPoint *pointToChange;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint firstHelper;
@property (nonatomic) CGPoint secondHelper;
- (void)setupLayer;
- (BOOL)checkPoint: (CGPoint) point withinRadius:(float)r;
@end
