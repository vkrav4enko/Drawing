//
//  ViewController.h
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineDrawView.h"

@interface ViewController : UIViewController
{
    CGPoint dragStartingPoint, lineOriginStart, lineOriginEnd;
    int currentPointIndex, currentCircleIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) LineDrawView *lineDrawView;
@property (nonatomic, strong) UITouch *currentTouch;
@end
