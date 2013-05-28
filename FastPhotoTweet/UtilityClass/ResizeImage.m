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
    
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    CGFloat originalHeight = image.size.height;
    CGFloat originalWidth = image.size.width;
    CGFloat maxSize = (CGFloat)[d integerForKey:@"ImageMaxSize"];
        
    //iPhone4解像度もリサイズする
    if ( [d boolForKey:@"NoResizeIphone4Ss"] ){
        
		if ( originalHeight == 640.0f &&
             originalWidth == 960.0f ) {
            
            return image;
            
		}else if ( originalHeight == 960.0f &&
                   originalWidth == 640.0f ) {
            
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
            
            //NSLog(@"No resize");
            
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

+ (UIImage *)aspectResizeForMaxSize:(UIImage *)image maxSize:(CGFloat)maxSize {
    
    //NSLog(@"aspectResizeSetMaxSize");
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    CGFloat originalHeight = image.size.height;
    CGFloat originalWidth = image.size.width;
    
    //iPhone4解像度もリサイズする
    if ( [d boolForKey:@"NoResizeIphone4Ss"] ){
        
		if ( originalHeight == 640.0f &&
             originalWidth == 960.0f ) {
            
            return image;
            
		}else if ( originalHeight == 960.0f &&
                   originalWidth == 640.0f ) {
            
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
