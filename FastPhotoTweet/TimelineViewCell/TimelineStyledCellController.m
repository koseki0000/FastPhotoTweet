//
//  TimelineStyledCellController.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/10/14.
//

#import "TimelineStyledCellController.h"

@implementation TimelineStyledCell

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //セル背景描画
    CGGradientRef gradient;
    CGColorSpaceRef colorSpace;
    size_t location = 2;
    CGFloat locations[2] = { 0.0, 1.0 };
    CGFloat components[8] = { 1.0, 1.0, 1.0, 1.0,
        0.92, 0.92, 0.92, 1.0 };
    colorSpace = CGColorSpaceCreateDeviceRGB();
    gradient = CGGradientCreateWithColorComponents( colorSpace, components,
                                                   locations, location );
    
    CGPoint startPoint = CGPointMake( self.frame.size.width / 2, 0.0 );
    CGPoint endPoint = CGPointMake( self.frame.size.width / 2, self.frame.size.height );
    CGContextDrawLinearGradient( context, gradient, startPoint, endPoint, 0 );
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (void)dealloc {
    
    [_iconView removeFromSuperview];
    _iconView = nil;
    [_infoLabel removeFromSuperview];
    _infoLabel = nil;
    [_mainLabel removeFromSuperview];
    _mainLabel = nil;
}

@end

@implementation TimelineStyledCellController

- (void)dealloc {
    
    [_styledCell removeFromSuperview];
    _styledCell = nil;
}

- (void)viewDidUnload {
    
    [_styledCell removeFromSuperview];
    _styledCell = nil;
    
    [super viewDidUnload];
}

@end
