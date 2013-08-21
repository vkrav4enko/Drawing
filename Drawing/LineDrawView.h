//
//  lineDrawView.h
//  Drawing
//
//  Created by Владимир on 21.08.13.
//  Copyright (c) 2013 Владимир. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineDrawView : UIView
@property (nonatomic, strong) NSMutableArray *lines;
@property (nonatomic) BOOL showAnchorPoints;
- (void) drawLine;
@end
