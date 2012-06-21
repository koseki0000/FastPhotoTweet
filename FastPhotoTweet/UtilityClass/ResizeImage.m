//
//  ResizeImage.m
//  FastPhotoTweet
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
    float originalHeight = image.size.height;
    float originalWidth = image.size.width;
    float maxSize = (float)[d integerForKey:@"ImageMaxSize"];
    
    //リサイズ前のログ
    //NSLog(@"OriginalSize w: %d h: %d", originalWidth, originalHeight);
    //NSLog(@"ImageMaxSize: %d", [d integerForKey:@"ImageMaxSize"]);
    
    //iPhone4解像度はリサイズしない
    if ( [d boolForKey:@"NoResizeIphone4Ss"] ){
        
		if ( originalHeight == 640 && originalWidth == 960 ) {
            
            //NSLog(@"640x960");
            return image;
            
		}else if ( originalHeight == 960 && originalWidth == 640 ) {
            
            //NSLog(@"960x640");
            return image;
        }
	}
    
    //正方形
    if ( originalWidth == originalHeight ) {
        
        if ( originalHeight > maxSize ) {
            
            resizeWidth = maxSize;
            resizeHeight = maxSize;
            
        }else {
            
            return image;
        }
        
    //長方形
    } else {
        
        if ( originalHeight > maxSize ||
             originalWidth > maxSize ) {
            
            //縦長
            if ( originalHeight > originalWidth && originalHeight > maxSize ) {
                
                //NSLog(@"H > W");
                
                float ratio = originalHeight / maxSize;
                resizeWidth = originalWidth / ratio;
                resizeHeight = maxSize;
                
            //横長
            }else if ( originalWidth > originalHeight && originalWidth > maxSize ) {
                
                //NSLog(@"W > H");
                
                float ratio = originalWidth / maxSize;
                resizeWidth = maxSize;
                resizeHeight = originalHeight / ratio;
                
            }else {
                
                //NSLog(@"No resize");
                
                return image;
            }
            
        //指定サイズ以下、リサイズ無し
        }else {
            
            //NSLog(@"No resize");
            
            return image;
        }
    }
    
    //NSLog(@"ResizeSize w: %lu h: %lu", resizeWidth, resizeHeight);
    
    UIGraphicsBeginImageContext( CGSizeMake( (int)resizeWidth, (int)resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, (int)resizeWidth, (int)resizeHeight )];  
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    //リサイズ後のログ
    //NSLog(@"Resized Image w: %d h: %d", (int)image.size.width, (int)image.size.height);
    
    return image;
}

+ (UIImage *)aspectResizeSetMaxSize:(UIImage *)image maxSize:(int)maxSize {
    
    //NSLog(@"aspectResizeSetMaxSize");
    
    NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    float originalHeight = image.size.height;
    float originalWidth = image.size.width;
    float maxSizeF = (float)maxSize;
    
    //リサイズ前のログ
    //NSLog(@"OriginalSize w: %d h: %d", originalWidth, originalHeight);
    //NSLog(@"ImageMaxSize: %d", maxSize);
    
    //iPhone4解像度はリサイズしない
    if ( [d boolForKey:@"NoResizeIphone4Ss"] ){
        
		if ( originalHeight == 640 && originalWidth == 960 ) {
            
            //NSLog(@"640x960");
            return image;
            
		}else if ( originalHeight == 960 && originalWidth == 640 ) {
            
            //NSLog(@"960x640");
            return image;
        }
	}
    
    //正方形
    if ( originalWidth == originalHeight ) {
        
        if ( originalHeight > maxSizeF ) {
            
            resizeWidth = maxSizeF;
            resizeHeight = maxSizeF;
            
        }else {
            
            return image;
        }
        
        //長方形
    } else {
        
        if ( originalHeight > maxSizeF ||
             originalWidth > maxSizeF ) {
            
            //縦長
            if ( originalHeight > originalWidth && originalHeight > maxSizeF ) {
                
                //NSLog(@"H > W");
                
                float ratio = originalHeight / maxSizeF;
                resizeWidth = originalWidth / ratio;
                resizeHeight = maxSizeF;
                
            //横長
            }else if ( originalWidth > originalHeight && originalWidth > maxSizeF ) {
                
                //NSLog(@"W > H");
                
                float ratio = originalWidth / maxSizeF;
                resizeWidth = maxSizeF;
                resizeHeight = originalHeight / ratio;
                
            }else {
                
                //NSLog(@"No resize");
                
                return image;
            }
            
        //指定サイズ以下、リサイズ無し
        }else {
            
            //NSLog(@"No resize");
            
            return image;
        }
    }
    
    //NSLog(@"ResizeSize w: %lu h: %lu", resizeWidth, resizeHeight);
    
    UIGraphicsBeginImageContext( CGSizeMake( (int)resizeWidth, (int)resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, (int)resizeWidth, (int)resizeHeight )];  
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    //リサイズ後のログ
    //NSLog(@"Resized Image w: %d h: %d", (int)image.size.width, (int)image.size.height);
    
    return image;
}

@end
