//
//  ShapeView.h
//  Drawing
//
//  Created by Владимир on 05.09.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShapeView : UIView
@property (nonatomic) CGPoint pointToChange;
@property (nonatomic, strong) NSMutableArray *points;
@property (nonatomic) float radius;
- (void)setupLayer;
- (BOOL)checkPoint: (CGPoint) point withinRadius:(float)r;
@end
