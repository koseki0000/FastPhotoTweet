//
//  ResizeImage.m
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/08.
//

#import "ResizeImage.h"

@implementation ResizeImage

+ (UIImage *)aspectResize:(UIImage *)image {

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	NSUserDefaults *d = [NSUserDefaults standardUserDefaults];
    
    size_t resizeHeight = 0;
    size_t resizeWidth = 0;
    int originalHeight = abs((int)resizeHeight);
    int originalWidth = abs((int)resizeWidth);
    BOOL skip = NO;
    
    //リサイズ前のログ
    NSLog(@"OriginalSize w: %d h: %d", originalWidth, originalHeight);
    
    //iPhone4解像度はリサイズしない
    if ( [d integerForKey:@"noResizeIphone4Ss"] == 1 ){
        
		if ( originalHeight == 640 && originalWidth == 960 ) {
            
            NSLog(@"640x960");
            
            resizeHeight = 640;
            resizeWidth = 960;
            skip = YES;
            
		}else if ( originalHeight == 960 && originalWidth == 640 ) {
            
            NSLog(@"960x640");
            
            resizeHeight = 960;
            resizeWidth = 640;
            skip = YES;
        }
	}
    
    if ( !skip ) {
        
        //正方形
        if ( originalWidth == originalHeight ) {

            if ( originalHeight < [d integerForKey:@"imageMaxSize"] ) {
                
                CGFloat ratio = originalWidth / [d integerForKey:@"imageMaxSize"];
                resizeWidth = originalWidth / ratio;
                resizeHeight = originalHeight / ratio;
                
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
                    
                    CGFloat ratio = originalHeight / [d integerForKey:@"imageMaxSize"];
                    resizeWidth = originalWidth / ratio;
                    resizeHeight = originalHeight / ratio;    
                
                //横長
                }else {
                    
                    CGFloat ratio = originalWidth / [d integerForKey:@"imageMaxSize"];
                    resizeWidth = originalWidth / ratio;
                    resizeHeight = originalHeight / ratio;
                }
            
            //指定サイズ以下、リサイズ無し
            }else {

                return image;
            }
        }
    }
    
    UIGraphicsBeginImageContext( CGSizeMake( resizeWidth, resizeHeight ) );  
	[image drawInRect:CGRectMake( 0, 0, resizeWidth, resizeHeight )];  
	image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
    
    //リサイズ後のログ
    NSLog(@"OriginalSize w: %d h: %d", originalWidth, originalHeight);
    
    [pool drain];
    
    return image;
}

@end
