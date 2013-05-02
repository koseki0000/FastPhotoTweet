//
//  UIView+RectInitialize.m
//  FastPhotoTweet
//
//  Created by m.s.s02968 on 2013/04/06.
//
//

#import "UIView+RectInitialize.h"

@implementation UIView (RectInitialize)

- (id)initWithX:(CGFloat)x Y:(CGFloat)y W:(CGFloat)w H:(CGFloat)h {
    
    self = [self initWithFrame:CGRectMake(x,
                                          y,
                                          w,
                                          h)];
    
    return self;
}

@end
