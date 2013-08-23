//
//  CIrcle.h
//  Drawing
//
//  Created by Владимир on 23.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CIrcle : UIView
@property (nonatomic) CGPoint *pointToChange;
@property (nonatomic) CGPoint centerPoint;
@property (nonatomic) float radius;
- (void)setupLayer;
- (BOOL)checkPoint: (CGPoint) point withinRadius:(float)r;
@end
