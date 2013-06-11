//
//  UIImage+Convert.m
//

#import "UIImage+Convert.h"

@implementation UIImage (Convert)

+ (UIImage *)imageWithDataByContext:(NSData *)imageData {
    
    UIImage *image = [UIImage imageWithData:imageData];
    CGImageRef imageRef = [image CGImage];
    UIGraphicsBeginImageContext(CGSizeMake(CGImageGetWidth(imageRef),
                                           CGImageGetHeight(imageRef)));
    [image drawAtPoint:CGPointZero];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

@end
