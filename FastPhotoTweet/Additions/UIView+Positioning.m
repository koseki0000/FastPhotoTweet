//
//  UIView+Positioning.m
//  AmznCal 2
//
//  Created by @peace3884 on 2013/03/10.
//  Copyright (c) 2013年 @peace3884. All rights reserved.
//

#import "UIView+Positioning.h"

@implementation UIView(Positioning)

- (void)changeX:(CGFloat)x {
    
    [self setFrame:CGRectMake(x,
                              CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
}

- (void)changeY:(CGFloat)y {
    
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame),
                              y,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
}

- (void)changeX:(CGFloat)x y:(CGFloat)y {
    
    [self setFrame:CGRectMake(x,
                              y,
                              CGRectGetWidth(self.frame),
                              CGRectGetHeight(self.frame))];
}

- (void)changeWidth:(CGFloat)width {
    
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame),
                              CGRectGetMinY(self.frame),
                              width,
                              CGRectGetHeight(self.frame))];
}

- (void)changeHeight:(CGFloat)height {
    
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame),
                              CGRectGetMinY(self.frame),
                              CGRectGetWidth(self.frame),
                              height)];

}

- (void)changeWidth:(CGFloat)width height:(CGFloat)height {
    
    [self setFrame:CGRectMake(CGRectGetMinX(self.frame),
                              CGRectGetMinY(self.frame),
                              width,
                              height)];

}

@end

@implementation CALayer(Positioning)

@end