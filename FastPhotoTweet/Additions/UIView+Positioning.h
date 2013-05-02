//
//  UIView+Positioning.h
//  AmznCal 2
//
//  Created by @peace3884 on 2013/03/10.
//  Copyright (c) 2013年 @peace3884. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIView(Positioning)

- (void)changeX:(CGFloat)x;
- (void)changeY:(CGFloat)y;
- (void)changeX:(CGFloat)x y:(CGFloat)y;

- (void)changeWidth:(CGFloat)width;
- (void)changeHeight:(CGFloat)height;
- (void)changeWidth:(CGFloat)width height:(CGFloat)height;

@end

@interface CALayer(Positioning)

@end