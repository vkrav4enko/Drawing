//
//  ViewController.h
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
{    
    int currentPointIndex, currentCircleIndex;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) UITouch *currentTouch;
@end
