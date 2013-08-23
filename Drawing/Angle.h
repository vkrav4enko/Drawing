//
//  Angle.h
//  Drawing
//
//  Created by Владимир on 23.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Angle : UIView
@property (nonatomic) CGPoint *pointToChange;
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint anglePoint;
@property (nonatomic) CGPoint endPoint;
- (void)setupLayer;
- (BOOL)checkPoint: (CGPoint) point withinRadius:(float)r;
@end
