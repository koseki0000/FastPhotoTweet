//
//  ResizeImage.h
//  UtilityClass
//
//  Created by @peace3884 on 12/03/08.
//

#import <Foundation/Foundation.h>

@interface ResizeImage : NSObject

+ (UIImage *)aspectResize:(UIImage *)image;
+ (UIImage *)aspectResizeForMaxSize:(UIImage *)image maxSize:(int)maxSize;

@end