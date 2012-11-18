//
//  NSString+Calculator.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 2012/11/17.
//
//

#import "NSString+Calculator.h"

@implementation NSString (Calculator)

- (CGFloat)heightForContents:(UIFont *)font toWidht:(CGFloat)widht minHeight:(CGFloat)minHeight lineBreakMode:(NSLineBreakMode)lineBreakMode {
    
    CGSize contentsSize = [self sizeWithFont:font
                           constrainedToSize:CGSizeMake(widht, 20000)
                               lineBreakMode:lineBreakMode];
    
    CGFloat height = contentsSize.height;
    
    if ( height < minHeight ) height = minHeight;
    
    return height;
}

@end
