//
//  UIImage+Convert.h
//

#import <UIKit/UIKit.h>

@interface UIImage (Convert)

+ (UIImage *)imageWithDataByContext:(NSData *)imageData;
+ (UIImage *)imageWithContentsOfFileByContext:(NSString *)imagePath;
+ (UIImage *)maskImage:(UIImage *)image withMask:(UIImage *)maskImage;

@end
