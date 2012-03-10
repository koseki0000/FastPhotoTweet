//
//  ResizeImage.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/08.
//

#import "ResizeImage.h"

@implementation ResizeImage

+ (UIImage *)aspectResize:(UIImage *)image {
    
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    int originalHeight = (int)image.size.height;
    int originalWidth = (int)image.size.width;
    
    //リサイズ前のログ
    NSLog(@"OriginalSize w: %d h: %d", originalWidth, originalHeight);
    NSLog(@"imageMaxSize: %d", [d integerForKey:@"imageMaxSize"]);
    
    //iPhone4解像度はリサイズしない
    if ( [d integerForKey:@"noResizeIphone4Ss"] == 1 ){
        
		if ( originalHeight == 640 && originalWidth == 960 ) {
            
            NSLog(@"640x960");
            
            resizeHeight = 640;
            resizeWidth = 960;
            
		}else if ( originalHeight == 960 && originalWidth == 640 ) {
            
            NSLog(@"960x640");
            
            resizeHeight = 960;
            resizeWidth = 640;
        }
        
        return image;
	}
    
    //正方形
    if ( originalWidth == originalHeight ) {
        
        if ( originalHeight < [d integerForKey:@"imageMaxSize"] ) {
            
            CGFloat ratio = image.size.width / [d integerForKey:@"imageMaxSize"];
            resizeWidth = image.size.width / ratio;
            resizeHeight = image.size.height / ratio;
            
        }else {
            
            resizeWidth = originalWidth;
            resizeHeight = originalHeight;
        }
        
    //長方形
    } else {
        
        
        if ( originalHeight > [d integerForKey:@"imageMaxSize"] ||
            originalWidth > [d integerForKey:@"imageMaxSize"] ) {
            
            //縦長
            if ( originalHeight > originalWidth ) {
                
                NSLog(@"H > W");
                
                CGFloat ratio = image.size.height / [d integerForKey:@"imageMaxSize"];
                resizeWidth = image.size.width / ratio;
                resizeHeight = image.size.height / ratio;
                
            //横長
            }else {
                
                NSLog(@"W > H");
                
                CGFloat ratio = image.size.width / [d integerForKey:@"imageMaxSize"];
                resizeWidth = image.size.width / ratio;
                resizeHeight = image.size.height / ratio;
            }
            
        //指定サイズ以下、リサイズ無し
        }else {
            
            NSLog(@"No resize");
            
            return image;
        }
    }
    
    NSLog(@"ResizeSize w: %lu h: %lu", resizeWidth, resizeHeight);
    
    UIGraphicsBeginImageContext( CGSizeMake( resizeWidth, resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, resizeWidth, resizeHeight )];  
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    //リサイズ後のログ
    NSLog(@"Resized Image w: %.0f h: %.0f", image.size.width, image.size.height);
    
    return image;
}

@end
