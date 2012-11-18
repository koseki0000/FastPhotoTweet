//
//  TimelineMenuCell.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import "TimelineMenuCell.h"

@implementation TimelineMenuCell

- (void)drawRect:(CGRect)rect {
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    size_t location = 2;
    CGFloat locations[2] =  {0.0, 1.0};
    CGFloat components[8] = {1.0,  1.0,  1.0, 1.0, 0.92, 0.92, 0.92, 1.0};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient =   CGGradientCreateWithColorComponents(colorSpace, components, locations, location);
    
    CGPoint startPoint = CGPointMake(self.frame.size.width / 2, 0.0);
    CGPoint endPoint =   CGPointMake(self.frame.size.width / 2, self.frame.size.height);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if ( self ) {
        
        [self.accessoryView removeFromSuperview];
        [self.backgroundView removeFromSuperview];
        [self.imageView removeFromSuperview];
        [self.editingAccessoryView removeFromSuperview];
        [self.inputAccessoryView removeFromSuperview];
        [self.inputView removeFromSuperview];
        [self.multipleSelectionBackgroundView removeFromSuperview];
        [self.selectedBackgroundView removeFromSuperview];
        
        [self.textLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    return self;
}

- (void)dealloc {
    
//    NSLog(@"%s", __func__);
}

@end
