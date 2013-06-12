//
//  UIImage+Convert.m
//

#import "UIImage+Convert.h"

@interface UIImage (Decode)

+ (UIImage *)decompressedImage:(UIImage *)image;

@end

@implementation UIImage (Decode)

+ (UIImage *)decompressedImage:(UIImage *)image {
    
    CGImageRef imageRef = [image CGImage];
    CGRect rect = CGRectMake(0.0f,
                             0.0f,
                             CGImageGetWidth(imageRef),
                             CGImageGetHeight(imageRef));
    CGContextRef bitmapContext = CGBitmapContextCreate(NULL,
                                                       rect.size.width,
                                                       rect.size.height,
                                                       CGImageGetBitsPerComponent(imageRef),
                                                       CGImageGetBytesPerRow(imageRef),
                                                       CGImageGetColorSpace(imageRef),
                                                       CGImageGetBitmapInfo(imageRef));
    CGContextDrawImage(bitmapContext,
                       rect,
                       imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(bitmapContext);
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef];
    
    CGImageRelease(decompressedImageRef);
    CGContextRelease(bitmapContext);
    
    return decompressedImage;
}

@end

@implementation UIImage (Convert)

+ (UIImage *)imageWithDataByContext:(NSData *)imageData {
    
    return [UIImage decompressedImage:[UIImage imageWithData:imageData]];
}

+ (UIImage *)imageWithContentsOfFileByContext:(NSString *)imagePath {
    
    return [UIImage decompressedImage:[UIImage imageWithContentsOfFile:imagePath]];
}

@end