//
//  ResizeImage.h
//  FastPhotoTweet
//
//  Created by @peace3884 on 12/03/08.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ResizeImage : NSObject

+ (UIImage *)aspectResize:(UIImage *)image;
+ (UIImage *)aspectResizeSetMaxSize:(UIImage *)image maxSize:(int)maxSize;

@end