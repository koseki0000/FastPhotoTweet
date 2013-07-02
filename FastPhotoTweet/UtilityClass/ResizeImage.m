//
//  ResizeImage.m
//  UtilityClass
//
//  Created by @peace3884 on 12/03/08.
//

#import "ResizeImage.h"

@implementation ResizeImage

+ (UIImage *)aspectResize:(UIImage *)image {
    
    //NSLog(@"aspectResize");
    return [ResizeImage aspectResizeForMaxSize:image
                                       maxSize:(CGFloat)[[NSUserDefaults standardUserDefaults] integerForKey:@"ImageMaxSize"]];
}

+ (UIImage *)aspectResizeForMaxSize:(UIImage *)image maxSize:(CGFloat)maxSize {
    
    //NSLog(@"aspectResizeSetMaxSize");
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    CGFloat originalHeight = image.size.height;
    CGFloat originalWidth = image.size.width;
    
    //iPhone4解像度もリサイズする
    if ( [d boolForKey:@"NoResizeIphone4Ss"] ){
        
        CGFloat scale = [UIScreen mainScreen].scale;
        CGFloat screenWidth = CGRectGetWidth([UIScreen mainScreen].bounds) * scale;
        CGFloat screenHeight = CGRectGetHeight([UIScreen mainScreen].bounds) * scale;
        
		if ( originalHeight == screenWidth &&
             originalWidth == screenHeight ) {
            
            return image;
            
		}else if ( originalHeight == screenHeight &&
                   originalWidth == screenWidth ) {
            
            return image;
        }
	}
    
    //正方形
    if ( originalWidth == originalHeight ) {
        
        if ( originalHeight > maxSize ) {
            
            resizeWidth = maxSize;
            resizeHeight = maxSize;
            
        } else {
            
            return image;
        }
        
        //長方形
    } else {
        
        if ( originalHeight > maxSize ||
             originalWidth > maxSize ) {
            
            //縦長
            if ( originalHeight > originalWidth &&
                 originalHeight > maxSize ) {
                
                CGFloat ratio = originalHeight / maxSize;
                resizeWidth = originalWidth / ratio;
                resizeHeight = maxSize;
                
            //横長
            }else if ( originalWidth > originalHeight &&
                       originalWidth > maxSize ) {
                
                CGFloat ratio = originalWidth / maxSize;
                resizeWidth = maxSize;
                resizeHeight = originalHeight / ratio;
                
            } else {
                
                return image;
            }
            
        //指定サイズ以下、リサイズ無し
        } else {
            
            return image;
        }
    }
    
    resizeWidth = roundf(resizeWidth);
    resizeHeight = roundf(resizeHeight);
    
    UIGraphicsBeginImageContext(CGSizeMake(resizeWidth, resizeHeight));
	[image drawInRect:CGRectMake(0.0f, 0.0f, resizeWidth, resizeHeight)];
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    return image;
}

@end
