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
    int originalHeight = (int)image.size.height;
    int originalWidth = (int)image.size.width;
    
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
        
        if ( originalHeight > [d integerForKey:@"ImageMaxSize"] ) {
            
            float ratio = (float)originalWidth / (float)[d integerForKey:@"ImageMaxSize"];
            resizeWidth = originalWidth / ratio;
            resizeHeight = originalHeight / ratio;
            
        }else {
            
            return image;
        }
        
    //長方形
    } else {
        
        if ( originalHeight > [d integerForKey:@"ImageMaxSize"] ||
             originalWidth > [d integerForKey:@"ImageMaxSize"] ) {
            
            //縦長
            if ( originalHeight > originalWidth && originalHeight > [d integerForKey:@"ImageMaxSize"] ) {
                
                //NSLog(@"H > W");
                
                float ratio = (float)originalHeight / (float)[d integerForKey:@"ImageMaxSize"];
                resizeWidth = originalWidth / ratio;
                resizeHeight = originalHeight / ratio;
                
            //横長
            }else if ( originalWidth > originalHeight && originalWidth > [d integerForKey:@"ImageMaxSize"] ) {
                
                //NSLog(@"W > H");
                
                float ratio = (float)originalWidth / (float)[d integerForKey:@"ImageMaxSize"];
                resizeWidth = originalWidth / ratio;
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
    
    UIGraphicsBeginImageContext( CGSizeMake( resizeWidth, resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, resizeWidth, resizeHeight )];  
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
    int originalHeight = (int)image.size.height;
    int originalWidth = (int)image.size.width;
    
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
        
        if ( originalHeight > maxSize ) {
            
            float ratio = (float)originalWidth / (float)maxSize;
            resizeWidth = originalWidth / ratio;
            resizeHeight = originalHeight / ratio;
            
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
                
                float ratio = (float)originalHeight / (float)maxSize;
                resizeWidth = originalWidth / ratio;
                resizeHeight = originalHeight / ratio;
                
            //横長
            }else if ( originalWidth > originalHeight && originalWidth > maxSize ) {
                
                //NSLog(@"W > H");
                
                float ratio = (float)originalWidth / (float)maxSize;
                resizeWidth = originalWidth / ratio;
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
    
    UIGraphicsBeginImageContext( CGSizeMake( resizeWidth, resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, resizeWidth, resizeHeight )];  
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    //リサイズ後のログ
    //NSLog(@"Resized Image w: %d h: %d", (int)image.size.width, (int)image.size.height);
    
    return image;
}

@end
